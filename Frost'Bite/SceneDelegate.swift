//
//  SceneDelegate.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/17/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit
import GoogleMobileAds

var launchToDos : [String] = []

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        UIApplication.shared.applicationIconBadgeNumber = 0
        addWindowSizeHandlerForMacOS()
        
        if let url = connectionOptions.urlContexts.first?.url {
            let param = url.absoluteString.components(separatedBy: "?").last?.components(separatedBy: "=")
            let key = param?.first
            let value = param?.last
            
            if key == "gamer" {
                gamer_id = value ?? ""
                launchToDos.append("player")
            } else if key == "id" {
                game_id = value ?? ""
                launchToDos.append("preview")
            }
        }
    }


    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            handleURLScheme(url: url)
        }
    }
    
    func addWindowSizeHandlerForMacOS() {
        if #available(iOS 13.0, *) {
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 500, height: 900)
                windowScene.sizeRestrictions?.maximumSize = CGSize(width: 500, height: 1000)
            }
        }
    }
    
    func handleURLScheme(url:URL) {
        
        let param = url.absoluteString.components(separatedBy: "?").last?.components(separatedBy: "=")
        let key = param?.first
        let value = param?.last
     
        if key == "gamer" {
            if let current = UIApplication.topViewController() {
                    gamer_id = value ?? ""
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "gamer") as! Player
                    current.present(vc, animated: true, completion: nil)
                
            }
        } else if key == "id" {
            if let current = UIApplication.topViewController() {
                game_id = value ?? ""
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "preview") as! GamePreview
                current.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

