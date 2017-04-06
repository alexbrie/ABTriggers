//
//  ABRemoteConfig.swift
//  ZoomedGame
//
//  Created by Alex on 03/06/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit


func DLog(_ message: String, function: String = #function) {
    #if DEBUG
        NSLog("\(function): \(message)")
    #endif
}


class ABRemoteConfig: NSObject {
    // singleton
    static let shared = ABRemoteConfig()

    var configDict : [String: AnyObject]?
    
    
    override init() {
        super.init()
        self.configDict = [:]
        initNBX()
    }
    
    func initNBX() {
        ABAskReview.clearRatedAppAfterUpdate()
    }
    

    func setupWithCompletionOrDefaultToLocal(configFileName : String, configRemoteURL : String, _ completion:@escaping ()->Void) {
        let urlConfigRemoteURL  = URL(string: configRemoteURL) ?? URL(string: "http://google.com")!
        ABRemoteConfig.downloadFileAsync(urlConfigRemoteURL, doOverwrite: true) { (path, error) in
            if (error != nil) {
                let bundle_url = Bundle.main.url(forResource: configFileName, withExtension: "json")
                let pathRes = Bundle.main.path(forResource: configFileName, ofType: "json")

                // only copy to the documents folders the first time, not afterwards
                self.configDict = self.configFromFileAtPath(pathRes!)
                ABRemoteConfig.downloadFileAsync(bundle_url!, doOverwrite: false) { (path, error) in
                    self.configDict = self.configFromFileAtPath(path)
                    completion()
                }
            }
            else {
                self.configDict = self.configFromFileAtPath(path)
                completion()
            }
        }
    }
    /*
    func setupWithCompletion(configFileName : String, configRemoteURL : String, _ completion:@escaping ()->Void) {
        let urlConfigRemoteURL  = URL(string: configRemoteURL) ?? URL(string: "http://google.com")!
        let bundle_url = Bundle.main.url(forResource: configFileName, withExtension: "json")
        let pathRes = Bundle.main.path(forResource: configFileName, ofType: "json")
        
        if bundle_url == nil {
            self.configDict = [:]
            ABRemoteConfig.downloadFileAsync(configRemoteURL, doOverwrite: true) { (path, error) in
                self.configDict = self.configFromFileAtPath(path)
                completion()
            }
        }
        else {
            // only copy to the documents folders the first time, not afterwards
            self.configDict = self.configFromFileAtPath(pathRes!)
            ABRemoteConfig.downloadFileAsync(bundle_url!, doOverwrite: false) { (path, error) in
                self.configDict = self.configFromFileAtPath(path)
                // regardless of having copied it or not, let's try to update it from the web
                ABRemoteConfig.downloadFileAsync(self.configRemoteURL(), doOverwrite: true) { (path, error) in
                    self.configDict = self.configFromFileAtPath(path)
                    completion()
                }
            }
        }
    }
    */
    class func downloadFileAsync(_ url: URL, doOverwrite: Bool, completion:@escaping (_ path:String, _ error:Error?) -> Void) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        if !doOverwrite && FileManager().fileExists(atPath: destinationUrl.path) {
            DLog("file already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else {
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if (error == nil && data != nil) {
                    if let response = response as? HTTPURLResponse {
                        DLog("response=\(response)")
                        if response.statusCode == 200 {
                            if (try? DLog("READ FROM WEB \(JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments))")) != nil {
                                if (try? data!.write(to: destinationUrl, options: [.atomic])) != nil {
                                    DLog("file saved [\(destinationUrl.path)]")
                                    completion(destinationUrl.path, error)
                                } else {
                                    DLog("error saving file")
                                    let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else {
                                completion(destinationUrl.path, error)
                            }
                        } else {
                            let error = NSError(domain:"Invalid return code file", code:1002, userInfo:nil)
                            completion(destinationUrl.path, error)
                        }
                    }
                        
                    // else it was local request
                    else  {
                        //
                        if (try? data!.write(to: destinationUrl, options: [.atomic])) != nil {
                            DLog("local file saved [\(destinationUrl.path)]")
                            completion(destinationUrl.path, error)
                        } else {
                            DLog("error saving local file")
                            let error = NSError(domain:"Error saving local file", code:1001, userInfo:nil)
                            completion(destinationUrl.path, error)
                        }
                    }
                }
                else {
                    DLog("Failure: \(error!.localizedDescription)");
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }

    
    func configFromFileAtPath(_ path: String) -> [String: AnyObject]! {
        // try to deserialize from local file
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                DLog(error.localizedDescription)
                return nil
            }
        }
        // not found? then set the defaults
        
        return nil
    }
    
    func initTriggers() {
        guard configDict != nil else { return }
        guard let triggers_dict = configDict?["triggers"] else { return }
        if let parameters = triggers_dict[ABCommonTriggerKeys.resume.rawValue]  as? [String : Int] {
            ABTriggerManager.shared.addTrigger(key: ABCommonTriggerKeys.resume.rawValue, parameters: parameters)
        }
        if let parameters = triggers_dict[ABCommonTriggerKeys.review.rawValue]  as? [String : Int] {
            ABTriggerManager.shared.addTrigger(key: ABCommonTriggerKeys.review.rawValue, parameters: parameters)
        }
        if let parameters = triggers_dict[ABCommonTriggerKeys.level.rawValue]  as? [String : Int] {
            ABTriggerManager.shared.addTrigger(key: ABCommonTriggerKeys.level.rawValue, parameters: parameters)
        }
    }    
}

