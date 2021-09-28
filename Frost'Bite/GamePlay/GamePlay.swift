//
//  GamePlay.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

var audioPlayer : AVPlayer?

class GamePlay: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var goodAnswersLabel: UILabel!
    @IBOutlet weak var earnedPointsLabel: UILabel!
    @IBOutlet weak var themeLayer: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var gameProgress: UIProgressView!
    
    @IBOutlet weak var remainingSongsLabel: UILabel!
    @IBOutlet weak var songArtwork: UIImageView!
    @IBOutlet weak var songProgress: UIProgressView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var avPlayer: AVPlayer?
    let engine = Engine()
    
    @IBAction func quitGame(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            audioPlayer?.pause()
            self.timer.invalidate()
            self.playerTimer.invalidate()
            self.asset.cancelLoading()
            audioPlayer = nil
        })
    }
    
    @IBAction func changeView(_ sender: Any) {
        let controller = sender as! UISegmentedControl
        if controller.selectedSegmentIndex == 0 {
            textView.isHidden = true
            songArtwork.isHidden = false
        } else {
            textView.isHidden = false
            songArtwork.isHidden = true
        }
    }
    
    var asset = AVAsset(url: URL(string:"https://flumeoapp.com")!)
    let keys : [String] = ["playable"]
    
    var timer = Timer()
    var playerTimer = Timer()
    var avPlayerLayer: AVPlayerLayer!
    var gameBundle : [String:Any] = [:]
    var currentIndex = 0
    var currentAnswers : [String] = []
    var remaining = 10
    var playbackStarted = false
    var anchorStart : Double = 0.0
    var scoreBoard : [[String:String]] = []
    var goodAnswers = 0
    var points = 0
    
    var themes : [UIImage?] = [UIImage(named: "gradient_1"), UIImage(named: "gradient_2"), UIImage(named: "gradient_4"), UIImage(named: "gradient_5")]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "choicecell", for: indexPath) as! ChoiceCell
        //cell.choiceTheme.image = themes[indexPath.row]
        if currentAnswers.isEmpty || playbackStarted == false {
            cell.titleLabel.text = ""
        } else {
            cell.titleLabel.text = currentAnswers[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 5, height: collectionView.bounds.height / 2 - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if playbackStarted {
            if let assets = gameBundle["assets"] as? [[String:Any]] {
                if currentAnswers[indexPath.row] == assets[currentIndex]["title"] as? String ?? "" {
                    let score = ["track_id": assets[currentIndex]["id"] as! String, "found":"yes"]
                    scoreBoard.append(score)
                    playTone(sound: "good_answer")
                    points += remaining
                    earnedPointsLabel.text = "  \(points) \(NSLocalizedString("xpPoints", comment: ""))  "
                    goodAnswers += 1
                    goodAnswersLabel.text = "  \(goodAnswers) \(NSLocalizedString("outOf", comment: "")) \(currentIndex + 1)  "
                    nextSong()
                } else {
                    let score = ["track_id": assets[currentIndex]["id"] as! String, "found":"no"]
                    scoreBoard.append(score)
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    playTone(sound: "wrong_buzzer")
                    goodAnswersLabel.text = "  \(goodAnswers) \(NSLocalizedString("outOf", comment: "")) \(currentIndex + 1)  "
                    nextSong()
                    print("LOST")
                    wrongAnimation()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.isHidden = true
        
        let theURL = Bundle.main.url(forResource:"background", withExtension: "mp4")
        avPlayer = AVPlayer(url: theURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer?.isMuted = true
        avPlayer?.actionAtItemEnd = .none
        avPlayer?.allowsExternalPlayback = false
        avPlayer?.play()
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.white
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
        
        audioPlayer = AVPlayer()
        //themeLayer.kf.setImage(with: Bundle.main.url(forResource: "\(Int.random(in: 1...5))", withExtension: "gif"))
        themeLayer.contentMode = .scaleAspectFill
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.exitGame), name:NSNotification.Name(rawValue: "exit"), object: nil)
        
        getGameBundle()
        
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        avPlayer?.seek(to: CMTime.zero)
        avPlayer?.play()
    }
    
    @objc func exitGame() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getGameBundle() {
        
        let querystring = engine.getGameBundle(game: game_id)
        //print(querystring)
        
        if let encoded = querystring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded)
        {
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                if error != nil {
                    //print(error!)
                } else {
                    if let urlContent = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                            if let pick = jsonResult as? [String:Any] {
                                self.gameBundle = pick
                                DispatchQueue.main.async(execute: {
                                    self.updateUI()
                                })
                            }
                            
                        } catch {
                            //print("Could not Serialize data")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func updateUI() {
        
        // HEADER
        titleLabel.text = gameBundle["title"] as? String ?? ""
        subtitleLabel.text = NSLocalizedString("by", comment: "") + " " + (gameBundle["subtitle"] as! String)
        cover.kf.setImage(with: engine.getPlaylistCover(endname: gameBundle["cover"] as? String ?? ""), placeholder: UIImage(named: "default_cover"))
        
        // CENTER VIEW
        songArtwork.kf.setImage(with: engine.getPlaylistCover(endname: gameBundle["cover"] as? String ?? ""), placeholder: UIImage(named: "default_cover"))
        
        // START GAME
        startGame()
    }
    
    func startGame() {
        // RESET VALUE
        remaining = 10
        gameProgress.setProgress(0, animated: true)
        songProgress.setProgress(0, animated: true)
        songArtwork.image = UIImage(named: "default_cover")
        
        timer.invalidate()
        playerTimer.invalidate()
        
        // REMOVE PREVIOUS ANSWERS
        currentAnswers.removeAll()
        collectionView.reloadData()
        
        if let assets = gameBundle["assets"] as? [[String:Any]], assets.indices.contains(currentIndex) {
            let currentSong = assets[currentIndex]
            remainingSongsLabel.text = " \(currentIndex + 1) \(NSLocalizedString("outOf", comment: "")) \(assets.count) "
            gameProgress.setProgress((1.0 / Float(assets.count)) * Float(currentIndex + 1), animated: true)
            if let answers = currentSong["answers"] as? [String] {
                currentAnswers = answers
                setPlayer()
            }
        }
        
    }
    
    func setPlayer() {
        
        audioPlayer?.pause()
        audioPlayer?.seek(to: .zero)
        playbackStarted = false
        loading.isHidden = false
        asset.cancelLoading()
        
        if let assets = gameBundle["assets"] as? [[String:Any]], assets.indices.contains(currentIndex) {
            let currentSong = assets[currentIndex]
            songArtwork.kf.setImage(with: engine.getAlbumCover(endname: currentSong["cover"] as? String ?? ""), placeholder: UIImage(named: "default_cover"))
            
            let urlString = engine.getTrackContent(endname: currentSong["stream_path"] as? String ?? "")
            
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let urlOut = URL(string: encoded) {
                asset.cancelLoading()
                asset = AVAsset(url: urlOut)
                
                var error : NSError?
                asset.loadValuesAsynchronously(forKeys: keys) {
                    
                    DispatchQueue.main.async(execute: {
                        if self.asset.isPlayable && self.asset.statusOfValue(forKey: "playable", error: &error) != .failed {
                            
                            let item = AVPlayerItem(asset: self.asset)
                            audioPlayer = AVPlayer(playerItem: item)
                            _ = try? AVAudioSession.sharedInstance().setActive(true)
                            audioPlayer?.playImmediately(atRate: 1.0)
                            self.lyricsFromMusixmatch()
                            
                            self.playerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
                            
                            self.anchorStart = CMTimeGetSeconds(audioPlayer?.currentItem?.asset.duration ?? CMTime.zero) * Double.random(min:0, max: 0.5)
                            audioPlayer?.seek(to: CMTime(seconds: self.anchorStart, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                        } else {
                            self.setPlayer()
                        }
                        
                    })
                }
            }
        }
        
    }
    
    @objc func runGameTimer() {
        let progress = 10 - Float(remaining)
        songProgress.setProgress(progress / 10, animated: true)
        
        remaining -= 1
        if remaining == 0 {
            timer.invalidate()
            playerTimer.invalidate()
            // NEXT SONG
            print("NEXT SONG TRIGGER [currentIndex: \(currentIndex)]")
            
            // MARK AS LOST
            if let assets = gameBundle["assets"] as? [[String:Any]] {
                let score = ["track_id": assets[currentIndex]["id"] as! String, "found":"no"]
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                scoreBoard.append(score)
                goodAnswersLabel.text = "  \(goodAnswers) \(NSLocalizedString("outOf", comment: "")) \(currentIndex + 1)  "
                playTone(sound: "wrong_buzzer")
                textView.text = ""
                wrongAnimation()
                print("LOST • TIMEOUT [currentIndex: \(currentIndex)]")
            }
            
            nextSong()
        }
    }
    
    @objc func updateCurrentTime() {
        
        if !playbackStarted {
            if (audioPlayer?.currentItem?.asset.duration) != nil && audioPlayer?.currentTime() != nil {
                if (CMTimeGetSeconds((audioPlayer?.currentTime())!)) > anchorStart {
                    print("PLAYING [currentIndex: \(currentIndex)]")
                    playbackStarted = true
                    loading.isHidden = true
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runGameTimer), userInfo: nil, repeats: true)
                    collectionView.reloadData()
                }
            }
        }
        
    }
    
    func nextSong() {
        audioPlayer?.pause()
        playbackStarted = false
        textView.text = ""
        playerTimer.invalidate()
        timer.invalidate()
        if let assets = gameBundle["assets"] as? [[String:Any]], assets.indices.contains(currentIndex + 1) {
            currentIndex += 1
            startGame()
        } else {
            // GAME ENDED
            print("GAME ENDED")
            gameEnded()
        }
    }
    
    func gameEnded() {
        self.performSegue(withIdentifier: "gameover", sender: nil)
    }
    
    func wrongAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: songArtwork.center.x - 10, y: songArtwork.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: songArtwork.center.x + 10, y: songArtwork.center.y))
        songArtwork.layer.add(animation, forKey: "position")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer?.pause()
        self.timer.invalidate()
        self.playerTimer.invalidate()
        self.asset.cancelLoading()
        audioPlayer = nil
        themeLayer.image = nil
        avPlayer = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameover" {
            var found = 0
            for i in 0..<scoreBoard.count {
                if scoreBoard[i]["found"] == "yes" {
                    found += 1
                }
            }
            
            let nextVC = segue.destination as! GameOver
            nextVC.score = "\(found) \(NSLocalizedString("outOf", comment: "")) \(scoreBoard.count), \(points) \(NSLocalizedString("xp", comment: ""))"
            nextVC.gameTitle = gameBundle["title"] as? String ?? ""
            nextVC.gameSubtitle = gameBundle["subtitle"] as? String ?? ""
            nextVC.game_id = gameBundle["id"] as? String ?? ""
            nextVC.coverArtwork = gameBundle["cover"] as? String ?? ""
            nextVC.owner_id = gameBundle["gamer_id"] as? String ?? ""
            nextVC.songs = String(scoreBoard.count)
            nextVC.intScore = found
            nextVC.points = points
            
            switch found * 100 / scoreBoard.count {
            case 0..<25:
                nextVC.appreciation = NSLocalizedString("badScore", comment: "")
                nextVC.motivation = "fail"
            case 25..<50:
                nextVC.appreciation = NSLocalizedString("lowScore", comment: "")
                nextVC.motivation = "fail"
            case 50..<75:
                nextVC.appreciation = NSLocalizedString("mediumScore", comment: "")
                nextVC.motivation = "win"
            default:
                nextVC.appreciation = NSLocalizedString("highScore", comment: "")
                nextVC.motivation = "win"
            }
            
            
        }
    }
    
    func lyricsFromMusixmatch() {
        
        return
        if let assets = gameBundle["assets"] as? [[String:Any]], assets.indices.contains(currentIndex) {
            let currentSong = assets[currentIndex]
            
            var rawURL = "https://api.musixmatch.com/ws/1.1/matcher.lyrics.get?q_track=" + (currentSong["title"] as! String)
            rawURL = rawURL + "&q_artist=" + (currentSong["artist"] as! String) + "&apikey=548fe270e965e351c816622557a35cac"
            
            //print(rawURL)
            if let encoded = rawURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                let url = URL(string: encoded)
            {
                let task = URLSession.shared.dataTask(with: url) {
                    (data, response, error) in
                    if error != nil {
                        //print(error!)
                    } else {
                        if let urlContent = data {
                            do {
                                let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                                //print(jsonResult)
                                
                                if let pick = jsonResult as? [String: Any] {
                                    
                                    if let message = pick["message"] as? [String:Any], let header = message["header"] as? [String:Any], header["status_code"] as? Int == 200 {
                                        
                                        if let body = message["body"] as? [String:Any], let lyrics = body["lyrics"] as? [String:Any] {
                                            DispatchQueue.main.async(execute: {
                                                self.segmentControl.isHidden = false
                                                self.textView.text = (lyrics["lyrics_body"] as? String ?? "").replacingOccurrences(of: "******* This Lyrics is NOT for Commercial use *******", with: "")
                                            })
                                        }
                                    } else {
                                        DispatchQueue.main.async(execute: {
                                            self.segmentControl.selectedSegmentIndex = 0
                                            self.songArtwork.isHidden = false
                                            self.textView.isHidden = true
                                            self.textView.text = ""
                                            self.segmentControl.isHidden = true
                                        })
                                    }
                                    
                                }
                                
                            } catch {
                                //print("Could not Serialize data")
                            }
                        }
                    }
                }
                task.resume()
            }
            
        }
        
    }
    
}
