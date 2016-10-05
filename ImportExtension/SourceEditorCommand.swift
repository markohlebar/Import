//
//  SourceEditorCommand.swift
//  ImportExtension
//
//  Created by Marko Hlebar on 04/10/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        let operation = AddImportOperation(with: invocation.buffer)
        operation.execute()
        
        completionHandler(nil)
    }
}

