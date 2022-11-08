//
//  ErrorViewController.swift
//  MCTSampleApp
//

import UIKit

class ErrorViewController: UIViewController {
    
    var error: String? {
        didSet {
            guard self.isViewLoaded else { return }
            self.textView.text = error
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = error
    }
}
