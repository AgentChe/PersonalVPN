import Foundation
import Swinject
import iAd

class AppContainer {
    static let sharedContainer = AppContainer()

    var container = Container()

    private init() {
        setup()
    }

    private func setup() {
        container.register(StartupService.self) { r in
            StartupService(
                client: ClientContainer.sharedContainer.container.resolve(Client.self)! as! (CheckClient & VpnClient),
                storage: UserDefaultsStorage.shared,
                attributionService: AttributionService(storage: UserDefaultsStorage.shared, client: ClientContainer.sharedContainer.container.resolve(Client.self)! as! (UserClient & AppInstallsClient), iadClient: ADClient.shared())
            )
        }.inObjectScope(.container)
    }
}
