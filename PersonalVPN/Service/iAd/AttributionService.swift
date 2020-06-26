import Foundation
import iAd
import AdSupport

class AttributionService {
    var storage: Storage
    let client: UserClient & AppInstallsClient
    let iadClient: ADClient

    init(storage: Storage, client: UserClient & AppInstallsClient, iadClient: ADClient) {
        self.storage = storage
        self.client = client
        self.iadClient = iadClient
    }

    class var idfa: String {
        ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    func register(completion: @escaping ([String: String], Bool) -> ()) {
        if !storage.isFirstLaunch {
            completion([:], false); return
        }
        loadAttributes { [weak self] dictionary in
            guard let self = self else { completion([:], false); return }
            self.client.register(idfa: AttributionService.idfa,
                                 randomString: self.storage.uniqRandomId,
                                 version: App.version,
                                 attributes: dictionary) { response, error in
                                    let fakeCampaign = dictionary["iad-campaign"] ?? "" == "1234567890"
                                    let attribution = dictionary["iad-attribution"] ?? "" == "true"
                                    completion(dictionary, attribution && !fakeCampaign)
            }
        }
    }

    func addAdsInfo(completion: @escaping () -> ()) {
        loadAttributes { [weak self] dictionary in
            guard let self = self else { completion(); return }
            self.client.addAdsInfo(attrs: dictionary) { response, error in completion() }
        }
    }

    func setUserInfo(full: Bool, completion: @escaping () -> ()) {
        client.set(idfa: full ? AttributionService.idfa : nil,
                   randomString: full ? storage.uniqRandomId : nil,
                   version: App.version,
                   locale: App.locale,
                   timezone: App.timezone.identifier,
                   storeCountry: App.currency
        ) { response, error in
            completion()
        }
    }

    private func loadAttributes(completion: @escaping ([String: String]) -> ()) {
        if let attrs = storage.attributionInfo {
            completion(attrs)
        } else {
            iadClient.requestAttributionDetails { [weak self] dictionary, error in
                let d = dictionary?.first?.value as? [String: NSObject] ?? [:]
                let attributes = d.filter { (val: (key: String, value: NSObject)) -> Bool in
                        val.value.isKind(of: NSString.self) || val.value.isKind(of: NSNumber.self)
                    }
                    .mapValues { object -> String in
                        object.isKind(of: NSNumber.self) ? (object as! NSNumber).stringValue : object as! String
                    }
                self?.storage.attributionInfo = attributes
                completion(attributes)
            }
        }
    }
}
