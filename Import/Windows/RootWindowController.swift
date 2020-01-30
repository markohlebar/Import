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
    static let usageMovie = (name: "usage", extension: "mp4")
    static let installationMovie = (name: "installation", extension: "mp4")
}

class RootWindowController: NSWindowController {

    @IBOutlet weak var playerView: AVPlayerView!

    lazy var keyBindingsPath: String = {
        return Sandboxing.userHomePath().appending(pathComponent: Resources.keyBindingsPath)
    }()
    
    @IBAction func installKeyBindings(_ sender: AnyObject) {
        let inserter = KeyBindingsInserter(withPath: keyBindingsPath);
        inserter.insertBindings()
    }
    
    @IBAction func switchInstructions(_ sender: NSSegmentedControl) {
        playItem(atUrl: movieUrl(for: sender.selectedSegment))
    }

    func movieUrl(for segment: Int) -> URL {
        let file = segment == 0 ? Resources.installationMovie : Resources.usageMovie
        return Bundle.main.url(forResource: file.name, withExtension: file.extension)!
    }

    @IBAction func openSystemPreferences(_ sender: AnyObject) {
        let file = Resources.systemPrefsScript
        let url = Bundle.main.url(forResource: file.name, withExtension: file.extension)!
        let script = NSAppleScript(contentsOf: url, error: nil)
        script?.executeAndReturnError(nil)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        let url = movieUrl(for: 0)
        playItem(atUrl: url);
    }

    func playItem(atUrl url: URL) {
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.play()

        playerView.player = player

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loop(with:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem!)
    }
    
    @objc func loop(with notification: Notification) {
        let item = notification.object as! AVPlayerItem
        item.seek(to: CMTime.zero)
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
