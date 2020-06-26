import Foundation
import Swinject

class ClientContainer {
    static let sharedContainer = ClientContainer()

    var container = Container()

    private init() {
        setup()
    }

    private func setup() {
        container.register(NetworkClient.self) { _ in
            NetworkClient()
        }.inObjectScope(.container)
        container.register(Client.self) { r in
            APIClient(network: r.resolve(NetworkClient.self)!, token: NetworkConfiguration.userToken ?? "_")
        }
    }
}
