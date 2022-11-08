//
//  TaskTableViewController.swift
//  RSDCatalog
//

import UIKit
import Research
import MotorControlV1

class TaskTableViewController: UITableViewController {
    
    public let taskList: [MCTTaskInfo] = MCTTaskIdentifier.allCases.map { MCTTaskInfo($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use automatic hieght dimension
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        flushTempDirectory()
    }
    
    /// Flush the temporary directory contents.
    /// For the example app, we want to leave the output directory untouched *until*
    /// this view controller appears. For a *real* application, the output directory
    /// that is used to store temporary results should be flushed as soon as the task
    /// is completed and the results are encrypted. This is because the results of the
    /// task could include private health data so it is important to handle these results
    /// using a secure method.
    func flushTempDirectory() {
        do {
            let fileManager = FileManager.default
            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let directories = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil, options: [])
            for outputDirectory in directories {
                try FileManager.default.removeItem(at: outputDirectory)
            }
        } catch let error {
            print("Error removing output directory: \(error.localizedDescription)")
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) as! ImageTableViewCell
        let taskInfo = taskList[indexPath.row]
        cell.titleLabel?.text = taskInfo.title
        cell.subtitleLabel?.text = taskInfo.subtitle
        if let imageView = cell.thumbnailView, let icon = taskInfo.icon {
            imageView.image = icon.embeddedImage()
        }
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell),
            let vc = segue.destination as? TaskPresentationViewController
            else {
                return
        }
        let taskInfo = taskList[indexPath.row]
        vc.taskInfo = taskInfo
        vc.title = taskInfo.title ?? taskInfo.identifier
        vc.navigationItem.title = vc.title
    }
}

class ImageTableViewCell : UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
}
