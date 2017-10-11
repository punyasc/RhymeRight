//
//  SettingsTableViewController.swift
//  LyricLab
//
//  Created by Punya Chatterjee on 10/3/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    
    @IBOutlet var fontStepper: UIStepper!
    @IBOutlet var fontSizeLabel: UILabel!
    @IBOutlet var acSwitch: UISwitch!
    @IBAction func switchToggled(_ sender: Any) {
        UserDefaults.standard.set(acSwitch.isOn, forKey: "EnableAutocorrect")
    }
    
    @IBAction func fontStepped(_ sender: UIStepper) {
        fontSizeLabel.text = "\(fontStepper.value) pt"
        UserDefaults.standard.set(fontStepper.value, forKey: "FontSize")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        acSwitch.isOn = UserDefaults.standard.bool(forKey: "EnableAutocorrect")
        if UserDefaults.standard.object(forKey: "FontSize") == nil {
            if UIDevice.current.userInterfaceIdiom == .pad {
                UserDefaults.standard.set(22.0, forKey: "FontSize")
            } else {
                UserDefaults.standard.set(17.0, forKey: "FontSize")
            }
            
        }
        fontStepper.value = Double(UserDefaults.standard.float(forKey: "FontSize"))
        fontSizeLabel.text = "\(fontStepper.value) pt"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let email = "punya@stanford.edu"
            if let mailurl = URL(string: "mailto:\(email)") {
                UIApplication.shared.openURL(mailurl)
            }
        }
    }
    
}
