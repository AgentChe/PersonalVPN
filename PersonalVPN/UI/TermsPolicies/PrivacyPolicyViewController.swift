import Foundation
import UIKit
import WebKit
import RxSwift
import RxCocoa

class PrivacyPolicyViewController: UIViewController {
    var viewModel: PrivacyPolicyViewModel!
    var buttonTitle: String = "Accept"

    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isOpaque = false
        view.navigationDelegate = self
        return view
    }()

    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 28.0
        button.backgroundColor = .white
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 22)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    lazy var gradientLayer: CALayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        return gradient
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        if let url = viewModel.url {
            webView.load(URLRequest(url: url))
        }
        acceptButton.rx.tap.bind(to: viewModel.accept).disposed(by: bag)
        view.backgroundColor = .black
        view.addSubview(webView)
        view.addSubview(acceptButton)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: acceptButton.topAnchor).isActive = true
        acceptButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 36.0).isActive = true
        acceptButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -36.0).isActive = true
        acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -36.0).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 56.0).isActive = true

        view.layer.addSublayer(gradientLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let gradientFrame = CGRect(x: 0, y: acceptButton.frame.minY - 100, width: view.frame.width, height: 100)
        gradientLayer.frame = gradientFrame
    }
}

extension PrivacyPolicyViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}
