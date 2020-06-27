import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

typealias HTTPHeaders = [String: String]

typealias HTTPParams = [String: String]

extension HTTPParams {
    enum RequestSystemKey {
        static let API = "_api_key"
        static let userToken = "_user_token"
    }

    enum ResponseSystemKey {
        static let code = "_code"
        static let msg = "_msg"
        static let needPayment = "_need_payment"
    }

    static var defaultParams: [String: String] {
        try! [
            RequestSystemKey.API: NetworkConfiguration.apiKey(),
            RequestSystemKey.userToken: NetworkConfiguration.userToken ?? ""
        ]
    }
}