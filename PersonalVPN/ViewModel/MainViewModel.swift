import Foundation
import RxSwift

class MainViewModel {
    typealias State = (state: String, data: String?, time: String?)
    // MARK: - Inputs

    var changeState: AnyObserver<Void>?
    var selectMore: AnyObserver<Void>
    var selectLocation: AnyObserver<Void>
    var firstAppear: AnyObserver<Bool>?
    var paygate: AnyObserver<Void>?

    var _firstAppear = PublishSubject<Bool>()
    let _alertMessage = PublishSubject<String>()

    // MARK: - Outputs

    var state: Observable<State>?
    var more: Observable<Void>
    var location: Observable<Void>
    var handleFirstAppear: Observable<Bool>
    var handlePaygate: Observable<Void>
    let alertMessage: Observable<String>

    // MARK: - Service

    var tunnel: TunnelService? {
        didSet {
            if let t = tunnel {
                state = t.statusObservable
                    .observeOn(MainScheduler.instance)
                    .map { [weak self] status -> State in
                        let data = String(format: "%.2f", Double(status.dataReceived) / 1024 / 1024)
                        let s = Int(fabs(status.connectionInterval)) % 60
                        let m = Int(fabs(status.connectionInterval)) / 60 % 60
                        let h = Int(fabs(status.connectionInterval)) / (60 * 60)
                        let time = String(format: "%d:%d:%d", h, m, s)
                        return (
                            self?.stringStatus(from: status.status) ?? "Connect",
                            status.status == .connected ? data : nil,
                            status.status == .connected ? time : nil
                        )
                    }
            }
        }
    }

    private var storage: Storage
    private let client: VpnClient

    private var firstAppearWasHit = false

    deinit {
        storage.removeObserver(self)
    }

    init(client: VpnClient, storage: Storage) {
        self.client = client
        self.storage = storage
        let _more = PublishSubject<Void>()
        more = _more.asObservable()
        selectMore = _more.asObserver()

        alertMessage = _alertMessage.asObservable()


        let _location = PublishSubject<Void>()
        location = _location.asObservable()
        selectLocation = _location.asObserver()

        let _paygate = PublishSubject<Void>()
        paygate = _paygate.asObserver()
        handlePaygate = _paygate.asObservable()

        firstAppear = _firstAppear.asObserver()
        handleFirstAppear = _firstAppear.asObservable()

        handleFirstAppear = handleFirstAppear.map { [weak self] b in
            self?.storage.activeSubscription ?? false
        }

        changeState = AnyObserver<Void> { [weak self] (v: Event<Void>) in
//            let vpnId = String(self?.storage.selectedVpn?.id ?? 0)
            let tunnelStatus = self?.tunnel?.connectionStatus.status
            if tunnelStatus == .connected || tunnelStatus == .connecting {
                self?.tunnel?.disconnect()
                return
            }
            if let vpnId = self?.storage.selectedVpn?.id {
                self?.fetchVpnConfiguration(String(vpnId))
            } else {
                self?.client.list { servers, error in
                    if let error = error {
                        print("Fail to get list of vpn with error \(error)")
                        self?._alertMessage.onNext("Fail to get list of vpn with error")
                        return
                    }
                    self?.storage.vpnList = servers
                    if self?.storage.selectedVpn == nil {
                        self?.storage.selectedVpn = servers?.first
                    }
                    self?.fetchVpnConfiguration(String(self?.storage.selectedVpn?.id ?? 0))
                }
            }
        }

        storage.addObserver(self)
    }

    private func fetchVpnConfiguration(_ vpnId: String) {
        guard vpnId != "0" else {
            _alertMessage.onNext("There is no selected VPN server. Please choose one to connect.")
            return
        }
        client.configuration(vpnId: vpnId) { [weak self] tuple, error in
            if let error = error, case ApiClientError.needPayment = error {
                self?.paygate?.onNext(())
            }
            guard let t = tuple, let sc = t.1, let data = Data(base64Encoded: sc) else {
                self?._alertMessage.onNext("Could not connect to VPN server")
                print("Could not start vpn configuration with error \(String(describing: error))")
                return
            }
            guard let conf = String(data: data, encoding: .utf8) else {
                fatalError("Could not start vpn with configuration")
            }
            self?.storage.needPayment = t.0
            if !t.0 {
                self?.tunnel?.connectionStatus.status == .connected ? self?.tunnel?.disconnect() : self?.tunnel?.connect(using: conf)
            } else {
                self?.paygate?.onNext(())
            }
        }
    }

    private func stringStatus(from status: TunnelStatus) -> String {
        switch status {
        case .invalid:
            return "Connect"
        case .disconnected:
            return "Connect"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .reasserting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        }
    }
}

extension MainViewModel: StorageObserver {
    func storage(_ storage: Storage, changedKey: String, oldValue: Any?, newValue: Any?) {
//        if "needPayment" == changedKey  {
        if "activeSubscription" == changedKey {
            let val = newValue as? Bool ?? false
            if !val {
                _firstAppear.onNext(true)
//            print("ASDFSAFSADFSAF ")
            }
        }
    }
}
