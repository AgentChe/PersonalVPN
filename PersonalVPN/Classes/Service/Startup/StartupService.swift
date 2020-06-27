import Foundation
import os
import Amplitude_iOS
import RxSwift

class StartupService {
    let client: CheckClient & VpnClient
    var storage: Storage
    var attributionService: AttributionService
    
    private var purchaseValidateDisposable: Disposable?

    init(client: CheckClient & VpnClient, storage: Storage, attributionService: AttributionService) {
        self.client = client
        self.storage = storage
        self.attributionService = attributionService
        self.storage.addObserver(self)
    }

    func coldStart() {
        Amplitude.instance().initializeApiKey(App.Amplitude.ApiKey)
        
        if storage.isFirstLaunch {
            Amplitude.instance().setUserProperties(App.Amplitude.firstLaunchParams(for: AttributionService.idfa))
            Amplitude.instance().logEvent(App.Amplitude.FirstLaunchEvent, withEventProperties: App.Amplitude.EventParams)
            
            attributionService.register { [weak self] (params, attribution) in
                if attribution {
                    Amplitude.instance().setUserProperties(params)
                    Amplitude.instance().logEvent(App.Amplitude.SearchAdsInstall, withEventProperties: App.Amplitude.EventParams)
                }
                
                self?.storage.isFirstLaunch = false
            }
        }

        let completion: (CheckTokenResponse?) -> () = { [weak self] r in
            if let r = r {
                NetworkConfiguration.userToken = r.userToken
                self?.storage.activeSubscription = r.activeSubscription
                self?.storage.needPayment = r.needPayment
                self?.storage.userId = r.userId
            }
            
            self?.loadNecessaryInfo()
        }
        
        client.checkToken { [weak self] response, error in
            DispatchQueue.main.async {
                if let _ = error {
                    self?.requestToken(completion)
                    return
                }
                else {
                    self?.attributionService.setUserInfo(full: false) { }
                }
                
                completion(response)
            }
        }
    }

    private func requestToken(_ completion: @escaping (CheckTokenResponse?) -> ()) {
        purchaseValidateDisposable?.dispose()
        
        purchaseValidateDisposable = PurchaseService
            .paymentValidate()
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { response in
                completion(response)
            })
    }

    private func loadNecessaryInfo() {
        requestVpnList()
    }

    private func requestVpnList() {
        client.list { [weak self] servers, error in
            if let error = error {
                os_log("Fail to get list of vpn with error %s", error.localizedDescription)
                print("Fail to get list of vpn with error \(error)")
                return
            }
            self?.storage.vpnList = servers
            if self?.storage.selectedVpn == nil {
                self?.storage.selectedVpn = servers?.first
            }
        }
    }
}

extension StartupService: StorageObserver {
    func storage(_ storage: Storage, changedKey: String, oldValue: Any?, newValue: Any?) {
        if changedKey == "userToken" && newValue != nil {
            if let nv = newValue as? String, let ov = oldValue as? String {
                if nv != ov {
                    attributionService.setUserInfo(full: true) {
                        self.attributionService.addAdsInfo {  }
                    }
                }
            }
            else if let _ = newValue as? String {
                attributionService.setUserInfo(full: true) {
                    self.attributionService.addAdsInfo {  }
                }
            }
        }

        if changedKey == "userId" && newValue != nil {
            if let nv = newValue as? String, let ov = oldValue as? String {
                if nv != ov {
                    Amplitude.instance().setUserId(App.Amplitude.userId(for: nv))
                    Amplitude.instance().logEvent(App.Amplitude.UserIDSynced, withEventProperties: App.Amplitude.EventParams)
                }
            } else if let nv = newValue as? String, oldValue == nil {
                Amplitude.instance().setUserId(App.Amplitude.userId(for: nv))
                Amplitude.instance().logEvent(App.Amplitude.UserIDSynced, withEventProperties: App.Amplitude.EventParams)
            }
        }
    }
}
