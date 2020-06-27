import Foundation

class UserDefaultsStorage: Storage {
    static let shared = UserDefaultsStorage()

    enum Key {
        static let UserToken = App.bundleId + ".storage.userToken"
        static let VpnList = App.bundleId + ".storage.vpnList"
        static let SelectedVpn = App.bundleId + ".storage.selectedVpn"
        static let UserId = App.bundleId + ".storage.userId"
        static let ActiveSubscription = App.bundleId + ".storage.activeSubscription"
        static let NeedPayment = App.bundleId + ".storage.needPayment"
        static let RandomString = App.bundleId + ".storage.randomString"
        static let IsAppInstalled = App.bundleId + ".storage.isFirstLaunch"
        static let Attribution = App.bundleId + ".storage.attributionInfo"
    }

    var userToken: String? {
        get {
            userDefaults.string(forKey: Key.UserToken)
        }
        set(newValue) {
            let oldValue = userToken
            userDefaults.set(newValue, forKey: Key.UserToken)
            _storage(self, changedKey: Key.UserToken, oldValue: oldValue, newValue: newValue)
        }
    }

    var vpnList: [VpnServer]? {
        get {
            userDefaults.vpnList(forKey: Key.VpnList)
        }
        set(newValue) {
            let oldValue = vpnList
            userDefaults.set(newValue?.arrayOfDict(), forKey: Key.VpnList)
            _storage(self, changedKey: Key.VpnList, oldValue: oldValue, newValue: newValue)
        }
    }

    var selectedVpn: VpnServer? {
        get {
            do {
                return try VpnServer(dict: userDefaults.dictionary(forKey: Key.SelectedVpn) ?? [:])
            } catch {
                return nil
            }
        }
        set (newValue) {
            let oldValue = selectedVpn
            userDefaults.set(newValue?.dict, forKey: Key.SelectedVpn)
            _storage(self, changedKey: Key.SelectedVpn, oldValue: oldValue, newValue: newValue)
        }
    }

    var userId: String? {
        get {
            userDefaults.string(forKey: Key.UserId)
        }
        set(newValue) {
            let oldValue = userId
            userDefaults.set(newValue, forKey: Key.UserId)
            _storage(self, changedKey: Key.UserId, oldValue: oldValue, newValue: newValue)
        }
    }

    var activeSubscription: Bool {
        get {
            userDefaults.bool(forKey: Key.ActiveSubscription)
        }
        set(newValue) {
            let oldValue = activeSubscription
            userDefaults.set(newValue, forKey: Key.ActiveSubscription)
            _storage(self, changedKey: Key.ActiveSubscription, oldValue: oldValue, newValue: newValue)
        }
    }

    var needPayment: Bool {
        get {
            userDefaults.bool(forKey: Key.NeedPayment)
        }
        set(newValue) {
            let oldValue = needPayment
            userDefaults.set(newValue, forKey: Key.NeedPayment)
            _storage(self, changedKey: Key.NeedPayment, oldValue: oldValue, newValue: newValue)
        }
    }

    var uniqRandomId: String {
        get {
            if let uniq = userDefaults.string(forKey: Key.RandomString) {
                return uniq
            }
            else {
                let uuid = UUID().uuidString
                userDefaults.set(uuid, forKey: Key.RandomString)
                _storage(self, changedKey: Key.RandomString, oldValue: nil, newValue: uuid)
                return uuid
            }
        }
        set(newValue) {
            let oldValue = uniqRandomId
            userDefaults.set(newValue, forKey: Key.RandomString)
            _storage(self, changedKey: Key.RandomString, oldValue: oldValue, newValue: newValue)
        }
    }

    var isFirstLaunch: Bool {
        get {
            !userDefaults.bool(forKey: Key.IsAppInstalled)
        }
        set(newValue) {
            let oldValue = isFirstLaunch
            userDefaults.set(!newValue, forKey: Key.IsAppInstalled)
            _storage(self, changedKey: Key.IsAppInstalled, oldValue: oldValue, newValue: !newValue)
        }
    }

    var attributionInfo: [String: String]? {
        get {
            userDefaults.dictionary(forKey: Key.Attribution) as? [String: String]
        }
        set {
            let oldValue = attributionInfo
            userDefaults.set(newValue, forKey: Key.Attribution)
            _storage(self, changedKey: Key.Attribution, oldValue: oldValue, newValue: newValue)
        }
    }

    private let userDefaults = UserDefaults.standard
    private var observations = [ObjectIdentifier : Observation]()
}

extension UserDefaultsStorage: StorageObserving {
    func addObserver(_ observer: StorageObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: StorageObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

private extension UserDefaultsStorage {
    struct Observation {
        weak var observer: StorageObserver?
    }

    func _storage(_ storage: Storage, changedKey: String, oldValue: Any?, newValue: Any?) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.storage(storage, changedKey: String(changedKey.split(separator: ".").last!), oldValue: oldValue, newValue: newValue)
        }
    }
}

extension Sequence where Iterator.Element == VpnServer {
    func arrayOfDict() -> [[String: Any]] {
        map { server -> [String: Any] in server.dict }
    }
}

extension UserDefaults {
    func vpnList(forKey key: String) -> [VpnServer]? {
        guard let vpnArray = array(forKey: key) as? [[String: Any]] else { return nil }
        return vpnArray.map { (dictionary: [String: Any]) -> VpnServer in
            try! VpnServer(dict: dictionary)
        }
    }
}
