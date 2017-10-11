//
//  SongListTableViewController.swift
//  LyricLab
//
//  Created by Punya Chatterjee on 10/2/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import AlertOnboarding

class SongListTableViewController: UITableViewController {
    
    let fm = FileManager.default
    var songsDirectory: URL?
    var chosenFileUrl: String?
    var fileUrls: [String] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chosenFileUrl = nil
        let docsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        songsDirectory = docsDirectory.appendingPathComponent("songs", isDirectory: true)
        if !fm.fileExists(atPath: songsDirectory!.path) {
            print("SongList: creating directory")
            try! fm.createDirectory(at: songsDirectory!, withIntermediateDirectories: true, attributes: nil)
        } else {
            print("SongList: directory found")
            fileUrls = try! fm.contentsOfDirectory(atPath: songsDirectory!.path)
            print("SongList: \(fileUrls.count) files in the directory")
            //print("SongList: \(fileUrls[0].path)")
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserDefaults.standard.bool(forKey: "HideOnboard") {
            showOnboardAlert()
            UserDefaults.standard.set(true, forKey: "HideOnboard")
        }
        navigationItem.leftBarButtonItem = editButtonItem
        chosenFileUrl = nil
        let docsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        songsDirectory = docsDirectory.appendingPathComponent("songs", isDirectory: true)
        if !fm.fileExists(atPath: songsDirectory!.path) {
            print("SongList: creating directory")
            try! fm.createDirectory(at: songsDirectory!, withIntermediateDirectories: true, attributes: nil)
        } else {
            print("SongList: directory found")
            let fileUrls = try! fm.contentsOfDirectory(atPath: songsDirectory!.path)
            self.tableView.reloadData()
        }
    }
    
    func showOnboardAlert() {
        
        var arrayOfImage = ["RhymeRightLogoNoBg", "onloadAB", "onloadRhymes"]
        var arrayOfTitle = ["WELCOME", "LINE NUMBERS", "RHYME SUGGESTIONS"]
        var arrayOfDescription = ["RhymeRight is a note app built for writing song lyrics.",
                                  "Lines are numbered according to the AABB rhyme scheme, meaning lines rhyme in pairs.",
                                  "If you're on the second line of a pair, rhyme suggestions will appear above the keyboard."]
        
        //Call AlertOnboarding
        var alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        
        //Modify background color of AlertOnboarding
        alertView.colorForAlertViewBackground = UIColor(red:0.10, green:0.41, blue:0.61, alpha:1.0)
        
        //Modify colors of AlertOnboarding's button
        alertView.colorButtonText = UIColor.white
        alertView.colorButtonBottomBackground = UIColor(red:0.08, green:0.31, blue:0.45, alpha:1.0)
        
        //Modify colors of labels
        alertView.colorTitleLabel = UIColor.white
        alertView.colorDescriptionLabel = UIColor.white
        
        //Modify colors of page indicator
        alertView.colorPageIndicator = UIColor.white
        alertView.colorCurrentPageIndicator = UIColor(red:0.93, green:0.73, blue:0.51, alpha:1.0)
        
        //Modify size of alertview (Purcentage of screen height and width)
        alertView.percentageRatioHeight = 0.7
        alertView.percentageRatioWidth = 0.8
        
        //Modify labels
        alertView.titleSkipButton = "SKIP"
        alertView.titleGotItButton = "GOT IT!"
        
        
        //Display onboarding
        alertView.show()
    }
    
    
    @IBAction func unwindToList(unwindSegue: UIStoryboardSegue) { }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileUrls.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongItem", for: indexPath)
        cell.textLabel!.text = fileUrls[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenFileUrl = fileUrls[indexPath.row]
        performSegue(withIdentifier: "SongSelected", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let docsDirectory = self.fm.urls(for: .documentDirectory, in: .userDomainMask).first!
            let songsDirectory = docsDirectory.appendingPathComponent("songs", isDirectory: true)
            let fileDirectory = songsDirectory.appendingPathComponent(fileUrls[indexPath.row])
            do {
                try fm.removeItem(at: fileDirectory)
            } catch {}
            fileUrls.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
        }    
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SongList: preparing for segue")
        guard let dest = segue.destination as? EditorViewController else { return }
        guard let chosenFileUrl = self.chosenFileUrl else { return }
        dest.fileOpenUrl = chosenFileUrl
        print("SongList: prepared to segue for \(chosenFileUrl)")
    }
 

}
