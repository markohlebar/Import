//
//  AddImportOperation.swift
//  Import
//
//  Created by Marko Hlebar on 05/10/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

import XcodeKit
import AppKit

fileprivate struct AddImportOperationConstants {
    
    /// Import matchers
    static let objcImport = ".*#.*(import|include).*[\",<].*[\",>]"
    static let objcModuleImport = ".*@.*(import).*.;"
    static let swiftModuleImport = ".*(import) +.*."
    static let objcClassForwardDeclaration = ".*@.*(class).*.;"
    
    /// Double import strings
    /// Note: For the `doubleImportWarningString` string, we're using a non-breaking space (\u00A0), not a normal space
    static let doubleImportWarningString = "🚨 This import has already been included 🚨"
    
    static let cancelRemoveImportButtonString = "Okay"
}

class AddImportOperation {

    let buffer: XCSourceTextBuffer
    
    let completionHandler: (Error?) -> Void
    
    lazy var importRegex = try! NSRegularExpression(pattern: AddImportOperationConstants.objcImport, options: NSRegularExpression.Options(rawValue: UInt(0)))
    lazy var moduleImportRegex = try! NSRegularExpression(pattern: AddImportOperationConstants.objcModuleImport, options: NSRegularExpression.Options(rawValue: UInt(0)))
    lazy var swiftModuleImportRegex = try! NSRegularExpression(pattern: AddImportOperationConstants.swiftModuleImport, options: NSRegularExpression.Options(rawValue: UInt(0)))
    lazy var objcClassForwardDeclarationRegex = try! NSRegularExpression(pattern: AddImportOperationConstants.objcClassForwardDeclaration, options: NSRegularExpression.Options(rawValue: UInt(0)))

    var lineToRemove: Int = NSNotFound
    
    init(with buffer:XCSourceTextBuffer, completionHandler: @escaping (Error?) -> Void) {
        self.buffer = buffer
        
        self.completionHandler = completionHandler
    }
    
    func execute() {
        let selection = self.buffer.selections.firstObject as! XCSourceTextRange
        let selectionLine = selection.start.line
        let importString = (self.buffer.lines[selectionLine] as! String).trimmingCharacters(in: CharacterSet.whitespaces)
        
        guard isValid(importString: importString) else {
            self.completionHandler(nil)
            return
        }
        let line = appropriateLine(ignoringLine: selectionLine)
        guard line != NSNotFound else {
            self.completionHandler(nil)
            return
        }
        
        guard self.buffer.canIncludeImportString(importString, atLine: line) else {
            
            // we need to run this on the main thread since we're getting called on a seconday thread
            
            OperationQueue.main.addOperation({
                
                self.lineToRemove = selectionLine
                
                let doubleImportAlert = NSAlert()
                
                let importAppIcon = #imageLiteral(resourceName: "ImportIcon");

                doubleImportAlert.icon = importAppIcon
                
                doubleImportAlert.messageText = AddImportOperationConstants.doubleImportWarningString

                doubleImportAlert.addButton(withTitle: AddImportOperationConstants.cancelRemoveImportButtonString)
                
                // We're creating a "fake" view so that the text doesn't wrap on two lines
                let fakeRect: NSRect = NSRect.init(x: 0, y: 0, width: 307, height: 0)
                
                let fakeView = NSView.init(frame: fakeRect)
                
                doubleImportAlert.accessoryView = fakeView
                
                NSBeep()

                let frontmostApplication = NSWorkspace.shared().frontmostApplication
                
                let appWindow = doubleImportAlert.window
                
                appWindow.makeKeyAndOrderFront(appWindow)
                
                NSApp.activate(ignoringOtherApps: true)
                
                let response = doubleImportAlert.runModal()
                
                if (response == NSAlertFirstButtonReturn) {
                    
                    let currentPosition = XCSourceTextPosition(line: selectionLine, column: 0)
                    
                    let updatedSelection = XCSourceTextRange(start: currentPosition, end: currentPosition)
                    
                    self.buffer.lines.removeObject(at: self.lineToRemove)
                    
                    self.buffer.selections.setArray([updatedSelection])
                }
                
                NSApp.deactivate()
                
                frontmostApplication?.activate(options: NSApplicationActivationOptions(rawValue: 0))
                
                self.completionHandler(nil)
            })
            
            return
        }
        
        self.buffer.lines.removeObject(at: selectionLine)
        self.buffer.lines.insert(importString, at: line)
        
        //add a new selection. Bug fix for #7
        let currentPosition = XCSourceTextPosition(line: selectionLine, column: 0)
        
        let updatedSelection = XCSourceTextRange(start: currentPosition, end: currentPosition)

        self.buffer.selections.setArray([updatedSelection])
        
        self.completionHandler(nil)
    }
    
    func isValid(importString: String) -> Bool {
        var numberOfMatches = 0
        let matchingOptions = NSRegularExpression.MatchingOptions(rawValue: UInt(0))
        let range = NSMakeRange(0, importString.characters.count)
        
        if buffer.isSwiftSource {
            numberOfMatches = swiftModuleImportRegex.numberOfMatches(in: importString, options: matchingOptions, range: range)
        }
        else {
            numberOfMatches = importRegex.numberOfMatches(in: importString, options: matchingOptions, range: range)
            numberOfMatches = numberOfMatches > 0 ? numberOfMatches : moduleImportRegex.numberOfMatches(in: importString, options: matchingOptions, range: range)
            numberOfMatches = numberOfMatches > 0 ? numberOfMatches : objcClassForwardDeclarationRegex.numberOfMatches(in: importString, options: matchingOptions, range: range)
        }
        
        return numberOfMatches > 0
    }
    
    func appropriateLine(ignoringLine: Int) -> Int {
        var lineNumber = NSNotFound
        let lines = buffer.lines as NSArray as! [String]
        
        //Find the line that is first after all the imports
        for (index, line) in lines.enumerated() {
            if index == ignoringLine {
                continue
            }
            
            if isValid(importString: line) {
                lineNumber = index
            }
        }
        
        guard lineNumber == NSNotFound else {
            return lineNumber + 1
        }
        
        //if a line is not found, find first free line after comments
        for (index, line) in lines.enumerated() {
            if index == ignoringLine {
                continue
            }
            
            lineNumber = index
            if line.isWhitespaceOrNewline() {
                break
            }
        }
        
        return lineNumber + 1
    }
}

fileprivate extension XCSourceTextBuffer {
    
    var isSwiftSource: Bool {
        return self.contentUTI == "public.swift-source"
    }

    /// Checks if the import string isn't already contained in the import list
    ///
    /// - Parameters:
    ///   - importString: The import statement to include
    ///   - atLine: The line where the import should be done. This is to check from lines 0 to atLine
    /// - Returns: true if the statement isn't already included, false if it is
    func canIncludeImportString(_ importString: String, atLine: Int) -> Bool {
        
        let importBufferArray = self.lines.subarray(with: NSMakeRange(0, atLine)) as NSArray as! [String]
        
        return importBufferArray.contains(importString) == false
    }
}

fileprivate extension String {
    
    func isWhitespaceOrNewline() -> Bool {
        let string = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return string.characters.count == 0
        
    }
}
