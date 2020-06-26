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
        container.register(PurchaseService.self) { _ in
            PurchaseService(productIds: AppProducts.productIdentifiers)
        }.inObjectScope(.container)
        container.register(StartupService.self) { r in
            StartupService(
                client: ClientContainer.sharedContainer.container.resolve(Client.self)! as! (CheckClient & PaymentsClient & VpnClient),
                storage: UserDefaultsStorage.shared,
                purchase: r.resolve(PurchaseService.self)!,
                attributionService: AttributionService(storage: UserDefaultsStorage.shared, client: ClientContainer.sharedContainer.container.resolve(Client.self)! as! (UserClient & AppInstallsClient), iadClient: ADClient.shared())
            )
        }.inObjectScope(.container)
    }
}
