//
//  TaskPresentationViewController.swift
//  RSDCatalog
//

import UIKit
import ResearchUI
import JsonModel
import Research
import MotionSensor
import MotorControlV1
import MobilePassiveData

/// The data storage manager in this case is used to show a sample usage. As such, the data will not be
/// shared to user defaults but only in local memory.
class DataStorageManager : NSObject, RSDDataStorageManager {
    
    static let shared = DataStorageManager()
    
    var taskData: [RSDIdentifier : RSDTaskData] = [:]
    
    func previousTaskData(for taskIdentifier: RSDIdentifier) -> RSDTaskData? {
        return taskData[taskIdentifier]
    }
    
    func saveTaskData(_ data: RSDTaskData, from taskResult: RSDTaskResult?) {
        taskData[RSDIdentifier(rawValue: data.identifier)] = data
    }
}

class TaskPresentationViewController: UITableViewController, RSDTaskViewControllerDelegate {
    
    var taskInfo: RSDTaskInfo!
    var result: ResultData?
    let archiveManager = ArchiveManager()
    var firstAppearance: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppearance, (self.result == nil), let taskInfo = self.taskInfo {
            let taskViewModel = RSDTaskViewModel(taskInfo: taskInfo)
            taskViewModel.dataManager = DataStorageManager.shared
            let taskViewController = RSDTaskViewController(taskViewModel: taskViewModel)
            taskViewController.delegate = self
            self.present(taskViewController, animated: true, completion: nil)
        }
        firstAppearance = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ResultTableViewController, let result = self.result {
            vc.result = result
            vc.title = vc.result!.identifier
            vc.navigationItem.title = vc.title
        }
        else if let vc = segue.destination as? TaskArchivesTableViewController {
            vc.archiveManager = self.archiveManager
            vc.title = self.title
            vc.navigationItem.title = vc.title
        }
        else if let vc = segue.destination as? ErrorViewController, let error = sender as? String {
            vc.error = error
        }
    }
    
    // MARK: - RSDTaskControllerDelegate
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        // populate the results
        self.result = taskController.taskViewModel.taskResult
        self.tableView.reloadData()
        
        // dismiss the view controller
        (taskController as? UIViewController)?.dismiss(animated: true) {
        }
        
        var debugResult: String = self.result!.identifier
        debugResult.append("\n\n=== Completed: \(reason) error:\(String(describing: error))")
        print(debugResult)
        
        // - note: The calling application is responsible for deleting the output directory once the files
        // are processed by encrypting them locally. The encrypted files can then be stored for upload
        // to a server or cloud service. These files are **not** encrypted so depending upon the
        // application, there is a risk of exposing PII data stored in these files.
        // For a production app, the cleanup method should be called for for the case where the participant
        // has exited the task early, cancelled the task, or there was a failure. Additionally, if using the
        // task result directly rather than the archiving the data using the archiving protocols, the cleanup
        // method should be called following upload either here or from `readyToSave`. syoung 04/22/2019
        //
        // taskController.taskViewModel.cleanup()
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        print("\n\n=== Ready to Save: \(taskViewModel.description)")
        
        // Inspect the result.
        self.inspectResult(taskViewModel.taskResult)
        
        taskViewModel.archiveResults(with: self.archiveManager) { _ in
            // The archive manager does not call completion because that deletes the result
            // and then the result cannot be displayed. Therefore, this completion handler
            // is never called. syoung 09/17/2019
        }
    }
    
    func taskViewController(_ taskViewController: UIViewController, shouldShowTaskInfoFor step: Any) -> Bool {
        // TODO: syoung 01/18/2019 clean up JSON and Factory stuff for showing the intro step.
        return false
    }
    
    // MARK: Custom code for inspecting the motion control tasks.
    
    func inspectResult(_ taskResult: RSDTaskResult) {
        guard let taskIdentifier = MCTTaskIdentifier(rawValue: taskResult.identifier)
            else {
                showError("Task identifier not recognized. \(taskResult.identifier)")
                return
        }
        DispatchQueue.global().async {
            // Inspect the results for expected values.
            switch taskIdentifier {
            case .kineticTremor, .tapping, .tremor:
                self.inspectTwoHandTaskResult(taskIdentifier: taskIdentifier, taskResult: taskResult)
            case .walk30Seconds, .walkAndBalance:
                self.inspectWalkTaskResult(taskIdentifier: taskIdentifier, taskResult: taskResult)
            }
        }
    }
    
    func inspectTwoHandTaskResult(taskIdentifier: MCTTaskIdentifier, taskResult: RSDTaskResult) {
        guard let handSelectionResult = taskResult.findResult(with: MCTHandSelectionDataSource.selectionKey) as? CollectionResult,
            let handOrder = handSelectionResult.findAnswer(with: MCTHandSelectionDataSource.handOrderKey)?.value as? [String]
            else {
                showError("Could not find expected hand selection result in \(taskResult)")
                return
        }
        self.inspectMotionRecords(for: handOrder, in: taskResult)
    }
    
    func inspectWalkTaskResult(taskIdentifier: MCTTaskIdentifier, taskResult: RSDTaskResult) {
        let resultIds = (taskIdentifier == .walkAndBalance) ? ["walk","balance"] : ["walk"]
        self.inspectMotionRecords(for: resultIds, in: taskResult)
    }
    
    func inspectMotionRecords(for identifiers: [String], in taskResult: RSDTaskResult) {
        for identifier in identifiers {
            guard let sectionResult = taskResult.findResult(with: identifier) as? RSDTaskResult
                else {
                    showError("Missing section result for \(identifier) in \(taskResult)")
                    return
            }
            guard let motionResult = sectionResult.asyncResults?.first(where: { $0.identifier == "motion" }) as? FileResult
                else {
                    showError("Missing motion result for \(sectionResult.identifier) in \(sectionResult)")
                    return
            }
            guard let url = motionResult.url
                else {
                    showError("The motion result for \(sectionResult.identifier) did not have a url")
                    return
            }
            do {
                let jsonDecoder = MCTFactory.shared.createJSONDecoder()
                let data = try Data(contentsOf: url)
                let records = try jsonDecoder.decode([MotionRecord].self, from: data)
                guard let startTime = records.first?.timestamp, let endTime = records.last?.timestamp
                    else {
                        showError("The motion result for \(sectionResult.identifier) was empty")
                        return
                }
                let delta = endTime - startTime
                if delta < 29.0 || delta > 35.0 {
                    showError("The delta time for the recording was not within expected bounds. delta=\(delta), startTime=\(startTime), endTime=\(endTime)")
                }
                else {
                    print("\(identifier)_motion=\(delta)")
                }
            }
            catch let err {
                showError("Failed to decode the motion record for \(sectionResult.identifier): \(err)")
            }
        }
    }
    
    func showError(_ error: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showError", sender: error)
        }
    }
}
