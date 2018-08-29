//
//  AppDelegate.swift
//  Mappies
//
//  Created by Hanafi Hisyam on 23/08/2018.
//  Copyright © 2018 Hanafi Hisyam. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAxw6nCK_m5zGXK5cPSRpUlZFBTMiNJa_Q")
        GMSPlacesClient.provideAPIKey("AIzaSyAxw6nCK_m5zGXK5cPSRpUlZFBTMiNJa_Q")
        
        let freschatConfig:FreshchatConfig = FreshchatConfig.init(appID: "c15f9ae2-008b-4c00-acae-a1729c9f4c1b", andAppKey: "648deac9-a706-46f0-98b1-5448c9a30d47")
        Freshchat.sharedInstance().initWith(freschatConfig)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        var freahchatUnreadCount = Int()
        Freshchat.sharedInstance().unreadCount { (unreadCount) in
            freahchatUnreadCount = unreadCount
        }
        UIApplication.shared.applicationIconBadgeNumber = freahchatUnreadCount;
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(userInfo, andAppstate: application.applicationState)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Freshchat.sharedInstance().setPushRegistrationToken(deviceToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent: UNNotification,
                                withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        if Freshchat.sharedInstance().isFreshchatNotification(willPresent.request.content.userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(willPresent.request.content.userInfo, andAppstate: UIApplication.shared.applicationState)  //Handled for freshchat notifications
        } else {
            withCompletionHandler([.alert, .sound, .badge]) //For other notifications
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive: UNNotificationResponse,
                                withCompletionHandler: @escaping ()->()) {
        if Freshchat.sharedInstance().isFreshchatNotification(didReceive.notification.request.content.userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(didReceive.notification.request.content.userInfo, andAppstate: UIApplication.shared.applicationState) //Handled for freshchat notifications
        } else {
            withCompletionHandler() //For other notifications
        }
    }

}

