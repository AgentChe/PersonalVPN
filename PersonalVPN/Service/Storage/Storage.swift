import Foundation

extension KeyPath {
    var toString: String? {
        NSExpression(forKeyPath: self).keyPath
    }
}

protocol StorageObserving {
    func addObserver(_ observer: StorageObserver)
    func removeObserver(_ observer: StorageObserver)
}

protocol StorageObserver: class {
    func storage(_ storage: Storage, changedKey: String, oldValue: Any?, newValue: Any?)
}

protocol Storage: StorageObserving {
    var userToken: String? { get set }
    var vpnList: [VpnServer]? { get set }
    var selectedVpn: VpnServer? { get set }
    var userId: String? { get set }
    var activeSubscription: Bool { get set }
    var uniqRandomId: String { get }
    var needPayment: Bool { get set }
    var isFirstLaunch: Bool { get set }
    var attributionInfo: [String: String]? { get set }
}
