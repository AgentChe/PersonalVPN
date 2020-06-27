//
//  PaygateSpecialOfferView.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 12/06/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import UIKit

final class PaygateSpecialOfferView: UIView {
    lazy var restoreButton = makeRestoreButton()
    lazy var iconImageView = makeIconImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var textLabel = makeTextLabel()
    lazy var leftTimeLabel = makeTimeLabel()
    lazy var rightTimeLabel = makeTimeLabel()
    lazy var delimeterTimeLabel = makeTimeDelimeterLabel()
    lazy var priceLabel = makePriceLabel()
    lazy var continueButton = makeContinueButton()
    lazy var lockImageView = makeLockIconView()
    lazy var termsOfferLabel = makeTermsOfferLabel()
    lazy var purchasePreloaderView = makePreloaderView()
    
    var timer: Timer?
    
    private(set) var specialOffer: PaygateSpecialOffer?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .black
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(paygate: PaygateSpecialOffer) {
        self.specialOffer = paygate
        
        titleLabel.text = paygate.title
        subTitleLabel.text = paygate.subTitle
        textLabel.text = paygate.text
        continueButton.setTitle(paygate.button, for: .normal)
        termsOfferLabel.text = paygate.subButton
        restoreButton.setAttributedTitle(paygate.restore?.attributed(with: TextAttributes()
            .letterSpacing(-0.12.scale)
            .textColor(UIColor.white.withAlphaComponent(0.5))),
                                         for: .normal)
        
        let timeComponents = paygate.time?.split(separator: ":")
        leftTimeLabel.text = String(timeComponents?.first ?? "0")
        rightTimeLabel.text = String(timeComponents?.last ?? "0")
        
        setupPrice(paygate: paygate)
    }
    
    func startTimer() {
        guard timer == nil else {
            return
        }
        
        guard let originalTime = specialOffer?.time else {
            leftTimeLabel.text = "0"
            rightTimeLabel.text = "0"
            
            return
        }
        
        let originalTimeComponents = originalTime.split(separator: ":")
        let originalMinutes = Int(String(originalTimeComponents.first ?? "0")) ?? 0
        let originalSeconds = Int(String(originalTimeComponents.last ?? "0")) ?? 0
        
        let totalSeconds = originalMinutes * 60 + originalSeconds
        
        var secondsPassed = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let `self` = self else {
                return
            }
            
            secondsPassed += 1
            
            let left = totalSeconds - secondsPassed
            
            let leftMinutes = (left % 3600) / 60
            let leftSeconds = (left % 3600) % 60
            
            DispatchQueue.main.async { [weak self] in
                var leftMinutesString = String(leftMinutes)
                if leftMinutesString.count == 1 {
                    leftMinutesString = "0" + leftMinutesString
                }
                self?.leftTimeLabel.text = leftMinutesString
                
                var leftSecondsString = String(leftSeconds)
                if leftSecondsString.count == 1 {
                    leftSecondsString = "0" + leftSecondsString
                }
                self?.rightTimeLabel.text = leftSecondsString
            }
            
            if left <= 0 {
                self.stopTimer()
                
                return
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: Private

private extension PaygateSpecialOfferView {
    func setupPrice(paygate: PaygateSpecialOffer) {
        let priceAttrs = NSMutableAttributedString()
        
        if let oldPrice = paygate.oldPrice {
            priceAttrs.append(oldPrice.attributed(with: TextAttributes()
                .font(Font.Poppins.regular(size: 17.scale))
                .textColor(.white)
                .strikethroughStyle(.single)))
            priceAttrs.append(NSAttributedString(string: " "))
        }
        
        if let currentPrice = paygate.price {
            priceAttrs.append(currentPrice.attributed(with: TextAttributes()
                .font(Font.Poppins.bold(size: 17.scale))
                .textColor(.white)))
        }
        
        priceLabel.attributedText = priceAttrs
    }
}

// MARK: Make constraints

private extension PaygateSpecialOfferView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            restoreButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 41.scale : 31.scale),
            restoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            restoreButton.heightAnchor.constraint(equalToConstant: 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 64.scale),
            iconImageView.heightAnchor.constraint(equalToConstant: 64.scale),
            iconImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 184.scale : 135.scale),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 15.scale),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30.scale),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            delimeterTimeLabel.centerYAnchor.constraint(equalTo: leftTimeLabel.centerYAnchor),
            delimeterTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            leftTimeLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 70.scale : 20.scale),
            leftTimeLabel.trailingAnchor.constraint(equalTo: delimeterTimeLabel.leadingAnchor, constant: -8.scale),
            leftTimeLabel.widthAnchor.constraint(equalToConstant: 66.scale)
        ])
        
        NSLayoutConstraint.activate([
            rightTimeLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 70.scale : 20.scale),
            rightTimeLabel.leadingAnchor.constraint(equalTo: delimeterTimeLabel.trailingAnchor, constant: 8.scale),
            rightTimeLabel.widthAnchor.constraint(equalToConstant: 66.scale)
        ])
        
        NSLayoutConstraint.activate([
            lockImageView.widthAnchor.constraint(equalToConstant: 12.scale),
            lockImageView.heightAnchor.constraint(equalToConstant: 16.scale),
            lockImageView.trailingAnchor.constraint(equalTo: termsOfferLabel.leadingAnchor, constant: -10.scale),
            lockImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -49.scale : -10.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsOfferLabel.centerYAnchor.constraint(equalTo: lockImageView.centerYAnchor),
            termsOfferLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -86.scale : -64.scale),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -160.scale : -138.scale),
            priceLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            purchasePreloaderView.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
            purchasePreloaderView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

// MARK: Lazy initialization

private extension PaygateSpecialOfferView {
    func makeRestoreButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = Font.Poppins.regular(size: 18.scale)
        addSubview(view)
        return view
    }
    
    func makeIconImageView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "paygate_special_offer_icon")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.textAlignment = .center
        view.font = Font.Poppins.bold(size: 80.scale)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = Font.OpenSans.bold(size: 22.scale)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = Font.Poppins.regular(size: 17.scale)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTimeLabel() -> PaddingLabel {
        let view = PaddingLabel()
        view.topInset = 16.scale
        view.bottomInset = 16.scale
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2.scale
        view.layer.cornerRadius = 8.scale
        view.font = Font.Poppins.bold(size: 28.scale)
        view.textColor = .white
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTimeDelimeterLabel() -> UILabel {
        let view = UILabel()
        view.text = ":"
        view.font = Font.Poppins.bold(size: 30.scale)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePriceLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = UIColor(red: 243 / 255, green: 160 / 255, blue: 65 / 255, alpha: 1)
        view.layer.cornerRadius = 28.scale
        view.titleLabel?.font = Font.Poppins.semibold(size: 17.scale)
        view.setTitleColor(.black, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLockIconView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "paygate_special_offer_lock")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTermsOfferLabel() -> UILabel {
        let view = UILabel()
        view.font = Font.OpenSans.semibold(size: 13.scale)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloaderView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
