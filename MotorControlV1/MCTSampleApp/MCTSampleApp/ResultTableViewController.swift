//
//  ResultTableViewController.swift
//  RSDCatalog
//

import UIKit
import ResearchUI
import JsonModel
import Research

class ResultTableViewController: UITableViewController {

    var result: ResultData!

    // MARK: - Table view data source
    
    func results(in section: Int) -> [ResultData] {
        if let collectionResult = result as? CollectionResult {
            return collectionResult.children
        } else if let taskResult = result as? RSDTaskResult {
            if section == 0 {
                return taskResult.stepHistory
            } else {
                return taskResult.asyncResults ?? []
            }
        } else {
            return []
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = result as? CollectionResult {
            return 1
        } else if let taskResult = result as? RSDTaskResult {
            return (taskResult.asyncResults?.count ?? 0) > 0 ? 2 : 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results(in: section).count
    }
    
    enum ReuseIdentifier : String {
        case base
        case answer
        case file
        case section
        case error
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageTableViewCell
        let result = results(in: indexPath.section)[indexPath.row]
        if let answerResult = result as? AnswerResult {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.answer.stringValue, for: indexPath) as! ImageTableViewCell
            cell.subtitleLabel?.text = answerResult.value != nil ? String(describing: answerResult.value!) : "nil"
        } else if let fileResult = result as? FileResult {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.file.stringValue, for: indexPath) as! ImageTableViewCell
            cell.subtitleLabel?.text = fileResult.url != nil ? String(describing: fileResult.url!.lastPathComponent) : "nil"
        } else if (result is CollectionResult) || (result is RSDTaskResult) {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.section.stringValue, for: indexPath) as! ImageTableViewCell
        } else if let errorResult = result as? ErrorResult {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.error.stringValue, for: indexPath) as! ImageTableViewCell
            cell.subtitleLabel?.text = errorResult.errorDescription
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.base.stringValue, for: indexPath) as! ImageTableViewCell
        }
        cell.titleLabel?.text = result.identifier
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let _ = result as? CollectionResult {
            return result.identifier
        }
        else {
            return section == 0 ? "stepHistory" : "asyncResults"
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) else {
                return
        }
        
        if let vc = segue.destination as? ResultTableViewController {
            vc.result = results(in: indexPath.section)[indexPath.row]
            vc.title = vc.result!.identifier
            vc.navigationItem.title = vc.title
        }
        else if let vc = segue.destination as? FileResultViewController {
            vc.result = results(in: indexPath.section)[indexPath.row] as? FileResult
            vc.title = vc.result!.identifier
            vc.navigationItem.title = vc.title
        }
    }
}
