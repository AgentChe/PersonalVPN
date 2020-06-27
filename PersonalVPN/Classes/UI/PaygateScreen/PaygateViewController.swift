//
//  PaygateViewController.swift
//  PersonalVPN
//
//  Created by Andrey Chernyshev on 27.06.2020.
//  Copyright © 2020 org. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PaygateViewController: UIViewController {
    private enum Scene {
        case not, main, specialOffer
    }
    
    var paygateView = PaygateView()
    
    private let disposeBag = DisposeBag()
    
    private var currentScene = Scene.not {
        didSet {
            updateCloseButton()
        }
    }
    
    private let viewModel = PaygateViewModel()
    
    deinit {
        paygateView.specialOfferView.stopTimer()
    }
    
    override func loadView() {
        super.loadView()
        
        view = paygateView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCloseButton()
        addMainOptionsSelection()
        
        let retrieved = viewModel.retrieve()
        
        retrieved
            .drive(onNext: { [weak self] paygate, completed in
                guard let `self` = self, let paygate = paygate else {
                    return
                }
                
                self.paygateView.mainView.setup(paygate: paygate.main)
                
                if let specialOffer = paygate.specialOffer {
                    self.paygateView.specialOfferView.setup(paygate: specialOffer)
                }
                
                if completed {
                    self.currentScene = .main
                }
                
                self.animateShowMainContent(isLoading: !completed)
            })
            .disposed(by: disposeBag)
        
        let paygate = retrieved
            .map { $0.0 }
            .startWith(nil)
        
        paygateView
            .closeButton.rx.tap
            .withLatestFrom(paygate)
            .subscribe(onNext: { [unowned self] paygate in
                switch self.currentScene {
                case .not:
                    self.dismiss()
                case .main:
                    if paygate?.specialOffer != nil {
                        self.animateMoveToSpecialOfferView()
                        self.currentScene = .specialOffer
                    } else {
                        self.dismiss()
                    }
                case .specialOffer:
                    self.paygateView.specialOfferView.stopTimer()
                    self.dismiss()
                }
            })
            .disposed(by: disposeBag)
        
        paygateView
            .mainView
            .continueButton.rx.tap
            .subscribe(onNext: { [unowned self] productId in
                guard let productId = [self.paygateView.mainView.leftOptionView, self.paygateView.mainView.rightOptionView]
                    .first(where: { $0.isSelected })?
                    .productId
                else {
                    return
                }
                
                self.viewModel.buySubscription.accept(productId)
            })
            .disposed(by: disposeBag)
        
        paygateView
            .mainView
            .restoreButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                guard let productId = [self.paygateView.mainView.leftOptionView, self.paygateView.mainView.rightOptionView]
                    .first(where: { $0.isSelected })?
                    .productId
                else {
                    return
                }
                
                self.viewModel.restoreSubscription.accept(productId)
            })
            .disposed(by: disposeBag)
        
        paygateView
            .specialOfferView
            .continueButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let productId = self?.paygateView.specialOfferView.specialOffer?.productId else {
                    return
                }
                
                self?.viewModel.buySubscription.accept(productId)
            })
            .disposed(by: disposeBag)
        
        paygateView
            .specialOfferView
            .restoreButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let productId = self?.paygateView.specialOfferView.specialOffer?.productId else {
                    return
                }
                
                self?.viewModel.restoreSubscription.accept(productId)
            })
            .disposed(by: disposeBag)
        
        Driver
            .merge(viewModel.purchaseProcessing.asDriver(),
                   viewModel.restoreProcessing.asDriver(),
                   viewModel.retrieveCompleted.asDriver(onErrorJustReturn: true).map { !$0 })
            .drive(onNext: { [weak self] isLoading in
                self?.paygateView.mainView.continueButton.isHidden = isLoading
                self?.paygateView.mainView.restoreButton.isHidden = isLoading
                self?.paygateView.specialOfferView.continueButton.isHidden = isLoading
                self?.paygateView.specialOfferView.restoreButton.isHidden = isLoading

                isLoading ? self?.paygateView.mainView.purchasePreloaderView.startAnimating() : self?.paygateView.mainView.purchasePreloaderView.stopAnimating()
                isLoading ? self?.paygateView.specialOfferView.purchasePreloaderView.startAnimating() : self?.paygateView.specialOfferView.purchasePreloaderView.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .error
            .drive(onNext: { [weak self] error in
                self?.paygateView.errorBanner.show(with: error)
            })
            .disposed(by: disposeBag)
        
        paygateView
            .errorBanner
            .tapForHide
            .subscribe(onNext: { [weak self] in
                self?.paygateView.errorBanner.hide()
            })
            .disposed(by: disposeBag)
        
        Signal
            .merge(viewModel.purchaseCompleted,
                   viewModel.restoredCompleted)
            .emit(onNext: { [weak self] result in
                self?.dismiss()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make

extension PaygateViewController {
    static func make() -> PaygateViewController {
        let vc = PaygateViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private

private extension PaygateViewController {
    func addMainOptionsSelection() {
        let leftOptionTapGesture = UITapGestureRecognizer()
        paygateView.mainView.leftOptionView.addGestureRecognizer(leftOptionTapGesture)
        
        leftOptionTapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                if let productId = self.paygateView.mainView.leftOptionView.productId {
                    self.viewModel.buySubscription.accept(productId)
                }
                
                guard !self.paygateView.mainView.leftOptionView.isSelected else {
                    return
                }
                
                self.paygateView.mainView.leftOptionView.isSelected = true
                self.paygateView.mainView.rightOptionView.isSelected = false
            })
            .disposed(by: disposeBag)
        
        let rightOptionTapGesture = UITapGestureRecognizer()
        paygateView.mainView.rightOptionView.addGestureRecognizer(rightOptionTapGesture)
        
        rightOptionTapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                if let productId = self.paygateView.mainView.rightOptionView.productId {
                    self.viewModel.buySubscription.accept(productId)
                }
                
                guard !self.paygateView.mainView.rightOptionView.isSelected else {
                    return
                }
                
                self.paygateView.mainView.leftOptionView.isSelected = false
                self.paygateView.mainView.rightOptionView.isSelected = true
            })
            .disposed(by: disposeBag)
    }
    
    func animateShowMainContent(isLoading: Bool) {
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.paygateView.mainView.greetingLabel.alpha = 1
            self?.paygateView.mainView.textLabel.alpha = 1
            self?.paygateView.mainView.lockImageView.alpha = 1
            self?.paygateView.mainView.termsOfferLabel.alpha = 1
            self?.paygateView.mainView.leftOptionView.alpha = 1
            self?.paygateView.mainView.rightOptionView.alpha = 1
            self?.paygateView.mainView.restoreButton.alpha = 1
        })
    }
    
    func animateMoveToSpecialOfferView() {
        paygateView.specialOfferView.isHidden = false
        paygateView.specialOfferView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.paygateView.mainView.alpha = 0
            self?.paygateView.specialOfferView.alpha = 1
        }, completion: { [weak self] _ in
            self?.paygateView.specialOfferView.startTimer()
        })
    }
    
    func updateCloseButton() {
        switch currentScene {
        case .not, .main:
            paygateView.closeButton.setImage(UIImage(named: "paygate_main_close"), for: .normal)
        case .specialOffer:
            paygateView.closeButton.setImage(UIImage(named: "paygate_special_offer_close"), for: .normal)
        }
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
}
