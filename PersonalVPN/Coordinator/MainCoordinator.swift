import Foundation
import RxSwift

class MainCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    private let bag = DisposeBag()
    private let client = ClientContainer.sharedContainer.container.resolve(Client.self)! as! VpnClient
    private let storage = UserDefaultsStorage.shared

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<Void> {
        let viewModel = MainViewModel(client: client, storage: storage)
        viewModel.tunnel = TunnelService(client: client, storage: storage)
        let mainViewController = MainViewController()
        mainViewController.viewModel = viewModel
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
        
        viewModel.more.subscribe(onNext: { [weak self] _ in
            let moreCoordinator = MoreCoordinator(rootViewController: mainViewController)
            self?.coordinate(to: moreCoordinator)
        }).disposed(by: bag)
        viewModel.location.subscribe(onNext: { [weak self] _ in
            let locationCoordinator = LocationCoordinator(rootViewController: mainViewController)
            self?.coordinate(to: locationCoordinator)
        }).disposed(by: bag)
        
        viewModel.handleFirstAppear
            .observeOn(MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] b in
                guard !b else {
                    return
                }
                let paygateCoordinator = PaygateCoordinator(rootViewController: mainViewController)
                self?.coordinate(to: paygateCoordinator)
            }).disposed(by: bag)
        viewModel.handlePaygate
        .observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in
            let paygateCoordinator = PaygateCoordinator(rootViewController: mainViewController)
            self?.coordinate(to: paygateCoordinator)
        }).disposed(by: bag)
        
        if (!UserDefaults.standard.bool(forKey: "privacy")) {
            let privacyCoordinator = PrivacyPolicyCoordinator(rootViewController: mainViewController, url: URL(string: LegalLinks.privacyPolicy.rawValue), buttonType: .accept, purchaseService: AppContainer.sharedContainer.container.resolve(PurchaseService.self)!)
            self.coordinate(to: privacyCoordinator).subscribe().disposed(by: bag)
        }
        return Observable.never()
    }
}
