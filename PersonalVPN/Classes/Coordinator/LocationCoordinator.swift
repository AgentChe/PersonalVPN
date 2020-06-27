import Foundation
import UIKit
import RxSwift

class LocationCoordinator: BaseCoordinator<Void> {
    private let rootViewController: UIViewController
    private let bag = DisposeBag()

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    override func start() -> Observable<Void> {
        let viewController = ServerListViewController()
        let viewModel = ServerListViewModel(storage: UserDefaultsStorage.shared)
        viewModel
            .handleServer
            .subscribe(onNext: { [weak self] server in
                guard let self = self else { return }
                self.rootViewController.dismiss(animated: true)
            })
            .disposed(by: bag)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = viewController
        rootViewController.present(viewController, animated: true)
        return Observable.never()
    }
}
