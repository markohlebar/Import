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
        let existingPlist = NSMutableDictionary(contentsOfFile: path)!
        let vanillaPlist = NSDictionary(contentsOfFile: vanillaPlistPath)!
        
        let bindings = ((existingPlist[KeyBindings.Key.MenuKeyBindings] as! NSDictionary)[KeyBindings.Key.KeyBindings] as! NSMutableArray)
        let bindingPosition = position(in: bindings)
        
        let vanillaBinding = ((vanillaPlist[KeyBindings.Key.MenuKeyBindings] as! NSDictionary)[KeyBindings.Key.KeyBindings] as! NSMutableArray).firstObject as! NSDictionary
        
        //check if there is already a plist entry and replace it.
        if bindingPosition != NSNotFound {
            if isBindingSet(in: bindings[bindingPosition] as! NSDictionary) {
                present(message: "Binding is already set.\nImport is ready to be used in Xcode.", style: .informational)
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
        present(message: "Binding ⌘ + ctrl + P is now set in Xcode.", style: .informational)
    }
    
    private func position(in bindings:NSMutableArray) -> Int {
        let binds = bindings as! [NSDictionary]
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
        do {
            try FileManager.default.copyItem(atPath: vanillaPlistPath, toPath: path)
            present(message: "Binding ⌘ + ctrl + P is now set in Xcode.", style: .informational)
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
