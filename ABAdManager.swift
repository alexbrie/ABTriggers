//
//  ABAdManager.swift
//  ZoomedPics
//
//  Created by Alex on 02/12/15.
//  Copyright © 2015 Alex. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AppLovinSDK

class  ABAdManager : NSObject, GADInterstitialDelegate {
    // singleton
    static let shared = ABAdManager()
    
    
    var admob_interstitial: GADInterstitial!
    
    var hasAdmob: Int = 0
    var hasApplovin : Int = 0

    var shouldShowAds : Bool = true
    var admobTestDevices : [String]?
    var admobInterstitialId : String?
    
    override init(){
        super.init()
    }
    
    // prepare ads

    func  prepareAds(withAdmobInterstitialId : String) {
        DLog("prepare ads")
        
        if let has_admob = (ABRemoteConfig.shared.configDict?["AdMob"] as? Int) {
            hasAdmob = has_admob
        }
        if let has_applovin = (ABRemoteConfig.shared.configDict?["AppLovin"] as? Int) {
            hasApplovin = has_applovin
        }
        
        if hasAdmob > 0 {
            admob_interstitial = createAndLoadInterstitial(withAdmobInterstitialId)
        }
        if hasApplovin > 0 {
            ALSdk.initializeSdk()
        }
    }
    
    // triggers
    
    
    func notifyIfTriggered(triggerKey : String = ABCommonTriggerKeys.level.rawValue, delay: TimeInterval = 0, notificationName : String = "SHOW_INTERSTITIAL", userInfo: [String: Any]? = nil) {
        guard shouldShowAds else { return }
        
        if ABTriggerManager.shared.trigger(key: triggerKey)?.tryTrigger() ?? false {
            if delay > 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: userInfo)
                }
            }
            else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: userInfo)
            }
        }
    }
    
    func createAndLoadInterstitial(_ admobId : String) -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: admobId)
        interstitial.delegate = self
        let request = GADRequest()
        if let testDevices = admobTestDevices {
            request.testDevices = testDevices
        }
        interstitial.load(request)
        return interstitial
    }
    
    func showAdmob(_ ctrl : UIViewController, onResume: Bool) -> Bool {
        if admob_interstitial.isReady {
            admob_interstitial.present(fromRootViewController: ctrl)
            DLog("ADMOB!")
            return true
        }
        return false
    }
    
    func  showApplovin(_ ctrl : UIViewController, onResume: Bool) -> Bool {
        if ALInterstitialAd.isReadyForDisplay(){
            ALInterstitialAd.show()
            DLog("APPLOVIN!")
            return true
        }
        return false
    }

    
    func showAdsInController(_ ctrl : UIViewController, onResume: Bool = false) {
        var hasShownAd = false
        if hasAdmob >= hasApplovin {
            hasShownAd = showAdmob(ctrl, onResume: onResume)
        }
        
        if (hasApplovin >= hasAdmob) || (!hasShownAd && hasApplovin > 0){
            hasShownAd = showApplovin(ctrl, onResume: onResume)
        }
    }
    
    // ADMOB DELEGATE
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if ad == admob_interstitial {
            if let admob_interstitial_id = admobInterstitialId {
                admob_interstitial = createAndLoadInterstitial(admob_interstitial_id)
            }
        }
    }
}
