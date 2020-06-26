import Foundation
import os

protocol Client {
    func request<E: Endpoint>(_ endpoint: E, completion: @escaping (ClientResponse) -> ())
}

typealias CheckResponse = (CheckTokenResponse?, ApiClientError?)

typealias Response<T: ResponseProtocol> = (T?, ApiClientError?)

protocol CheckClient {
    func checkToken(_ completion: @escaping (CheckResponse) -> ())
}

protocol PaymentsClient {
    func validate(receipt: String, completion: @escaping (CheckResponse) -> ())
    func paygate(completion: @escaping (Response<PaygateResponse>) -> ())
}

protocol VpnClient {
    func list(_ completion: @escaping ([VpnServer]?, ApiClientError?) -> ())
    func configuration(vpnId: String, completion: @escaping ((Bool, String?)?, ApiClientError?) -> ())
}

protocol UserClient {
    func set(idfa: String?, randomString: String?, version: String, locale: String, timezone: String, storeCountry: String, completion: @escaping (Response<BaseResponse>) -> ())
    func addAdsInfo(attrs: [String: String], completion: @escaping (Response<BaseResponse>) -> ())
}

protocol AppInstallsClient {
    func register(idfa: String,
                  randomString: String,
                  version: String,
                  attributes: [String: String],
                  completion: @escaping (Response<BaseResponse>) -> ())
}

class APIClient: Client {

    var network: NetworkClient
    var token: String {
        NetworkConfiguration.userToken ?? ""
    }

    private var requestQueue = Set<URL>()

    init(network: NetworkClient, token: String) {
        self.network = network
    }

    func request<E: Endpoint>(_ endpoint: E, completion: @escaping (ClientResponse) -> ()) {
        guard canAddRequest(for: endpoint.path) else {
            completion(ClientResponse(needPayment: true, data: nil, error: .sameRequestInQueue))
            return
        }
        requestQueue.insert(endpoint.path)
        network.request(endpoint) { [weak self] dictionary, error in
            guard let self = self else { return }
            self.requestQueue.remove(endpoint.path)
            if let error = error {
                os_log("Error %s while validate token %s", error.localizedDescription, self.token)
                print("Error \(error) while validate token \(self.token)")
                completion(ClientResponse(needPayment: false, data: nil, error: .httpError(error: error)))
                return
            }
            if let data = dictionary?["_data"], let code = dictionary?["_code"] as? NSNumber  {
                if code.int64Value == 200 {
                    completion(ClientResponse(needPayment: dictionary?["_need_payment"] as! Bool, data: data as AnyObject, error: nil))
                }
                else {
                    if code.int64Value == 401 || code.int64Value == 400 {
                        completion(ClientResponse(needPayment: dictionary?["_need_payment"] as! Bool, data: nil, error: .tokenInvalid(code: 401, msg: "")))
                    }
                    else if code.int64Value == 403 {
                        completion(ClientResponse(needPayment: true, data: nil, error: .needPayment))
                    }
                    else {
                        completion(ClientResponse(needPayment: true, data: nil, error: .unexpectedResponseDataType))
                    }
                }
            }
            else {
                completion(ClientResponse(needPayment: false, data: nil, error: .missingDataInResponse))
            }
        }
    }

    func handle<T: ResponseProtocol>(with completion: @escaping (Response<T>) -> ()) -> (ClientResponse) -> () {
        { response in
            guard let data = response.data else {
                completion(Response(nil, response.error))
                return
            }
            /*guard var dict = data as? Dictionary<String, AnyObject> else {
                completion(Response(nil, .unexpectedResponseDataType))
                return
            }*/
            var dict = [String: AnyObject]()
            var unexpectedResponseDataType = false
            if let str = data as? String {
                if str != "{}" {
                    unexpectedResponseDataType = true
                }
                else {
                    dict = [:]
                }
            }
            else {
                unexpectedResponseDataType = (data as? Dictionary<String, AnyObject>) == nil
                if !unexpectedResponseDataType {
                    dict = data as! Dictionary<String, AnyObject>
                }
                else {
                    dict = [:]
                }
            }
            if unexpectedResponseDataType {
                completion(Response(nil, .unexpectedResponseDataType))
                return
            }
            do {
                dict["_need_payment"] = response.needPayment as AnyObject
                let apiResponse = try T(rawResponse: dict)
                completion(Response(apiResponse, nil))
            } catch {
                completion(Response(nil, .unexpectedResponseDataType))
            }
        }
    }

