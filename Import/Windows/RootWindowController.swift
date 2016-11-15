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

fileprivate enum Resources {
    static let keyBindingsPath = "/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings"
    static let systemPrefsScript = (name: "open_system_preferences", extension:"scpt")
    static let usageMovie = (name: "usage", extension: "mov")
}

class RootWindowController: NSWindowController {

    @IBOutlet weak var playerView: AVPlayerView!
    
    @IBAction func installKeyBindings(_ sender: AnyObject) {
        
        let usersHomePath = getpwuid(getuid()).pointee.pw_dir
        
        let usersHomePathString : String = FileManager.default.string(withFileSystemRepresentation: usersHomePath!, length: Int(strlen(usersHomePath)))
        
        let keyBindingsPath = usersHomePathString.appending(pathComponent: Resources.keyBindingsPath)

        let inserter = KeyBindingsInserter(withPath: keyBindingsPath);
        inserter.insertBindings()
    }
    
    @IBAction func openSystemPreferences(_ sender: AnyObject) {
        let file = Resources.systemPrefsScript
        let url = Bundle.main.url(forResource: file.name, withExtension: file.extension)!
        let script = NSAppleScript(contentsOf: url, error: nil)
        script?.executeAndReturnError(nil)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        let file = Resources.usageMovie
        let url = Bundle.main.url(forResource: file.name, withExtension: file.extension)!
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

extension String {
    
    public func appending(pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
    
}
