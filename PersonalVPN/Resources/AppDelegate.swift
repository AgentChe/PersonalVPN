import UIKit
import StoreKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var iapObserver: OldPurchaseService!
    var startup: StartupService!
    var window: UIWindow?
    private var appCoordinator: AppCoordinator!
    private let disposeBag = DisposeBag()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let container = AppContainer.sharedContainer.container
        iapObserver = container.resolve(OldPurchaseService.self)
        startup = container.resolve(StartupService.self)
        SKPaymentQueue.default().add(iapObserver)
        startup.coldStart()
        window = UIWindow()
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator.start()
            .subscribe()
            .disposed(by: disposeBag)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(iapObserver)
    }



























































































}
