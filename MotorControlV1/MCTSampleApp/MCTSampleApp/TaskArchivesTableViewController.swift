//
//  TaskArchivesTableViewController.swift
//  RSDCatalog
//

import UIKit
import ResearchUI
import Research
import JsonModel

class TaskArchivesTableViewController: UITableViewController {
    
    var archiveManager: ArchiveManager!

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.archiveManager?.dataArchives.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let archives = self.archiveManager?.dataArchives, section < archives.count else { return 0 }
        return archives[section].files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "file", for: indexPath) as! ImageTableViewCell
        let file = self.archiveManager.dataArchives[indexPath.section].files[indexPath.item]
        cell.titleLabel?.text = file.lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let archive = self.archiveManager.dataArchives[section]
        return archive.identifier
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) else {
                return
        }
        
        let archive = self.archiveManager.dataArchives[indexPath.section]
        let file = archive.files[indexPath.item]
        if let vc = segue.destination as? FileResultViewController {
            vc.result = FileResultObject(identifier: file.lastPathComponent, url: file)
            vc.title = vc.result!.identifier
            vc.navigationItem.title = vc.title
        }
    }

}
