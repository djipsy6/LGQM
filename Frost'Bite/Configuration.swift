//
//  Configuration.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import Foundation
import UIKit

class Engine {
    
    // PROPERTIES
//    let rootServer : String = "http://192.168.1.3/Flumeo/"
//    let server : String = "http://192.168.1.3/Flumeo/APIs/"
//
    let rootServer : String = "https://flumeoapp.com/"
    let server : String = "https://flumeoapp.com/APIs/"
    let api : String = "h4d-kdh-JDzd-LAe-81j-824ee"
    let secret : String = "9dj-LKN-Jdd-Lmz-72s-0Jdh"
    var appVersion = ""
    var locale = "en"
    
    var user_id = ""
    
    // GLOBAL PARAMETERS
    let dailyLimits = 15
    let freeDownloadsLimits = 5
    let premiumDownloadsLimit = 10000
    
    // INIT
    init() {
        if let userData = UserDefaults.standard.value(forKey: "userData") as? [String:String], let user_id = userData["user_id"] {
            self.user_id = user_id
        }
        self.appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "Unspecified"
        self.locale = Locale.current.languageCode ?? "en"
    }
    
    // METHODS
    func logUserIn(password:String, emailid:String) -> String {
        let signature = server + "logUserIn.php?api=" + api + "&secret=" + secret
        let append = "&emailid=" + emailid + "&password=" + password + "&version=" + self.appVersion + "&scope=frostbite"
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }

    func getHomeData() -> String {
        let signature = server + "frostbite/getHomeData.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&locale=" + locale
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func getGameData(game:String) -> String {
        let signature = server + "frostbite/getGameData.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&game=" + game + "&locale=" + locale
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func getGameBundle(game:String) -> String {
        let signature = server + "frostbite/getGameBundle.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&game=" + game + "&locale=" + locale
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func getGamerData(gamer:String) -> String {
        let signature = server + "frostbite/getGamerData.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&gamer=" + gamer + "&locale=" + locale
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func getFriendsList(search:String) -> String {
        let signature = server + "frostbite/getFriendsList.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&search=" + search + "&locale=" + locale
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func getTimelineData() -> String {
        let signature = server + "frostbite/getTimelineData.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&locale=" + locale
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func searchGames(search:String) -> String {
        let signature = server + "frostbite/searchGames.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&search=" + search + "&locale=" + locale
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func syncGameData(gamer:String, game:String, score:String, songs:String, points:Int) -> String {
        let signature = server + "frostbite/syncGameData.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&gamer=" + gamer + "&game=" + game + "&score=" + score + "&songs=" + songs + "&points=\(points)"
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func addRemoveFriend(gamer:String) -> String {
        let signature = server + "frostbite/addRemoveFriend.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&gamer=" + gamer
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func syncGhostGameData(gamer:String, game:String, score:String, songs:String, points:Int) -> String {
        let signature = server + "frostbite/syncGhostGameData.php?api=" + api + "&secret=" + secret
        let append = "&uuid=" + UIDevice.current.identifierForVendor!.uuidString + "&gamer=" + gamer + "&game=" + game + "&score=" + score + "&songs=" + songs +  "&points=\(points)"
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func rewardGamerAd(points:String) -> String {
        let signature = server + "frostbite/rewardAd.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&points=" + points
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func updatePushToken(deviceToken:String) -> String {
        let signature = server + "frostbite/updatePushToken.php?api=" + api + "&secret=" + secret
        let append = "&uid=" + user_id + "&devicetoken=" + deviceToken
        let randomizer = Int.random(in: 0 ... 9999)
        return signature + append + "&randomizer=" + String(randomizer)
    }
    
    func getUserPhoto(endname:String) -> URL {
        return URL(string: rootServer + "data/avatars/" + endname)!
    }
    
    func getPlaylistCover(endname:String) -> URL {
        return URL(string: rootServer + "data/playlists/" + endname)!
    }
    
    func getTrackContent(endname:String) -> String {
        return rootServer + "data/files/" + endname
    }
    
    func getAlbumCover(endname:String) -> URL {
        return URL(string: rootServer + "data/albums/" + endname)!
    }
    
}
