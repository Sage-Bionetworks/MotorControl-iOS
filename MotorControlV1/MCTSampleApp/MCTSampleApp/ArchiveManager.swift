//
//  ArchiveManager.swift
//  RSDCatalog
//

import Foundation
import Research
import JsonModel

public class ArchiveManager : NSObject, RSDDataArchiveManager {
        
    public var dataArchives = [DataArchive]()
    
    public func shouldContinueOnFail(for archive: RSDDataArchive, error: Error) -> Bool {
        return false
    }
    
    public func dataArchiver(for taskResult: RSDTaskResult, scheduleIdentifier: String?, currentArchive: RSDDataArchive?) -> RSDDataArchive? {
        if currentArchive != nil {
            return currentArchive
        } else {
            let dataArchive = DataArchive(identifier: taskResult.identifier)
            dataArchives.append(dataArchive)
            return dataArchive
        }
    }
    
    public func encryptAndUpload(taskResult: RSDTaskResult, dataArchives: [RSDDataArchive], completion: @escaping (() -> Void)) {
        // Do nothing - this is only to test that archiving doesn't blow up. For an actual app, this archive manager would be
        // replaced with a manager that can handle the upload services.
        // For a production application (rather than the sample app), the completion handler should be called to hand off
        // back to the task state to manage cleanup. Because the sample app allows for inspection of the files
        // used by this app to store data, the completion is not being called here.
        // completion()
    }
    
    public func handleArchiveFailure(taskResult: RSDTaskResult, error: Error, completion: @escaping (() -> Void)) {
        debugPrint("Failed to archive \(taskResult) : \(error)")
    }
}

public class DataArchive : NSObject, RSDDataArchive {

    public let identifier: String
    public var scheduleIdentifier: String?
    
    public var files = [URL]()
    public var manifestList = [RSDFileManifest]()
    
    public var outputDirectory: URL! = {
        let tempDir = NSTemporaryDirectory()
        let formatter = ISO8601DateFormatter()
        let dir = RSDFileResultUtility.filename(for: formatter.string(from: Date()))
        let path = (tempDir as NSString).appendingPathComponent(dir)
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [ .protectionKey : FileProtectionType.completeUntilFirstUserAuthentication ])
            } catch let error as NSError {
                print ("Error creating file: \(error)")
                return nil
            }
        }
        return URL(fileURLWithPath: path, isDirectory: true)
    }()
    
    public var isComplete = false
    
    public init(identifier: String) {
        self.identifier = identifier
        super.init()
    }
    
    public func shouldInsertData(for filename: RSDReservedFilename) -> Bool {
        return true
    }
    
    public func archivableData(for result: ResultData, sectionIdentifier: String?, stepPath: String?) -> RSDArchivable? {
        return result as? RSDArchivable
    }
    
    public func insertDataIntoArchive(_ data: Data, manifest: RSDFileManifest) throws {
        guard !isComplete, !self.manifestList.contains(manifest) else {
            assertionFailure("Failed to add \(manifest.filename) : \(manifest)")
            return
        }
        let filename = manifest.filename
        let url = self.outputDirectory.appendingPathComponent(filename)
        try data.write(to: url)
        if manifest.filename == "answers.json" {
            let json = String(data: data, encoding: .utf8)
            #if DEBUG
                print("answers.json:\n\(json!)")
            #endif
        }
        DispatchQueue.main.async {
            self.manifestList.append(manifest)
            self.files.append(url)
        }
    }
    
    public func completeArchive(with metadata: RSDTaskMetadata) throws {
        let encoder = RSDFactory.shared.createJSONEncoder()
        let jsonData = try encoder.encode(metadata)
        let json = String(data: jsonData, encoding: .utf8)
        #if DEBUG
        print("Archive complete. outputDirectory: \(String(describing: outputDirectory))\n\n\(json!)")
        #endif
        isComplete = true
    }
}
