//
//  ViewController.swift
//  DemoApp
//
//  Created by SENTHIL KUMAR on 08/06/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sslPinningButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentBaseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as! String
        print("currentBaseURL--->>", currentBaseURL)
    }
    @IBAction func nextVCButtonAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckSSLPinningViewController") as? CheckSSLPinningViewController
        self.navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
}

