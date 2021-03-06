import Foundation
import UIKit
import RxSwift

class MoreCoordinator: BaseCoordinator<Void> {
    private let rootViewController: UIViewController
//    private let transitionDelegate = TransitionDelegate()
    private let bag = DisposeBag()

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    override func start() -> Observable<Void> {
        let viewController = MoreViewController()
        let viewModel = MoreViewModel()
        viewModel
            .handleItem
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                switch item.kind {
                case .restorePurchases:
                    break
                case .privacyPolicy:
                    let privacyCoordinator = PrivacyPolicyCoordinator(rootViewController: viewController, url: URL(string: LegalLinks.privacyPolicy.rawValue), buttonType: .accept)
                    self.coordinate(to: privacyCoordinator).subscribe().disposed(by: self.bag)
                    break
                case .termsOfService:
                    let termsCoordinator = PrivacyPolicyCoordinator(rootViewController: viewController, url: URL(string: LegalLinks.termsOfUse.rawValue), buttonType: .close)
                    self.coordinate(to: termsCoordinator).subscribe().disposed(by: self.bag)
                    break
                case .contactUs:
                    let termsCoordinator = PrivacyPolicyCoordinator(rootViewController: viewController, url: URL(string: LegalLinks.contactUs.rawValue), buttonType: .close)
                    self.coordinate(to: termsCoordinator).subscribe().disposed(by: self.bag)
                    break
                }
            })
            .disposed(by: bag)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = viewController
        rootViewController.present(viewController, animated: true)
        return Observable.never()
    }
}
