//
// Created by Anton Serov on 12.11.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import RxSwift

class PaygateCoordinator: BaseCoordinator<Void> {
    private weak var rootViewController: UIViewController?
    private let bag = DisposeBag()

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    override func start() -> Observable<Void> {
        let viewController = PaygateViewController.make()
        
        rootViewController?.present(viewController, animated: true)
        
        return Observable.never()
    }
}
