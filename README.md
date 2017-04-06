# ABTriggers
Remote-configurable JSON defined triggers for various events in your app (displaying ads, asking for review, etc)

## Remote config file
Each of my apps needs some amount of configuration from the server. While more verbose than using Parse / Firebase, having my own solution gives more privacy and control.
The remote config files are json files. Downloading the latest version from the server is usually being done in the
the application:didFinishLaunchingWithOptions method from AppDelegate

```swift
 ABRemoteConfig.shared.setupWithCompletionOrDefaultToLocal(configFileName : UNIQUE_ID, configRemoteURL : APP_CONFIG_URL_STRING) {
      ABRemoteConfig.shared.initTriggers()
      // more stuff to do after initializing the triggers
  }
```
[... to be continued] 

## Triggers

Triggers are simple json hashes with the following format
```json
"review":{
   "frequency":0,
   "startAfter":5,
   "period":10
   },
```
The trigger will be incremented at every call for tryTrigger(), and once every "period" times it'll get fired. The startAfter parameter allows you to define an initial delay, so that it doesn't fire for a while the first times. If the frequency parameter is > 0, the trigger fires randomly, with the specified frequency (freq times out of period).
 
[... to be continued/clarified] 

## How to use

In your code, whenever you need to update the trigger, call

```swift
if ABTriggerManager.shared.trigger(key: triggerKey)?.tryTrigger() ?? false {
  // the code executed if the trigger fired
}
```
Inside the conditional, you'll place the code that's to be executed if the trigger has fired. For the "review" trigger example, you'll pop up a UIAlertController that asks the user to leave a review. 