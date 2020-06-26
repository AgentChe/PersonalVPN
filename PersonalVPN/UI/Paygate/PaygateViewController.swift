//
// Created by Anton Serov on 12.11.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PaygateViewController: UIViewController {
    var viewModel: PaygateViewModel! {
        didSet {
            viewModel.alertMessage
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] in self?.presentAlert(message: $0) })
                .disposed(by: disposeBag)
            viewModel.activity
                .asObservable()
                .observeOn(MainScheduler.instance)
                .bind(to: activityIndicator.rx.isAnimating)
                .disposed(by: disposeBag)
            subscribeButton.rx.tap.bind(to: viewModel.subscribe).disposed(by: disposeBag)
            restoreButton.rx.tap.bind(to: viewModel.restore).disposed(by: disposeBag)
            viewModel
                .paymentDetails
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] info in
                    if let caption = info?.caption, let buttonTitle = info?.button, let heading = info?.heading {
                        self?.priceLabel.text = caption
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineHeightMultiple = 0.81
                        self?.titleLabel.attributedText = NSMutableAttributedString(string: heading, attributes: [NSAttributedString.Key.kern: -1.12, NSAttributedString.Key.paragraphStyle: paragraphStyle])
                        self?.subscribeButton.setTitle(buttonTitle, for: .normal)
                        self?.priceActivityIndicator.stopAnimating()
                        self?.payActivityIndicator.stopAnimating()
                    }
                    else {
                        self?.priceActivityIndicator.startAnimating()
                        self?.payActivityIndicator.startAnimating()
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.tintColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
        button.alpha = 0
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.color = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var priceActivityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.color = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var payActivityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.color = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        var view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textColor = UIColor(red: 0.071, green: 0.071, blue: 0.09, alpha: 1)
        view.font = UIFont(name: "Poppins-Bold", size: 28)
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.81
        view.textAlignment = .center
        view.attributedText = NSMutableAttributedString(string: "Start your free 3-day trial. No commitment. Cancel anytime.", attributes: [NSAttributedString.Key.kern: -1.12, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return view
    }()

    private lazy var fastConnection: VerticalButton = {
        let button = VerticalButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle("Fast\nconnection", for: .normal)
        button.setImage(UIImage(named: "IconPaygate_1"), for: .normal)
        button.isUserInteractionEnabled = false
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    private lazy var encryption: VerticalButton = {
        let button = VerticalButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle("Top-notch\nencryption", for: .normal)
        button.setImage(UIImage(named: "IconPaygate_2"), for: .normal)
        button.isUserInteractionEnabled = false
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    private lazy var unlimitedTraffic: VerticalButton = {
        let button = VerticalButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle("Unlimited\ntraffic", for: .normal)
        button.setImage(UIImage(named: "IconPaygate_3"), for: .normal)
        button.isUserInteractionEnabled = false
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    private lazy var variousLocations: VerticalButton = {
        let button = VerticalButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle("Various\nlocations", for: .normal)
        button.setImage(UIImage(named: "IconPaygate_4"), for: .normal)
        button.isUserInteractionEnabled = false
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    private lazy var featuresStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [fastConnection, encryption, unlimitedTraffic, variousLocations])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.backgroundColor = .clear
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var priceLabel: UILabel = {
        var view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        view.font = UIFont(name: "Poppins-Medium", size: 20)
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textAlignment = .center
        return view
    }()

    private lazy var subscribeButton: UIButton = {
        var view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.9
        view.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.backgroundColor = UIColor(red: 1, green: 0.847, blue: 0.725, alpha: 1)
        view.layer.cornerRadius = 38
        view.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        view.titleLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        return view
    }()

    private lazy var restoreButton: UIButton = {
        var view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Restore Purchases", for: .normal)
        view.tintColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        view.titleLabel?.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1)
        view.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        view.titleLabel?.textAlignment = .center
        return view
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceLabel, subscribeButton, restoreButton])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.backgroundColor = .clear
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        initialize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            UIView.animate(withDuration: 0.25) { [weak self] () -> Void in
                self?.closeButton.alpha = 1
            }
        }
    }

    @objc func close() {
        dismiss(animated: true)
    }

    private func initialize() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.969, blue: 0.965, alpha: 1)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(featuresStack)
        view.addSubview(buttonsStackView)
        view.addSubview(activityIndicator)
        view.addSubview(priceActivityIndicator)
        view.addSubview(payActivityIndicator)
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0).isActive = true
        closeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 37.0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 37.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 92).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        featuresStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 37).isActive = true
        featuresStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        featuresStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        buttonsStackView.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 140).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 38).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38).isActive = true
        subscribeButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        priceActivityIndicator.centerXAnchor.constraint(equalTo: priceLabel.centerXAnchor).isActive = true
        priceActivityIndicator.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
        payActivityIndicator.centerXAnchor.constraint(equalTo: subscribeButton.centerXAnchor).isActive = true
        payActivityIndicator.centerYAnchor.constraint(equalTo: subscribeButton.centerYAnchor).isActive = true
    }

    class VerticalButton: UIButton {

        override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
            let imageFrame = imageRect(forContentRect: contentRect)
            let titleMinY = imageFrame.maxY + interItemSpacing
            return CGRect(x: contentRect.minX, y: titleMinY, width: contentRect.width, height: titleHeight)
        }

        override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
            let imageRect = super.imageRect(forContentRect: contentRect)
            let imageX = (contentRect.width - imageRect.width) / 2
            let contentMinY = (contentRect.height - contentHeight) / 2
            return CGRect(x: imageX, y: contentMinY, width: imageRect.width, height: imageRect.height)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupView()
        }

        private func setupView() {
            titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 13)
            titleLabel?.textAlignment = .center
            titleLabel?.textColor = UIColor(red: 0.071, green: 0.071, blue: 0.09, alpha: 1)
            titleLabel?.numberOfLines = 0
            titleLabel?.lineBreakMode = .byWordWrapping
            setTitleColor(UIColor(red: 0.071, green: 0.071, blue: 0.09, alpha: 1), for: .normal)
        }

        private let interItemSpacing = CGFloat(10.0)
        private var contentHeight: CGFloat {
            titleHeight + interItemSpacing + imageHeight
        }
        private var titleHeight: CGFloat {
            title(for: .normal) != nil ? 36 : 0
        }
        private var imageHeight: CGFloat {
            guard let image = image(for: .normal) else { return 0 }
            return image.size.height
        }
    }
}
