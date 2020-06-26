import Foundation
import RxSwift

struct ServerViewModel {
    let id: Int
    let title: String
    let selected: Bool
}

class ServerListViewModel {
    // MARK: - Inputs
    let selectServer: AnyObserver<ServerViewModel>

    // MARK: - Outputs
    var items = Variable<[ServerViewModel]>([ServerViewModel]())
    var handleServer: Observable<ServerViewModel>

    // MARK: - Service
    var storage: Storage

    init(storage: Storage) {
        self.storage = storage
        let _selectServer = PublishSubject<ServerViewModel>()
        self.selectServer = _selectServer.asObserver()
        self.handleServer = _selectServer.asObservable()

        self.handleServer = self.handleServer.do(onNext: { [weak self] server in
            guard let self = self else {
                return
            }
            let selected: VpnServer? = self.storage.vpnList?.first { s in
                server.id == s.id
            }
            self.storage.selectedVpn = selected
        })

        if let list = storage.vpnList {
            let selectedServer = storage.selectedVpn
            let servers = list.map {
                ServerViewModel(id: $0.id, title: $0.location, selected: $0.id == selectedServer?.id)
            }
            items.value.append(contentsOf: servers)
        }
    }
}
