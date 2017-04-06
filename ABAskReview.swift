//
//  ABAskReview.swift
//
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit

class ABAskReview: NSObject {

    class func markRatedApp() {
        UserDefaults.standard.set(true, forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()
    }
    
    class func rateAppInStore(_ appId: String) {
        self.markRatedApp()
        UIApplication.shared.openURL(URL(string: appReviewURL(appId))!)
    }
    
    class func appReviewURL(_ appId : String) -> String {
        var templateReviewURL = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appId)"
    
        if UIDevice.current.systemVersion.compare("7.0", options: NSString.CompareOptions.numeric, range: nil, locale: nil) != ComparisonResult.orderedAscending {
            templateReviewURL = "itms-apps://itunes.apple.com/app/id\(appId)"
        }
        return templateReviewURL
    }
    
    class func hasRatedApp() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasRatedApp")
    }
    
    class func clearRatedAppAfterUpdate() {
        let lastAppVersion = UserDefaults.standard.string(forKey: "lastAppVersion")
        let currentAppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    
        if currentAppVersion != nil  && lastAppVersion != nil && currentAppVersion==lastAppVersion {
            return
        }
        else {
            UserDefaults.standard.set(currentAppVersion, forKey:"lastAppVersion")
            UserDefaults.standard.synchronize()
            self.clearRatedApp()
        }
    }
    
    class func clearRatedApp() {
        //Mark as rated
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()
    }

}
