//
//  RootWindowController.swift
//  Import
//
//  Created by Marko Hlebar on 05/10/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

import Cocoa

class RootWindowController: NSWindowController {
    
    let path = "/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings"
    
    @IBOutlet weak var imageView: NSImageView!
    
    @IBAction func installKeyBindings(_ sender: AnyObject) {
        let inserter = KeyBindingsInserter(withPath: NSHomeDirectory() + path);
        inserter.insertBindings()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let image = NSImage(named: "usage.gif")
        imageView.imageScaling = .scaleNone
        imageView.animates = true
        imageView.image = image
        imageView.canDrawSubviewsIntoLayer = true
        imageView.superview?.wantsLayer = true
    }
}
