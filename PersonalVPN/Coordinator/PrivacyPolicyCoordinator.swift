//
// Created by Anton Serov on 24.10.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum PrivacyPolicyCoordinationResult {
    case accept
}

enum PrivacyButtonType {
    case accept
    case close
}

class PrivacyPolicyCoordinator: BaseCoordinator<Void> {
    let url: URL?
    private let rootViewController: UIViewController
    private let buttonType: PrivacyButtonType
    private let purchaseService: PurchaseService?
    private let bag = DisposeBag()

    init(rootViewController: UIViewController, url: URL?, buttonType: PrivacyButtonType, purchaseService: PurchaseService? = nil) {
        self.rootViewController = rootViewController
        self.url = url
        self.buttonType = buttonType
        self.purchaseService = purchaseService
    }

    override func start() -> Observable<Void> {
        let viewController = PrivacyPolicyViewController()
        viewController.buttonTitle = buttonType == .accept ? "Accept" : "Close"
        let viewModel = PrivacyPolicyViewModel(url: url)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .fullScreen
        viewModel
            .didAccept
            .subscribe(onNext: { [weak self] _ in
            self?.purchaseService?.continueProcessingPayment()
            self?.rootViewController.dismiss(animated: true)
        })
        .disposed(by: bag)

        rootViewController.present(viewController, animated: true)

        return Observable.never()
    }
}
