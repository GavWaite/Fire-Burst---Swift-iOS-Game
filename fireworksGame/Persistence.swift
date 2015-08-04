//
//  Persistence.swift
//  fireworksGame
//
//  Created by Daniel Bromberg on 7/20/15
//  Used by Gavin Waite on 7/28/15
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation

class SuperSimpleSave: NSObject, NSCoding {
    var savedScores = [String : Int]()
    var soundMute: Bool = false
    
    // because we're inheriting from NSObject, must override
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        // Awaken from our custom persisted object on device filesystem
        savedScores = aDecoder.decodeObjectForKey("savedScores") as! [String : Int]
        soundMute = aDecoder.decodeObjectForKey("soundMute") as! Bool
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(savedScores, forKey: "savedScores")
        aCoder.encodeObject(soundMute, forKey: "soundMute")
    }
}

class Persistence {
    static let ModelFileName = "savedScores.serialized"
    static let FileMgr = NSFileManager.defaultManager()
    
    static var path: String? {
        // Important: searchpath API
        if let dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true) as? [String] where dirPaths.count > 0 {
            // "/var/db/43234-ABC2345-2345/Library/Application Support"
            if !FileMgr.fileExistsAtPath(dirPaths[0]) && !mkdir(dirPaths[0]) {
                return nil
            }
            return dirPaths[0].stringByAppendingPathComponent(ModelFileName)
        }
        return nil
    }
    
    // think of it as black box to create a directory on iOS filesystem
    static func mkdir(newDirPath: String) -> Bool {
        var createDirErr: NSError?
        let createDirRes = FileMgr.createDirectoryAtPath(newDirPath, withIntermediateDirectories: false, attributes: nil, error: &createDirErr)
        if let err = createDirErr where !createDirRes {
            println("Could not create directory: \(err.localizedDescription)")
            return false
        }
        return true
    }
    
    // Rather than using full hierarchical capabilities of NSKeyedArchiver,
    // just one object, so it's the "root" object of the file
    static func save(model: NSObject) -> Bool {
        var success = false
        if let savePath = Persistence.path {
            // Important: archiving step
            success = NSKeyedArchiver.archiveRootObject(model, toFile: savePath)
            println("saved model success: \(success) at \(NSDate()) to path: \(savePath)")
        }
        return success
    }
    
    static func restore() -> NSObject? {
        if let savePath = Persistence.path {
            if let rawData = NSData(contentsOfFile: savePath) {
                // rawData is the bytes on disk to transform into the object previously
                // saved
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: rawData)
                // Important: unarchiving
                if let model = unarchiver.decodeObjectForKey("root") as? NSObject {
                    println("restored model successfully at \(NSDate())")
                    return model
                }
                else {
                    println("Could not decode object at \(NSDate())")
                }
            }
            else {
                println("could not load data file \(savePath)")
            }
        }
        return nil
    }
    
}