//
// Created by Anton Serov on 12.11.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import RxSwift

class PaygateCoordinator: BaseCoordinator<Void> {
    private let rootViewController: UIViewController
    private let bag = DisposeBag()

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    override func start() -> Observable<Void> {
        let container = AppContainer.sharedContainer.container
        let viewController = PaygateViewController()
        let viewModel = PaygateViewModel(
            storage: UserDefaultsStorage.shared,
            payment: container.resolve(PurchaseService.self)!,
            client: ClientContainer.sharedContainer.container.resolve(Client.self)! as! PaymentsClient
        )
        viewModel
            .handleSubscribe
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
            })
            .disposed(by: bag)
        viewModel
            .handleRestore
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
            })
            .disposed(by: bag)
        viewModel
            .dismiss
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.rootViewController.dismiss(animated: true)
            })
            .disposed(by: bag)
        viewController.viewModel = viewModel
        rootViewController.present(viewController, animated: true)
        return Observable.never()
    }
}
