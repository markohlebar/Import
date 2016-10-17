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
    
    /// Warning strings
    static let doubleImportWarningString = " // 🚨 This import has already been included 🚨"
    static let doubleImportRemoveInstructionsString = "// ☝️ again to remove duplicate"
}

class AddImportOperation {

    let buffer: XCSourceTextBuffer
    
    lazy var importRegex = try! NSRegularExpression(pattern: AddImportOperationConstants.objcImport, options: NSRegularExpression.Options(rawValue: UInt(0)))
    lazy var moduleImportRegex = try! NSRegularExpression(pattern: AddImportOperationConstants.objcModuleImport, options: NSRegularExpression.Options(rawValue: UInt(0)))
    lazy var swiftModuleImportRegex = try! NSRegularExpression(pattern: AddImportOperationConstants.swiftModuleImport, options: NSRegularExpression.Options(rawValue: UInt(0)))

    init(with buffer:XCSourceTextBuffer) {
        self.buffer = buffer
    }
    
    func execute() {
        let selection = self.buffer.selections.firstObject as! XCSourceTextRange
        let selectionLine = selection.start.line
        let importString = (self.buffer.lines[selectionLine] as! String).trimmingCharacters(in: CharacterSet.whitespaces)
        
        guard isValid(importString: importString) else {
            return
        }
        let line = appropriateLine(ignoringLine: selectionLine)
        guard line != NSNotFound else {
            return
        }

        guard self.buffer.canIncludeImportString(importString, atLine: line) else {

            if let potentialRemovalInstructionsString = self.buffer.lines[selectionLine + 1] as? String {
                
                if (potentialRemovalInstructionsString.trimmingCharacters(in: CharacterSet.newlines) == AddImportOperationConstants.doubleImportRemoveInstructionsString)
                {
                    self.buffer.lines.removeObjects(in: NSMakeRange(selectionLine, 2))
                    
                    return
                }
                
            }
            
            NSBeep()
            
            let importStatementString = self.buffer.lines[selectionLine] as! String
            
            let commentedString = importStatementString.trimmingCharacters(in: CharacterSet.newlines).appending(AddImportOperationConstants.doubleImportWarningString)
            
            self.buffer.lines[selectionLine] = commentedString

            self.buffer.lines.insert(AddImportOperationConstants.doubleImportRemoveInstructionsString, at: selectionLine + 1)

            
            
            return
        }
        
        self.buffer.lines.removeObject(at: selectionLine)
        self.buffer.lines.insert(importString, at: line)
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
        
        var sanitizedImportString: String = importString

        if let range = importString.range(of: "//"), !range.isEmpty {
            
            sanitizedImportString = importString.substring(to: range.lowerBound)
        }
        
        sanitizedImportString = sanitizedImportString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if let range = importString.rangeOfCharacter(from: CharacterSet.newlines), !range.isEmpty {
            sanitizedImportString.append("\n")
        }
        
        return importBufferArray.contains(sanitizedImportString) == false
    }
}

fileprivate extension String {
    
    func isWhitespaceOrNewline() -> Bool {
        let string = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return string.characters.count == 0
        
    }
}
