//
//  RhymeTableViewController.swift
//  LyricLab
//
//  Created by Punya Chatterjee on 10/2/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RhymeTableViewController: UITableViewController {

    let kDatamuseRhymeUrl = "https://api.datamuse.com/words?rel_rhy="
    let kDatamuseNearRhymeUrl = "https://api.datamuse.com/words?rel_nry="
    var keyword:String?
    var rhymes: [Word] = []
    var nearRhymes: [Word] = []
    var chosenWord: String?
    var chosenRange: UITextRange?
    
    @IBOutlet var segControl: UISegmentedControl!
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rhymes = []
        nearRhymes = []
        guard let keyword = keyword else { return }
        callDatamuse(with: kDatamuseRhymeUrl)
        callDatamuse(with: kDatamuseNearRhymeUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func callDatamuse(with datamuseUrl: String) {
        let fullUrl = datamuseUrl + keyword!
        Alamofire.request(fullUrl).responseJSON { response in
            let json = JSON(response.result.value)
            let rhymeObjects = json.arrayValue
            if rhymeObjects.count > 0 {
                for rhymeObject in rhymeObjects {
                    let thisWord = Word(text: rhymeObject["word"].stringValue, syllables: rhymeObject["numSyllables"].intValue)
                    if datamuseUrl == self.kDatamuseRhymeUrl {
                        self.rhymes.append(thisWord)
                    } else {
                        self.nearRhymes.append(thisWord)
                    }
                }
                self.tableView.reloadData()
            } else {
                self.tableView.reloadData()
            }
        }
    }
    

    // Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segControl.selectedSegmentIndex == 0 {
            if rhymes.count == 0 {
                return 1
            }
            return rhymes.count
        }
        if nearRhymes.count == 0 {
            return 1
        }
        return nearRhymes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sci = segControl.selectedSegmentIndex
        let cell: UITableViewCell?
        if sci == 0 {
            if rhymes.count > 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "RhymeCell", for: indexPath)
                cell!.textLabel?.text = rhymes[indexPath.row].text
                cell!.detailTextLabel?.text = String(rhymes[indexPath.row].syllables) + " syllables"
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "BlankCell", for: indexPath)
                cell!.textLabel!.text = "No rhymes found!"
            }
            
        } else {
            if nearRhymes.count > 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "RhymeCell", for: indexPath)
                cell!.textLabel?.text = nearRhymes[indexPath.row].text
                cell!.detailTextLabel?.text = String(nearRhymes[indexPath.row].syllables) + " syllables"
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "BlankCell", for: indexPath)
                cell!.textLabel!.text = "No near rhymes found!"
            }
            
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segControl.selectedSegmentIndex == 0 {
            chosenWord = rhymes[indexPath.row].text
        } else {
            chosenWord = nearRhymes[indexPath.row].text
        }
        performSegue(withIdentifier: "EditorUnwind", sender: self)
    }
    

    // Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? EditorViewController else { return }
        dest.chosenWord = self.chosenWord
    }
 

}
