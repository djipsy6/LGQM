//
//  Screenshot.swift
//  Le Grand Quiz Musical
//
//  Created by Djibril Coly on 5/6/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit
import Photos
import SCSDKCreativeKit

class Screenshot: UIViewController {
    
    @IBOutlet weak var themeLayer: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var points: UILabel!
    
    let engine = Engine()
    let snapAPI = SCSDKSnapAPI()
    var image = UIImage()
    var snap = false
    var saveOnly = false
    
    @IBAction func closeWindow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let theme = UserDefaults.standard.value(forKey: "theme") as? Int, theme < 6, theme > 0 {
            themeLayer.stopAnimating()
        }
        
        if getUserData(scope: "avatar") == "default.png" || getUserData(scope: "user_id") == "-1" {
            avatar.image = getAvatar(id: getUserData(scope: "user_id"))
            avatar.backgroundColor = .white
        } else {
            avatar.kf.setImage(with: engine.getUserPhoto(endname: getUserData(scope: "avatar")), placeholder: UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
        }
        
        name.text = getUserData(scope: "name")
        points.text = "  \(getUserData(scope: "score")) \(NSLocalizedString("xpPoints", comment: "")) "
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        image = takeScreenshot()
        
        if snap {
            
            let photo = SCSDKSnapPhoto(image: image)
            let photoContent = SCSDKPhotoSnapContent(snapPhoto: photo)
            
            snapAPI.startSending(photoContent) { [weak self] (error: Error?) in
                //self?.view.isUserInteractionEnabled = true
                print(error)
            }
            
        } else {
            
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: self.image)
                }, completionHandler: { success, error in
                    if self.saveOnly {
                        DispatchQueue.main.async(execute: {
                            throwAlert(title: NSLocalizedString("captureSaved", comment: ""), message: NSLocalizedString("captureSavedDesc", comment: ""), in: self)
                        })
                    } else {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                        if let lastAsset = fetchResult.firstObject {
                            let localIdentifier = lastAsset.localIdentifier
                            let u = "instagram://library?LocalIdentifier=" + localIdentifier
                            DispatchQueue.main.async {
                                UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    
                })
            })
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func takeScreenshot() -> UIImage {
        let imageSize = UIScreen.main.bounds.size as CGSize;
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        for obj : AnyObject in UIApplication.shared.windows {
            if let window = obj as? UIWindow {
                if window.responds(to: #selector(getter: UIWindow.screen)) || window.screen == UIScreen.main {
                    // so we must first apply the layer's geometry to the graphics context
                    context!.saveGState();
                    // Center the context around the window's anchor point
                    context!.translateBy(x: window.center.x, y: window.center
                        .y);
                    // Apply the window's transform about the anchor point
                    context!.concatenate(window.transform);
                    // Offset by the portion of the bounds left of and above the anchor point
                    context!.translateBy(x: -window.bounds.size.width * window.layer.anchorPoint.x,
                                         y: -window.bounds.size.height * window.layer.anchorPoint.y);
                    
                    // Render the layer hierarchy to the current context
                    window.layer.render(in: context!)
                    
                    // Restore the context
                    context!.restoreGState();
                }
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext();
        return image!
    }
    
}
