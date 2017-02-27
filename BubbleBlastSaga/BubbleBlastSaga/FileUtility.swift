//
//  FileUtility.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 27/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

class FileUtility {
    
    static func getFileURL(for name: String, and fileExtension: String) -> URL {
        // Get the URL of the Documents Directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Get the URL for a file in the Documents Directory
        return documentDirectory.appendingPathComponent(name).appendingPathExtension(fileExtension)
    }
    
}
