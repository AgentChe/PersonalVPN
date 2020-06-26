import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    var viewModel: MainViewModel! {
        didSet {
            viewModel.state?
                .subscribe(onNext: { state in
                    self.mainView.startButton.setTitle(state.state, for: .normal)
                    self.mainView.received = state.data
                    self.mainView.connectedDate = state.time
                })
                .disposed(by: bag)
            moreButton.rx.tap.bind(to: viewModel.selectMore).disposed(by: bag)
            locationButton.rx.tap.bind(to: viewModel.selectLocation).disposed(by: bag)
            if let c = viewModel.changeState {
                mainView.startButton.rx.tap.bind(to: c).disposed(by: bag)
            }
            if let didAppear = viewModel.firstAppear {
                rx.viewDidAppear.bind(to: didAppear).disposed(by: bag)
            }
            viewModel.alertMessage
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] in self?.presentAlert(message: $0) })
                .disposed(by: bag)
        }
    }

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "more"), for: .normal)
        button.tintColor = .black
        return button
    }()

    private lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "location"), for: .normal)
        button.tintColor = .black
        return button
    }()

    private lazy var mainView: MainView = {
        var view = MainView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        view.addSubview(mainView)
        view.addSubview(moreButton)
        view.addSubview(locationButton)
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        moreButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14.0).isActive = true
        moreButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24.0).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        locationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14.0).isActive = true
        locationButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 34.0).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        locationButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

