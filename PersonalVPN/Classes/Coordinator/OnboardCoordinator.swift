import Foundation
import UIKit
import RxSwift
import RxCocoa

enum OnboardCoordinationResult {
    case accept
}

class OnboardCoordinator: BaseCoordinator<Void> {
    private let rootViewController: UIViewController
    private let purchaseService: OldPurchaseService
    private let bag = DisposeBag()

    init(viewController: UIViewController, purchaseService: OldPurchaseService) {
        self.rootViewController = viewController
        self.purchaseService = purchaseService
    }

    override func start() -> Observable<Void> {
        let viewController = OnboardViewController()
        let viewModel = OnboardViewModel()
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .fullScreen
        viewModel
            .didAccept
            .subscribe(onNext: { [weak self] _ in
                self?.purchaseService.continueProcessingPayment()
                UserDefaults.standard.set(true, forKey: "privacy")
                self?.rootViewController.dismiss(animated: true)
            })
            .disposed(by: bag)

        rootViewController.present(viewController, animated: true)

        return Observable.never()
    }
}
