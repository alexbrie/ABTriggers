//
//  ABTrigger.swift
//
//  Created by Alex Brie on 05/04/2017.
//  Copyright © 2017 Cognitive Bits. All rights reserved.
//

import Foundation

/* 
 accomplishes one simple important task: persistently increments a counter, and checks if the conditions for triggering a response have been met
 */

class ABSimpleTrigger {
    private(set) public var key : String
    private(set) public var initialDelay : Int = 0
    private(set) public var period : Int = 0
    private(set) public var frequency : Int?
    
    init(withKey : String, period per: Int = 1, frequency freq: Int? = nil, delay del : Int = 0) {
        key = withKey
        period = per
        frequency = freq
        initialDelay = del
    }
    
    func update(period per: Int, frequency freq: Int? = nil, delay del : Int) {
        period = per
        frequency = freq
        initialDelay = del
    }
    
    private(set) public var counter : Int {
        set(value){
            UserDefaults.standard.set(value, forKey: counterKey)
            UserDefaults.standard.synchronize()
        }
        
        get {
            return UserDefaults.standard.integer(forKey: counterKey)
        }
    }
    
    public var isDisabled : Bool {
        set(value){
            UserDefaults.standard.set(value, forKey: disabledKey)
            UserDefaults.standard.synchronize()
        }
        
        get {
            return UserDefaults.standard.bool(forKey: disabledKey)
        }
    }
    
    func triggered() -> Bool {
        guard !isDisabled else {
            return false
        }
        let callCounter = counter

        // the '=' is to prevent instant triggering from the start; if I want instant triggering, just set initialDelay to 0
        if initialDelay > 0 && callCounter <= initialDelay {
            return false
        }
        if frequency != nil && frequency! > 0 {
            let randomExtraction = Int(arc4random_uniform(UInt32(period)))
            return randomExtraction < frequency!
        }
        else {
            return (callCounter - initialDelay) % period == 0
        }
    }
    
    private func incrementCounter() {
        guard !isDisabled else { return }
        counter += 1
    }
    
    public func tryTrigger(shouldIncrement increments: Bool = true)->Bool {
        let ret = triggered()
        if increments {
            incrementCounter()
        }
        return ret
    }
    
    
    // MARK :- Keys
    
    private var counterKey : String {
        return "trigger*\(key)*Counter"
    }
    
    private var disabledKey : String {
        return "trigger*\(key)*Disabled"
    }
}

let AB_TRIGGER_DELAY = "startAfter"
let AB_TRIGGER_PERIOD = "period"
let AB_TRIGGER_FREQUENCY = "frequency"
let AB_TRIGGER_DISABLED = "disabled"

class ABTriggerManager {
    // singleton
    static let shared = ABTriggerManager()
    var triggers : [String : ABSimpleTrigger]
    
    init() {
        triggers = [:]
    }
    
    @discardableResult func addTrigger(key : String, parameters : [String : Int]) -> ABSimpleTrigger {
        if let trigger = triggers[key] {
            trigger.update(period: parameters[AB_TRIGGER_PERIOD] ?? 1, frequency: parameters[AB_TRIGGER_FREQUENCY], delay: parameters[AB_TRIGGER_DELAY] ?? 0)
        }
        else {
            let simpleTrigger = ABSimpleTrigger(withKey: key, period: parameters[AB_TRIGGER_PERIOD] ?? 1, frequency: parameters[AB_TRIGGER_FREQUENCY], delay: parameters[AB_TRIGGER_DELAY] ?? 0)
            triggers[key] = simpleTrigger
        }
        return triggers[key]!
    }
    
    @discardableResult func trigger(key : String) -> ABSimpleTrigger? {
        return triggers[key]
    }
}

enum ABCommonTriggerKeys : String {
    case
    review = "review",
    level = "level",
    resume = "resume"
}

class ABCommonTriggers {
    static let proSuffix = "pro"

    class func key() -> Bool {
        return false
    }
}
