import RxSwift
import RxCocoa

/**
 ViewController view states
*/
public enum ViewControllerViewState: Equatable {
    case viewWillAppear
    case viewDidAppear
    case viewWillDisappear
    case viewDidDisappear
    case viewDidLoad
    case viewDidLayoutSubviews
}

/**
 UIViewController view state changes.
 Emits a Bool value indicating whether the change was animated or not
 */

extension RxSwift.Reactive where Base: UIViewController {
    public var viewDidLoad: Observable<Void> {
        methodInvoked(#selector(UIViewController.viewDidLoad)).map { _ in }
    }

    public var viewDidLayoutSubviews: Observable<Void> {
        methodInvoked(#selector(UIViewController.viewDidLayoutSubviews)).map { _ in }
    }

    public var viewWillAppear: Observable<Bool> {
        methodInvoked(#selector(UIViewController.viewWillAppear)).map { $0.first as? Bool ?? false }
    }

    public var viewDidAppear: Observable<Bool> {
        methodInvoked(#selector(UIViewController.viewDidAppear)).map { $0.first as? Bool ?? false }
    }

    public var viewWillDisappear: Observable<Bool> {
        methodInvoked(#selector(UIViewController.viewWillDisappear)).map { $0.first as? Bool ?? false }
    }

    public var viewDidDisappear: Observable<Bool> {
        methodInvoked(#selector(UIViewController.viewDidDisappear)).map { $0.first as? Bool ?? false }
    }

    /**
     Observable sequence of the view controller's view state
     
     This gives you an observable sequence of all possible states.
     
     - returns: Observable sequence of AppStates
     */
    public var viewState: Observable<ViewControllerViewState> {
        Observable.of(
                viewDidLoad.map { _ in
                    ViewControllerViewState.viewDidLoad
                },
                viewDidLayoutSubviews.map { _ in
                    ViewControllerViewState.viewDidLayoutSubviews
                },
                viewWillAppear.map { _ in
                    ViewControllerViewState.viewWillAppear
                },
                viewDidAppear.map { _ in
                    ViewControllerViewState.viewDidAppear
                },
                viewWillDisappear.map { _ in
                    ViewControllerViewState.viewWillDisappear
                },
                viewDidDisappear.map { _ in
                    ViewControllerViewState.viewDidDisappear
                }
            )
            .merge()
    }
}