//
//  RootWindowController.swift
//  Import
//
//  Created by Marko Hlebar on 05/10/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class RootWindowController: NSWindowController {
    
    let path = "/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings"
    
    @IBOutlet weak var playerView: AVPlayerView!
    
    @IBAction func installKeyBindings(_ sender: AnyObject) {
        let inserter = KeyBindingsInserter(withPath: NSHomeDirectory() + path);
        inserter.insertBindings()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let url = Bundle.main.url(forResource: "usage", withExtension: "mov")!
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.play()
        
        playerView.player = player
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loop(with:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem!)
    }
    
    func loop(with notification: Notification) {
        let item = notification.object as! AVPlayerItem
        item.seek(to: kCMTimeZero)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
