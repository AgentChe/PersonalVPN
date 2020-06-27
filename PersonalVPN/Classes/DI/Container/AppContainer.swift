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
        container.register(OldPurchaseService.self) { _ in
            OldPurchaseService(productIds: AppProducts.productIdentifiers)
        }.inObjectScope(.container)
        container.register(StartupService.self) { r in
            StartupService(
                client: ClientContainer.sharedContainer.container.resolve(Client.self)! as! (CheckClient & PaymentsClient & VpnClient),
                storage: UserDefaultsStorage.shared,
                attributionService: AttributionService(storage: UserDefaultsStorage.shared, client: ClientContainer.sharedContainer.container.resolve(Client.self)! as! (UserClient & AppInstallsClient), iadClient: ADClient.shared())
            )
        }.inObjectScope(.container)
    }
}
