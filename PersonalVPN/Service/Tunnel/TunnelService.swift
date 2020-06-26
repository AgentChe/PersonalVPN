import Foundation
import TunnelKit
import NetworkExtension
import RxSwift
import os

class TunnelService {
    typealias ConnectionState = (status: TunnelStatus, dataReceived: Int, connectionInterval: TimeInterval)

    var connectionStatus = ConnectionState(status: .invalid, dataReceived: 0, connectionInterval: 0)

    lazy var scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    lazy var statusObservable: Observable<ConnectionState> =
        Observable<Int>
        .timer(.seconds(1), period: .seconds(1), scheduler: scheduler)
            .map { _ -> ConnectionState in
            let dataCount = self.configuration?.dataCount(in: App.groupId)
            let connectionTime = self.session?.connectedDate?.timeIntervalSinceNow
            self.connectionStatus = (self.status.tunnelStatus, dataCount?.0 ?? 0, connectionTime ?? 0)
            return self.connectionStatus
        }

    private let client: VpnClient
    private let storage: Storage
    private var configuration: OpenVPNTunnelProvider.Configuration?
    private var currentManager: NETunnelProviderManager?
    private var session: NETunnelProviderSession?
    private var status = NEVPNStatus.invalid
    private var tunnelLog = OSLog(subsystem: "app.yourpersonalvpn", category: "TunnelService")

    init(client: VpnClient, storage: Storage) {
        self.client = client
        self.storage = storage
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
    }

    func connect(using configuration: String) {
        connect(stringConfiguration: configuration)
    }

    func connect() {
        let vpnId = String(storage.selectedVpn?.id ?? 0)
        client.configuration(vpnId: vpnId) { [weak self] configuration, error in
            guard let configuration = configuration, let sc = configuration.1, let data = Data(base64Encoded: sc) else {
                if let tl = self?.tunnelLog {
                    os_log("Could not start vpn configuration with error %s", log: tl, type: .error, error?.localizedDescription ?? "No error description")
                }
                print("Could not start vpn configuration with error \(error)")
                return
            }
            guard let conf = String(data: data, encoding: .utf8) else {
                if let tl = self?.tunnelLog {
                    os_log("Could not start vpn with configuration", log: tl, type: .error)
                }
                fatalError("Could not start vpn with configuration")
            }
            self?.connect(stringConfiguration: conf)
        }
    }

    func disconnect() {
        currentManager?.connection.stopVPNTunnel()
    }
    
    func configure(using configuration: String,
                   completionHandler: @escaping (Error?) -> Void) {
        configureVPN(
        { (manager) in
            self.makeProtocol(from: configuration)
        },
        completionHandler: { (error) in
            if let error = error {
                os_log("configure error: %s", log: self.tunnelLog, type: .error, error.localizedDescription)
                print("configure error: \(error)")
            }
            completionHandler(error)
        })
    }

    private func connect(stringConfiguration: String) {
        configureVPN(
            { (manager) in
                self.makeProtocol(from: stringConfiguration)
            },
            completionHandler: { (error) in
                if let error = error {
                    os_log("configure error: %s", log: self.tunnelLog, type: .error, error.localizedDescription)
                    print("configure error: \(error)")
                    return
                }
                self.session = self.currentManager?.connection as! NETunnelProviderSession
                do {
                    try self.session?.startTunnel()
                } catch let e {
                    os_log("error starting tunnel: %s", log: self.tunnelLog, type: .error, e.localizedDescription)
                    print("error starting tunnel: \(e)")
                }
            })
    }

    private func configureVPN(
        _ configure: @escaping (NETunnelProviderManager) -> NETunnelProviderProtocol?,
        completionHandler: @escaping (Error?) -> Void
    ) {
        reloadCurrentManager { (error) in
            if let error = error {
                os_log("error reloading preferences: %s", log: self.tunnelLog, type: .error, error.localizedDescription)
                print("error reloading preferences: \(error)")
                completionHandler(error)
                return
            }

            let manager = self.currentManager!
            if let protocolConfiguration = configure(manager) {
                manager.protocolConfiguration = protocolConfiguration
            }
            manager.isEnabled = true

            manager.saveToPreferences { (error) in
                if let error = error {
                    os_log("error saving preferences: %s", log: self.tunnelLog, type: .error, error.localizedDescription)
                    print("error saving preferences: \(error)")
                    completionHandler(error)
                    return
                }
                self.reloadCurrentManager(completionHandler)
            }
        }
    }

    private func reloadCurrentManager(_ completionHandler: ((Error?) -> Void)?) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let error = error {
                completionHandler?(error)
                return
            }

            var manager: NETunnelProviderManager?

            for m in managers! {
                if let p = m.protocolConfiguration as? NETunnelProviderProtocol {
                    if p.providerBundleIdentifier == App.extensionId {
                        manager = m
                        break
                    }
                }
            }

            if (manager == nil) {
                manager = NETunnelProviderManager()
            }

            self.currentManager = manager
            self.status = manager!.connection.status
            completionHandler?(nil)
        }
    }

    private func displayLog() {
        guard let vpn = currentManager?.connection as? NETunnelProviderSession else {
            return
        }
        do {
            try vpn.sendProviderMessage(OpenVPNTunnelProvider.Message.requestLog.data) { (data) in
                guard let data = data, let log = String(data: data, encoding: .utf8) else {
                    return
                }
                os_log("Display log:\n%s", log: self.tunnelLog, type: .info, log)
                print(log)
            }
        } catch {
            print(error)
        }
    }

    @objc private func VPNStatusDidChange(notification: NSNotification) {
        guard let status = currentManager?.connection.status else {
            return
        }
        displayLog()
        if self.status != status {
            self.status = status
        }
    }

    private func makeProtocol(from stringConfiguration: String) -> NETunnelProviderProtocol? {
        do {
            let lines: [String] = stringConfiguration.trimmedLines()
            let parsedConfiguration = try OpenVPN.ConfigurationParser.parsed(fromLines: lines)
            let builder =
                OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: parsedConfiguration.configuration)
            configuration = builder.build()
            do {
                let providerProtocol: NETunnelProviderProtocol? = try configuration?.generatedTunnelProtocol(withBundleIdentifier: App.extensionId, appGroup: App.groupId)
                return providerProtocol
            } catch {
                os_log("Error while make protocol: %s", log: tunnelLog, type: .error, error.localizedDescription)
                print("Error while make protocol \(error.localizedDescription)")
                return nil
            }

        } catch let error as NSError {
            print(error.localizedDescription)
            fatalError()
        }
    }
}

extension NEVPNStatus {
    var tunnelStatus: TunnelStatus {
        switch self {
        case .invalid:
            return TunnelStatus.invalid
        case .disconnected:
            return TunnelStatus.disconnected
        case .connecting:
            return TunnelStatus.connecting
        case .connected:
            return TunnelStatus.connected
        case .reasserting:
            return TunnelStatus.reasserting
        case .disconnecting:
            return TunnelStatus.disconnecting
        }
    }
}

private extension String {
    func trimmedLines() -> [String] {
        components(separatedBy: .newlines).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter {
            !$0.isEmpty
        }
    }
}
