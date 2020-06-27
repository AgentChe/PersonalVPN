//
// Created by Anton Serov on 20.12.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OnboardViewController: UIViewController {
    var viewModel: OnboardViewModelProtocol? {
        didSet {
            containerView.viewModel = viewModel
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundImage.layer.sublayers?.forEach { layer in layer.removeFromSuperlayer() }

        let layer0 = CALayer()
        layer0.backgroundColor = UIColor(red: 0.886, green: 0.886, blue: 0.945, alpha: 0.12).cgColor
        layer0.bounds = view.bounds
        layer0.position = view.center
        backgroundImage.layer.addSublayer(layer0)

        let layer1 = CALayer()
        layer1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        layer1.bounds = view.bounds
        layer1.position = view.center
        if let compositingFilter = CIFilter(name: "CIAdditionCompositing") {
            layer1.compositingFilter = compositingFilter
        }
        backgroundImage.layer.addSublayer(layer1)
        backgroundImage.layer.cornerRadius = 8
    }

    private lazy var containerView: OnboardView = {
        let view = OnboardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var onboardViewConstraints: [NSLayoutConstraint] = {
        var constraints = [NSLayoutConstraint]()
        constraints.append(containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(containerView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        return constraints
    }()

    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(image: backgroundBlurImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let layer = CALayer()
        layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1.74, b: 0, c: 0, d: 1.13, tx: -0.37, ty: -0.06))
        layer.bounds = view.bounds
        layer.position = view.center
        if let compositingFilter = CIFilter(name: "CIAdditionCompositing") {
            layer.compositingFilter = compositingFilter
        }
        imageView.layer.addSublayer(layer)
        return imageView
    }()

    private lazy var backgroundImageConstraints: [NSLayoutConstraint] = {
        var constraints = [NSLayoutConstraint]()
        constraints.append(backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(backgroundImage.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        return constraints
    }()

    private lazy var backgroundBlurImage: UIImage = {
        let image = UIImage(named: "bg_onboarding")!
        let filter = CIFilter(name: "CIDiscBlur", parameters: ["inputImage": CIImage(image: image)!, "inputRadius": 70])!
        return UIImage(ciImage: filter.outputImage!)
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backgroundViewConstraints: [NSLayoutConstraint] = {
        var constraints = [NSLayoutConstraint]()
        constraints.append(backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(backgroundView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        return constraints
    }()

    private func setupView() {
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate(backgroundImageConstraints)
//        view.addSubview(backgroundView)
//        NSLayoutConstraint.activate(backgroundViewConstraints)
        view.addSubview(containerView)
        NSLayoutConstraint.activate(onboardViewConstraints)
    }
}

private class OnboardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    var viewModel: OnboardViewModelProtocol? {
        didSet {
            if let vm = viewModel as? OnboardViewModel {
                button.rx.tap.bind(to: vm.accept).disposed(by: bag)
            }
            updateView()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if buttonLayer == nil {
            let shadowPath0 = UIBezierPath(roundedRect: button.bounds, cornerRadius: 8)
            let buttonLayer = CALayer()
            buttonLayer.shadowPath = shadowPath0.cgPath
            buttonLayer.shadowColor = UIColor(red: 0.651, green: 0.827, blue: 0.792, alpha: 0.6).cgColor
            buttonLayer.shadowOpacity = 1
            buttonLayer.shadowRadius = 6
            buttonLayer.shadowOffset = CGSize(width: 0, height: 0)
            button.layer.addSublayer(buttonLayer)
        }
    }

    private func setupView() {
        addSubview(imageView)
        addSubview(label)
        addSubview(textView)
        addSubview(button)
        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(labelConstraints)
        NSLayoutConstraint.activate(textViewConstraints)
        NSLayoutConstraint.activate(buttonConstraints)
    }

    private func updateView() {
        imageView.image = UIImage(named: viewModel?.imageName ?? "")
        label.text = viewModel?.welcomeText ?? ""
        button.setTitle(viewModel?.acceptText, for: .normal)
    }

    private var termsAndPrivacyText: NSAttributedString {
        let text = NSMutableAttributedString(string: String(format: viewModel?.privacyAndTermsFormat ?? "", arguments: [viewModel?.privacyURL.title ?? "", viewModel?.termsURL.title ?? ""]))
        if let termsRange = text.string.range(of: viewModel?.termsURL.title ?? "!@#"), 
           let privacyRange = text.string.range(of: viewModel?.privacyURL.title ?? "!@#"), 
           let termsURL = viewModel?.termsURL.url,
           let privacyURL = viewModel?.privacyURL.url {
            text.setAttributes([NSAttributedString.Key.link : termsURL], range: NSRange(termsRange, in: text.string))
            text.setAttributes([NSAttributedString.Key.link : privacyURL], range: NSRange(privacyRange, in: text.string))
        }
        return text
    }

    private enum Layout {
        enum ImageView {
            static let Top: CGFloat = 122
            static let Height: CGFloat = 180
            static let Width: CGFloat = 180
        }

        enum Label {
            static let Leading: CGFloat = 54
            static let Trailing: CGFloat = -54
            static let Top: CGFloat = 38
            static let Bottom: CGFloat = -32
        }

        enum TextView {
            static let Leading: CGFloat = 32
            static let Trailing: CGFloat = -32
            static let Top: CGFloat = 32
            static let Bottom: CGFloat = -100
            static let Height: CGFloat = 84
        }

        enum Button {
            static let Leading: CGFloat = 25
            static let Trailing: CGFloat = -25
            static let Top: CGFloat = 100
            static let Bottom: CGFloat = -80
        }
    }

    private let bag = DisposeBag()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var imageViewConstraints: [NSLayoutConstraint] = {
        var constraints = [NSLayoutConstraint]()
        constraints.append(imageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(imageView.topAnchor.constraint(equalTo: topAnchor, constant:Layout.ImageView.Top))
        constraints.append(imageView.heightAnchor.constraint(equalToConstant: Layout.ImageView.Height))
        constraints.append(imageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.Width))
        return constraints
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "Barlow-SemiBold", size: 40)!
        label.textColor = UIColor(red: 0.925, green: 0.925, blue: 0.961, alpha: 1)
        label.font = UIFont(name: "Barlow-SemiBold", size: 40)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        label.textAlignment = .center
        label.attributedText = NSMutableAttributedString(string: "Welcome to  the AppName", attributes: [NSAttributedString.Key.kern: 0.8, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }()

    private lazy var labelConstraints: [NSLayoutConstraint] = {
        var constraints = [NSLayoutConstraint]()
        constraints.append(label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.Label.Leading))
        constraints.append(label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.Label.Trailing))
        constraints.append(label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant:Layout.Label.Top))
        constraints.append(label.bottomAnchor.constraint(equalTo: textView.topAnchor, constant:Layout.Label.Bottom))
        return constraints
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.font = UIFont(name: "Barlow-Regular", size: 22)
        return textView
    }()

    private lazy var textViewConstraints: [NSLayoutConstraint] = {
        var constraints = [NSLayoutConstraint]()
        constraints.append(textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.TextView.Leading))
        constraints.append(textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.TextView.Trailing))
        constraints.append(textView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: Layout.TextView.Bottom))
        constraints.append(textView.heightAnchor.constraint(equalToConstant: Layout.TextView.Height))
        return constraints
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = false
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        let attributedText = NSMutableAttributedString(string: "Accept and Continue", attributes: [NSAttributedString.Key.kern: 1.32, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        button.setAttributedTitle(attributedText, for: .normal)
        return button
    }()

    private var buttonLayer: CALayer?

    private lazy var buttonConstraints: [NSLayoutConstraint] = {
        var constraints = [NSLayoutConstraint]()
        constraints.append(button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.Button.Leading))
        constraints.append(button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.Button.Trailing))
        constraints.append(button.bottomAnchor.constraint(equalTo: bottomAnchor, constant:Layout.Button.Bottom))
        return constraints
    }()
}