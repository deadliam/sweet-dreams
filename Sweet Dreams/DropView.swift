//
//  DropView.swift
//  Sweet Dreams
//
//  Created by Anatolii Kasianov on 27.08.2022.
//

import Cocoa

class DropView: NSView {
    
    var onDrop: ((String) -> Void)?
    
    var rawImagesPath: String = ""
    
//    let expectedExt = ["jpeg"]  //file extensions allowed for Drag&Drop (example: "jpg","png","docx", etc..)

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.0).cgColor

        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkPath(sender) == true {
            self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.3).cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }

    fileprivate func checkPath(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String
        else { return false }
//        let suffix = URL(fileURLWithPath: path).pathExtension
//        for ext in self.expectedExt {
//            if ext.lowercased() == suffix {
//                return true
//            }
//        }
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            } else {
                // file exists and is not a directory
            }
        }
        return false
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.0).cgColor
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.0).cgColor
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = pasteboard[0] as? String
        else { return false }
        
        print("FilePath: \(path)")
        onDrop?(path)
        
        return true
    }
}

