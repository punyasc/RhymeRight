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
        /*
        if segControl.selectedSegmentIndex == 0 {
            //callDatamuse(with: kDatamuseRhymeUrl)
            //print("RR")
            tableView.reloadData()
        } else {
            //callDatamuse(with: kDatamuseNearRhymeUrl)
            //print("NRR")
            tableView.reloadData()
        } */
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                        print("NR count: \(self.nearRhymes.count)")
                    }
                }
                self.tableView.reloadData()
                //self.toolbarText.text = resultString
            } else {
                self.tableView.reloadData()
                //self.toolbarText.text = "(no rhymes found)"
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        //navigationController?.popViewController(animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare!!!")
        guard let dest = segue.destination as? EditorViewController else { return }
        dest.chosenWord = self.chosenWord
    }
 

}
