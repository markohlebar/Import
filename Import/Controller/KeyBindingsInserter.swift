//
//  KeyBindingsController.swift
//  Import
//
//  Created by Marko Hlebar on 05/10/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

import Foundation
import Cocoa

fileprivate enum KeyBindings {
    
    enum Key {
        static let MenuKeyBindings = "Menu Key Bindings"
        static let KeyBindings = "Key Bindings"
        static let CommandID = "CommandID"
        static let KeyboardShortcut = "Keyboard Shortcut"
    }
    
    enum Value {
        static let CommandID = "IDESourceEditorExtension:com.squid.Import.ImportExtension,IDESourceEditorExtensionCommand:com.squid.Import.ImportExtension.Command"
        static let KeyboardShortcut = "^@p"
    }
}

fileprivate enum Messages {

    static let BindingAlreadySet = "Binding is already set.\nImport is ready to be used in Xcode."
    static let BindingIsSet = "Binding ⌘ + ctrl + P is now set in Xcode."
    static let CouldNotInstall = "Sorry, could not install the key bindings at this time.\nTry  -> System Preferences... -> Extensions -> All -> Enable Import,\nand try again."
}

class KeyBindingsInserter {
    
    let path: String
    lazy var vanillaPlistPath = Bundle.main.path(forResource: "Default", ofType: ".idekeybindings")!
    
    init(withPath path: String) {
        self.path = path
    }
    
    func insertBindings() {
        if (FileManager.default.fileExists(atPath: path)) {
            insertVanillaPlist()
        }
        else {
            installVanillaPlist()
        }
    }
    
    private func insertVanillaPlist() {
        guard let existingPlist = NSMutableDictionary(contentsOfFile: path) else {
            present(message: Messages.CouldNotInstall, style: .critical)
            return
        }

        guard let vanillaPlist = NSDictionary(contentsOfFile: vanillaPlistPath) else {
            return
        }
        
        if let bindings = extractBindings(from: existingPlist) {
            let bindingPosition = position(in: bindings)
            let vanillaBindings = extractBindings(from: vanillaPlist)
            let vanillaBinding = vanillaBindings!.firstObject as! NSDictionary

            //check if there is already a plist entry and replace it.
            if bindingPosition != NSNotFound {
                if let binding = bindings[bindingPosition] as? NSDictionary,
                    isBindingSet(in: binding) {
                    present(message: Messages.BindingAlreadySet, style: .informational)
                    return;
                }
                else {
                    bindings.removeObject(at: bindingPosition)
                    bindings.insert(vanillaBinding, at: bindingPosition)
                }
            }
            else {
                bindings.insert(vanillaBinding, at: 0)
            }

            existingPlist.write(toFile: path, atomically: true);
            present(message: Messages.BindingIsSet, style: .informational)
        }
        else {
            present(message: Messages.CouldNotInstall, style: .critical)
        }
    }

    private func extractBindings(from plist: NSDictionary) -> NSMutableArray? {
        if let menuKeyBindings = plist[KeyBindings.Key.MenuKeyBindings] as? NSDictionary,
            let keyBindings = menuKeyBindings[KeyBindings.Key.KeyBindings] as? NSMutableArray {
                return keyBindings
        }
        return nil
    }
    
    private func position(in bindings:NSMutableArray) -> Int {
        guard let binds = bindings as? [NSDictionary] else {
            return NSNotFound
        }

        for (index, binding) in binds.enumerated() {
            if binding[KeyBindings.Key.CommandID] as? String == KeyBindings.Value.CommandID {
                return index
            }
        }
        return NSNotFound
    }
    
    private func isBindingSet(in dictionary:NSDictionary) -> Bool {
        if let shortcut = dictionary[KeyBindings.Key.KeyboardShortcut] as? String,
            shortcut == KeyBindings.Value.KeyboardShortcut {
            return true
        }
        return false
    }
    
    private func installVanillaPlist() {
        let keyBindingsFolder = NSString(string: path).deletingLastPathComponent
        if !FileManager.default.fileExists(atPath: keyBindingsFolder) {
            do {
                try FileManager.default.createDirectory(atPath: keyBindingsFolder,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            catch let error as NSError {
                present(error: error)
                return
            }
        }

        do {
            try FileManager.default.copyItem(atPath: vanillaPlistPath, toPath: path)
            present(message: Messages.BindingIsSet, style: .informational)
        }
        catch let error as NSError {
            present(error: error)
        }
    }
    
    private func present(message: String, style: NSAlertStyle) {
        let alert = NSAlert()
        alert.messageText = (style == .informational) ? "👍" : "🤕"
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func present(error: NSError) {
        present(message: error.localizedDescription, style:.critical)
    }
}
