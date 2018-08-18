//
//  SupportLibs.swift
//  WatchConnectManager
//
//  Created by Takuji Hori on 2018/07/06.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit

class Logger {
    
    class func debug (message: String = "") {
        NSLog("debug: \(message)")
    }
    class func info (message: String = "") {
        NSLog("info: \(message)")
    }
    class func warning (message: String = "") {
        NSLog("warning: \(message)")
    }
    class func error (message: String = "") {
        NSLog("error: \(message)")
    }
}

class Misc {
    static func unitSizeString(size: Int) -> String {
        var unit = ""
        var Size = size
        switch Size {
        case 0..<1024:
            unit = "b"
        case 1024..<(1024*1024):
            Size = Size / 1024
            unit = "k"
        case (1024*1024)..<(1024*1024*1024):
            Size = Size / (1024*1024)
            unit = "m"
        default:
            unit = "Size Error"
        }
        return String(Size) + unit
    }
    
    static func elapsedTimeString(startDate: Date) -> String {
        let timeInterval = Date().timeIntervalSince(startDate)
        let time = Int(timeInterval)
        let d = time / 86400
        let h = time / 3600 % 24
        let m = time / 60 % 60
        let s = time % 60
        let ms = Int(timeInterval * 100) % 100
//        return String(format: "%02d:%02d:%02d:%02d.%02d",d. h, m, s, ms)
        return String(format: "%01d.%02d", s, ms)
    }
}

public class FileHelper {
//
    static func temporaryDirectory() -> String {
        return NSTemporaryDirectory()
    }

    // tmp/fileName
    static func temporaryDirectoryWithFileName(fileName: String) -> String {
        return temporaryDirectory().stringByAppendingPathComponent(path: fileName)
    }

    static func fileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    static func fileSizePath(path: String) -> Int? {
        if fileExists(path: path) == false {
            return nil
        }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            return Int(attributes.fileSize())
        }
        catch let error as NSError {
            NSLog ("File size error: \(error.localizedDescription) \(path)")
            return nil
        }
    }

    static func readFileWithData(path: String) -> Data? {
        if fileExists(path: path) == false {
            return nil
        }
        guard let fileHandle = FileHandle(forReadingAtPath: path) else {
            return nil
        }

        let data = fileHandle.readDataToEndOfFile()
        fileHandle.closeFile()
        return data
    }

    static func copyFile(fromPath: String, toPath: String) -> Bool {
        do {
            try FileManager.default.copyItem(atPath: fromPath, toPath: toPath)
            return true
        } catch let error as NSError {
            print ("File copy error: \(error.localizedDescription) \(fromPath) \(toPath)")
            return false
        }
    }
}


class RandomMaker {
    
    static func randomNumIntegerWithLimits(lower:Int, upper:Int) -> Int {
        assert(upper > lower, "randomNumIntegerWithLimits: lower/upper are negative")
        let random : Int = Int(arc4random_uniform(UInt32(upper - lower + 1)))
        return random + lower
    }
    
    static func randomStringWithLength(_ len:Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var result:String = ""
        assert(len >= 0, "randomStringWithLength: error length 0 error")
        for _ in 0..<len {
            let startindex = letters.characters.index(letters.startIndex, offsetBy: Int(arc4random_uniform(UInt32(letters.characters.count))))
            let endindex = letters.index(startindex, offsetBy: 1)
            result += letters.substring(with: startindex..<endindex)
        }
        return result
    }
    
}

let dateformatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "M/dd HH:mm:ss"
    return f
}()

let dateformatter2: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm:ss"
    return f
}()

extension String {

    private var ns: NSString {
        return (self as NSString)
    }

    func stringByAppendingPathComponent(path: String) -> String {
        return ns.appendingPathComponent(path)
    }
    
    public var lastPathComponent: String {
        return ns.lastPathComponent
    }

    public var deletingPathExtension: String {
        return ns.deletingPathExtension
    }
}
