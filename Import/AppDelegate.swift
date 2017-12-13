//
//  AppDelegate.swift
//  Import
//
//  Created by Marko Hlebar on 04/10/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    lazy var nibName: String = {
        return Sandboxing.isAppSandboxed() ? "RootWindowController_Sandbox": "RootWindowController"
    }()

    lazy var rootWindowController: RootWindowController = RootWindowController(windowNibName: NSNib.Name(rawValue: self.nibName))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        self.window = rootWindowController.window!
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

