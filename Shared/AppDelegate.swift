/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's delegate.
*/

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let accountManager = AccountManager()

    fileprivate var currentServerInfo = SettingsManager.shared.url()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // The override point for customization after app launch.
        
        // HARDCODE SERVER URL
        setUpRESTUrl()
        
        return true
    }
    
    func setUpRESTUrl(){
        
        Constants.Server.Url = "https://emea-rp.identityx-cloud.com/natwest-fido2-demo/" // "https://emea-rp.identityx-cloud.com/PS5/"
        SettingsManager.shared.setServer(url: Constants.Server.Url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // The system calls this method when creating a new scene.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // The system calls this method when the user discards a scene session.
        // If the system discards any sessions while the app isn't running,
        // it calls this shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that are specific to the discarded scenes, because they don't return.
    }
}

