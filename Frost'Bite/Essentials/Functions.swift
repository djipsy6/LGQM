//
//  Functions.swift
//  AdamApp
//
//  Created by Djibril Coly on 3/28/20.
//  Copyright © 2020 Djibril Coly. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData
import UserNotifications
import AuthenticationServices
import NotificationBannerSwift
import AVKit

var tonePlayer: AVAudioPlayer?

func playTone(sound: String) {
        
    guard let url = Bundle.main.url(forResource: sound, withExtension: "m4a") else { return }
    
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        
        /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
        tonePlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        
        /* iOS 10 and earlier require the following line:
         player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
        
        guard let tonePlayer = tonePlayer else { return }
        
        tonePlayer.volume = 0.8
        tonePlayer.play()
        
    } catch let error {
        print(error.localizedDescription)
    }
}

func isEmailValid(email:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}

func isNameValid(name:String) -> Bool {
    //    let RegEx = "^[a-zA-Z]{4,}(?: [a-zA-Z]+){0,2}$"
    //    let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
    //    return Test.evaluate(with: name)
    if name.count > 5 && name.contains(" ") {
        return true
    } else {
        return false
    }
}

func throwAlert(title : String, message : String, in vc: UIViewController) {
    alertTitleText = title
    alertDescText = message
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
    myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    myAlert.modalTransitionStyle = UIModalTransitionStyle.coverVertical
    vc.present(myAlert, animated: true, completion: nil)
}

func goToVc(from:UIViewController, target:String, method:UIModalPresentationStyle) {
    DispatchQueue.main.async(execute: {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: target)
        myAlert.modalPresentationStyle = method
        myAlert.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        from.present(myAlert, animated: true, completion: nil)
    })
}


func fireNotification(title:String, body:String, style:BannerStyle) {
    let banner = NotificationBanner(title: title, subtitle: body, style: style)
    banner.show()
}


func getUserData(scope:String) -> String {
    if let userData = UserDefaults.standard.value(forKey: "userData") as? [String:String], let data = userData[scope] {
        return data
    } else {
        return ""
    }
}

func shortenLink(link:String, completion: @escaping(String)->()) {
    
    let querystring = "https://tinyurl.com/api-create.php?url=" + link
    
    if let encoded = querystring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
        let url = URL(string: encoded) {
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                //print(error!)
            } else {
                if let urlContent = data {
                    if let shortLink = String(data: urlContent, encoding: .utf8) {
                        completion(shortLink)
                    }
                }
             }
        }
        task.resume()
    }

}

func rewardGamerAd(points:String, completion: @escaping(Bool)->()) {
    
    let engine = Engine()
    let querystring = engine.rewardGamerAd(points: points)
    
    if let encoded = querystring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
        let url = URL(string: encoded) {
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(true)
        }
        task.resume()
    }

}

func getAvatar(id: String) -> UIImage {
    if let intId = Int(id)  {
        return UIImage(named: "avatar_\(intId % 11)") ?? UIImage(named: "avatar_\(Int.random(in: 1...11) % 11)")!
    } else {
        return UIImage(named: "avatar_\(Int.random(in: 1...11) % 11)")!
    }
}


func goTab(tab:Int) {
    if let customTabBar = mainTabBar as? CustomTabBar {
        customTabBar.didPressTab(customTabBar.buttons[tab])
    }
}