    private func canAddRequest(for path: URL) -> Bool { !requestQueue.contains(path) }
}

extension APIClient: AppInstallsClient {
    func register(idfa: String,
                  randomString: String,
                  version: String,
                  attributes: [String: String],
                  completion: @escaping (Response<BaseResponse>) -> ()) {
        let registerApi = AppInstallsEndpoint.register(idfa: idfa,
                                                       randomString: randomString,
                                                       version: version,
                                                       attributes: attributes)
        request(registerApi, completion: handle(with: completion))
    }
}

extension APIClient: UserClient {
    func set(idfa: String?,
             randomString: String?,
             version: String,
             locale: String,
             timezone: String,
             storeCountry: String,
             completion: @escaping (Response<BaseResponse>) -> ()) {
        let setApi = UserEndpoints.set(idfa: idfa, randomString: randomString, version: version, locale: locale, timezone: timezone, storeCountry: storeCountry)
        request(setApi, completion: handle(with: completion))
    }

    func addAdsInfo(attrs: [String: String], completion: @escaping (Response<BaseResponse>) -> ()) {
        let addApi = UserEndpoints.addAdsInfo(attrs: attrs)
        request(addApi, completion: handle(with: completion))
    }
}

extension APIClient: CheckClient, PaymentsClient {
    func checkToken(_ completion: @escaping (CheckResponse) -> ()) {
        let tokenApi = CheckEndpoints.userToken(token: token)
        request(tokenApi, completion: handleResponse(with: completion))
    }

    func validate(receipt: String, completion: @escaping (CheckResponse) -> ()) {
        let validateApi = PaymentEndpoints.validate(receipt: receipt, version: nil)
        request(validateApi, completion: handleResponse(with: completion))
    }

    func paygate(completion: @escaping (Response<PaygateResponse>) -> ()) {
        let paygateApi = PaymentEndpoints.paygate(version: App.version)
        request(paygateApi, completion: handle(with: completion))
    }

    private func handleResponse(with completion: @escaping (CheckResponse) -> ()) -> (ClientResponse) -> () {
        { response in
            guard let data = response.data else {
                completion(CheckResponse(nil, response.error))
                return
            }
            guard var dict = data as? Dictionary<String, AnyObject> else {
                completion(CheckResponse(nil, .unexpectedResponseDataType))
                return
            }
            do {
                dict["_need_payment"] = response.needPayment as AnyObject
                let checkTokenResponse = try CheckTokenResponse(rawResponse: dict)
                completion(CheckResponse(checkTokenResponse, nil))
            } catch {
                completion(CheckResponse(nil, .unexpectedResponseDataType))
            }
        }
    }
}

extension APIClient: VpnClient {
    func list(_ completion: @escaping ([VpnServer]?, ApiClientError?) -> ()) {
        let listApi = VpnEndpoints.list
        request(listApi) { response in
            guard let data = response.data else {
                completion(nil, response.error)
                return
            }
            guard let array = data as? Array<[String: AnyObject]> else {
                completion(nil, .unexpectedResponseDataType)
                return
            }
            do {
                var servers = [VpnServer]()
                for dict in array {
                    try servers.append(VpnServer(dict: dict))
                }
                completion(servers, nil)
            } catch {
                completion(nil, .unexpectedResponseDataType)
            }
        }
    }

    func configuration(vpnId: String, completion: @escaping ((Bool, String?)?, ApiClientError?) -> ()) {
        let configurationApi = VpnEndpoints.configuration(vpnId: vpnId)
        request(configurationApi) { response in
            guard let data = response.data else {
                completion(nil, response.error)
                return
            }
            guard let dict = data as? [String: Any], let config = dict["config"] as? String 
                else {
                completion(nil, .unexpectedResponseDataType)
                return
            }
            completion((response.needPayment, config), nil)
        }
    }

}
