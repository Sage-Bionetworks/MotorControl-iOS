//
//  FileResultViewController.swift
//  RSDCatalog
//

import UIKit
import ResearchUI
import Research
import JsonModel
import AVKit
import AVFoundation

class FileResultViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var result: FileResult?
    var firstAppearance: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.isHidden = true
        self.imageView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard firstAppearance else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        firstAppearance = false
        
        guard let url = result?.url else {
            self.textView.isHidden = false
            self.textView.text = "No URL to open."
            return
        }

        do {
            if url.pathExtension == "jpeg" {
                self.imageView.isHidden = false
                let data = try Data(contentsOf: url)
                self.imageView.image = UIImage(data: data)
            }
            else if url.pathExtension == "mov" {
                let player = AVPlayer(url: url)
                let playerController = AVPlayerViewController()
                playerController.player = player
                present(playerController, animated: true) {
                    player.play()
                }
            }
            else {
                self.textView.isHidden = false
                self.textView.text = try String(contentsOf: url)
            }
        } catch let err {
            self.textView.isHidden = false
            self.textView.text = "Failed to open file: \(err)"
        }
    }
}
