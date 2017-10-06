//
//  ViewController.swift
//  LyricLab
//
//  Created by Punya Chatterjee on 10/1/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension String {
    var lines: [String] { return self.components(separatedBy: NSCharacterSet.newlines) }
}

class EditorViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {

    //@IBOutlet weak var wrapper: LineNumberTextViewWrapper!
    let fm = FileManager.default
    let kDatamuseRhymeUrl = "https://api.datamuse.com/words?rel_rhy="
    var fileOpenUrl: String?
    var keyword: String?
    var chosenWord: String?
    var chosenRange: UITextRange?
    
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var wrapper: LineNumberTextViewWrapper!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet var toolbarText: UILabel!
    @IBOutlet var toolbarStack: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    
    
    @IBAction func renamePress(_ sender: Any) {
        alertRename()
    }
    
    func alertSetTitle() {
        let docsDirectory = self.fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let songsDirectory = docsDirectory.appendingPathComponent("songs", isDirectory: true)
        let alertTitle = navigationItem.rightBarButtonItem?.title
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        //2. Add the text field. You can configure it however you need.
        let oldTitle = self.navigationItem.title
        alert.addTextField { (textField) in
            textField.placeholder = oldTitle
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            var newDirectory = songsDirectory.appendingPathComponent(textField!.text!)
            var newTitle = textField!.text!
            print("NT: \(newTitle.characters.count)")
            if newTitle.trimmingCharacters(in: .whitespaces).characters.count == 0 {
                print("seppuku")
                self.navigationController?.popViewController(animated: true)
            }
            if self.fm.fileExists(atPath: newDirectory.path) && self.fileOpenUrl != textField!.text! {
                print("file exists")
                var copyCount = 1
                while self.fm.fileExists(atPath: newDirectory.path) {
                    print("newdir: \(newDirectory.path)")
                    var extendedUrl = newTitle + " copy \(copyCount)"
                    print("ext: \(extendedUrl)")
                    newDirectory = songsDirectory.appendingPathComponent(extendedUrl)
                    copyCount += 1
                }
                
                newTitle += " copy \(copyCount - 1)"
                print("newTitle: \(newTitle)")
            }
                self.navigationItem.title = newTitle
                self.navigationItem.rightBarButtonItem?.title = "Rename"
                if let oldTitle = oldTitle {
                    let oldDirectory = songsDirectory.appendingPathComponent(oldTitle)
                    let newDirectory = songsDirectory.appendingPathComponent((textField?.text)!)
                    do {
                        try self.fm.moveItem(at: oldDirectory, to: newDirectory)
                    } catch {}
                }
                self.wrapper.textView.becomeFirstResponder()
                alert?.dismiss(animated: true, completion: { })
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            //self.dismiss(animated: true, completion: {})
            self.navigationController?.popViewController(animated: true)
            //alert?.dismiss(animated: true, completion: { })
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertRename() {
        let docsDirectory = self.fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let songsDirectory = docsDirectory.appendingPathComponent("songs", isDirectory: true)
        let alertTitle = navigationItem.rightBarButtonItem?.title
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        //2. Add the text field. You can configure it however you need.
        let oldTitle = self.navigationItem.title
        alert.addTextField { (textField) in
            textField.placeholder = oldTitle
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            var newDirectory = songsDirectory.appendingPathComponent(textField!.text!)
            var newTitle = textField!.text!
            if self.fm.fileExists(atPath: newDirectory.path) && self.fileOpenUrl != textField!.text! {
                print("file exists")
                var copyCount = 1
                while self.fm.fileExists(atPath: newDirectory.path) {
                    print("newdir: \(newDirectory.path)")
                    var extendedUrl = newTitle + " copy \(copyCount)"
                    print("ext: \(extendedUrl)")
                    newDirectory = songsDirectory.appendingPathComponent(extendedUrl)
                    copyCount += 1
                }
                
                newTitle += " copy \(copyCount - 1)"
                print("newTitle: \(newTitle)")
                //self.alertExistingFile()
            } //else {
            
            self.navigationItem.title = newTitle
            self.navigationItem.rightBarButtonItem?.title = "Rename"
            if let oldTitle = oldTitle {
                let oldDirectory = songsDirectory.appendingPathComponent(oldTitle)
                let newDirectory = songsDirectory.appendingPathComponent((textField?.text)!)
                do {
                    try self.fm.moveItem(at: oldDirectory, to: newDirectory)
                } catch {}
            }
            self.wrapper.textView.becomeFirstResponder()
            alert?.dismiss(animated: true, completion: { })
            //}
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            //self.dismiss(animated: true, completion: {})
            //self.navigationController?.popViewController(animated: true)
            alert?.dismiss(animated: true, completion: { })
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func hideKeyboardPress(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "EnableAutocorrect") {
            print("ACSET")
            wrapper.textView.autocorrectionType = .yes
        } else {
            print("ACNOTSET")
            wrapper.textView.autocorrectionType = .no
        }
        if let fileOpenUrl = fileOpenUrl {
            //load a file
            let docsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
            let songsDirectory = docsDirectory.appendingPathComponent("songs", isDirectory: true)
            let fileDirectory = songsDirectory.appendingPathComponent(fileOpenUrl)
            let savedText =  String(data: fm.contents(atPath: fileDirectory.path)!, encoding: String.Encoding.utf8)
            wrapper.textView.text = savedText
            self.navigationItem.title = fileOpenUrl
        } else {
            //nothing to load, blank file
            navigationItem.rightBarButtonItem?.title = "Set Title"
            alertSetTitle()
        }
        if chosenWord != nil {
            if let range = chosenRange {
                wrapper.textView.replace(range, withText: chosenWord! + " ")
            }
            chosenWord = nil
            chosenRange = nil
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            saveFieldToFile()
    }
    
    func saveFieldToFile() {
        let docsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let songsDirectory = docsDirectory.appendingPathComponent("songs", isDirectory: true)
        let fileDirectory = songsDirectory.appendingPathComponent(self.navigationItem.title!)
        if fm.fileExists(atPath: fileDirectory.path) && fileOpenUrl != self.navigationItem.title {
          print("file already exists! not overwritten")
            alertExistingFile()
        } else {
            let songText = wrapper.textView.text!
            let songData = songText.data(using: String.Encoding.utf8)
            fm.createFile(atPath: fileDirectory.path, contents: songData, attributes: nil)
            fileOpenUrl = self.navigationItem.title!
        }
    }
    
    func alertExistingFile() {
        let alert2 = UIAlertController(title: "Title already used", message: "Overwrite the file with the previous title, or pick a new title", preferredStyle: .alert)
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert2.addAction(UIAlertAction(title: "Overwrite", style: .destructive, handler: { [weak alert2] (_) in
            alert2?.dismiss(animated: true, completion: { })
        }))
        alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert2] (_) in
            //alertSetTitle()
            alert2?.dismiss(animated: true, completion: { })
        }))
        // 4. Present the alert.
        self.present(alert2, animated: true, completion: nil)
    }
    
    func alertAndSaveName() {
        let alert = UIAlertController(title: "Save Song", message: "Give your song a title and save it.", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
            textField.text = ""
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.navigationItem.title = textField?.text
        }))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: { })
            self.dismiss(animated: true, completion: nil)
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        FileManager.default.contents(atPath: "")
 
        wrapper.textView.delegate = self
        /*
        do {
            //  Display some sample text to start with
            let fileURL = Bundle.main.url(forResource: "Sample", withExtension: "rtf")
            let ats  =  try NSAttributedString.init(url: fileURL!, options: [:], documentAttributes: nil)
            self.wrapper.textView?.attributedText = ats;
        } catch {} */
        wrapper.textView.keyboardAppearance = .dark
        wrapper.textView.inputAccessoryView = toolbarView
        wrapper.textView.lineNumberTextColor = UIColor(red:0.93, green:0.73, blue:0.51, alpha:1.0) //.white
        wrapper.textView.backgroundColor = UIColor(red:0.16, green:0.18, blue:0.20, alpha:1.0) //.black
        wrapper.textView.lineNumberBackgroundColor = UIColor(red:0.16, green:0.18, blue:0.20, alpha:1.0) //.black //UIColor(red:0.00, green:0.29, blue:0.51, alpha:1.0)
        wrapper.textView.lineNumberBorderColor = .clear
        wrapper.textView.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        wrapper.textView.textColor = .white
        //  Respond to software keyboard appearance and dissappearance as per:
        //  http://stackoverflow.com/questions/26213681/ios-8-keyboard-hides-my-textview
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        //print("3: \(wrapper.textView.text.lines[19])")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        updateToolbar(textView)
    }
    
    var prevLastLine: String?
    func updateToolbar(_ textView: UITextView) {
        print("Selection changed!")
        scrollView.setContentOffset(CGPoint.zero, animated: false)
        let ns = textView.text as NSString
        let sr = textView.selectedRange
        let lr = ns.lineRange(for: textView.selectedRange)
        //print("lr low: \(lr.lowerBound) and lr high: \(lr.upperBound)")
        if (lr.lowerBound > 0) {
            let newSr = NSRange.init(location: lr.lowerBound - 1, length: 0)
            let newLr = ns.lineRange(for: newSr)
            let lastLineUT = ns.substring(with: newLr)
            let lastLine = lastLineUT.trimmingCharacters(in: .newlines)
            //let lastLine = lastLineUT.trimmingCharacters(in: .whitespacesAndNewlines)
            //print("lr: \(ns.substring(with: lr))")
            print("lastLine: \(lastLine)")
            
            if let lineNum = textView.text.lines.index(of: lastLine) {
                print("lastLine: \(lastLine)")
                //print("lineNum: \(lineNum) prevLineNum: \(prevLineNum)")
                //prevLineNum = lineNum
                //print("line num: \(lineNum)")
                if lineNum % 2 == 0 && lastLine.characters.count > 0 && lastLine != prevLastLine {
                    //A-line
                    prevLastLine = lastLine
                    print("b")
                    var lastLineWords = lastLine.components(separatedBy: " ")
                    
                    var endCount = 1
                    while true {
                        if lastLineWords[lastLineWords.count - endCount].characters.count > 0 {
                            break
                        }
                        endCount += 1
                        if endCount > 100 {
                            endCount = 1
                            break
                        }
                    }
                    
                    let lastWord = lastLineWords[lastLineWords.count - endCount]
                    toolbarText.text = "..."
                    let lastWordTrimmed = lastWord.trimmingCharacters(in: .punctuationCharacters)
                    cleanUpButtons()
                    getRhymes(for: lastWordTrimmed)
                } else {
                    //B-line
                    print("a")
                    if lastLine != prevLastLine {
                        prevLastLine = lastLine
                        cleanUpButtons()
                        toolbarText.text = " "
                        self.moreButton.isHidden = true
                    }
                }
            } else {
                toolbarText.text = " "
                cleanUpButtons()
                self.moreButton.isHidden = true
                print("dint work")
            }
        } else {
            print("LOERBOUND")
            prevLastLine = nil
            toolbarText.text = " "
            cleanUpButtons()
            self.moreButton.isHidden = true
        }
    }
    
    func cleanUpButtons() {
        var ct = toolbarStack.subviews.count - 1
        while ct > 0 {
            toolbarStack.subviews[ct].removeFromSuperview()
            ct -= 1
        }
    }
    
    func getRhymes(for last:String) {
        let fullUrl = kDatamuseRhymeUrl + last + "&max=7"
        keyword = last
        print("url: \(fullUrl)")
        Alamofire.request(fullUrl).responseJSON { response in
            let json = JSON(response.result.value)
            
            let rhymes = json.arrayValue
            var resultString = "Rhymes:"
            print("J.count: \(rhymes.count)")
            if rhymes.count > 0 {
                var count = 0
                for word in rhymes {
                    let resultWord = word["word"].stringValue
                    //resultString = "\(resultString)\(resultWord), "
                    let button = UIButton()
                    button.setTitle(resultWord, for: .normal)
                    button.heightAnchor.constraint(equalToConstant: 15)
                    button.widthAnchor.constraint(lessThanOrEqualToConstant: 80)
                    //button.widthAnchor.constraint(equalToConstant: 71)
                    button.backgroundColor = UIColor(red:0.10, green:0.41, blue:0.61, alpha:1.0)
                    button.layer.cornerRadius = 10
                    button.addTarget(self, action: #selector(self.wordPressed), for: .touchUpInside)
                    self.toolbarStack.addArrangedSubview(button)
                    
                    //count += 1
                    //if count > 5 { break }
                }
                self.toolbarText.text = resultString
                self.moreButton.isHidden = false
            } else {
                self.toolbarText.text = "(no rhymes found)"
                self.moreButton.isHidden = true
            }
        }
    }
    
    @objc func wordPressed(sender: UIButton!) {
        print("wordPressed!")
        let chosenWord = sender.titleLabel!.text! + " "
        if let range = wrapper.textView.selectedTextRange {
            wrapper.textView.replace(range, withText: chosenWord)
        }
    }
    
    @IBAction func unwindToEditor(unwindSegue: UIStoryboardSegue) { }
    
    override func viewDidLayoutSubviews() {
        let viewBounds = self.view.bounds
        var wrapperFrame = viewBounds
        let topBarOffset = self.topLayoutGuide.length
        wrapperFrame.origin.y = topBarOffset
        wrapperFrame.size.height -= topBarOffset
        wrapper.frame = wrapperFrame
    }
    
    @objc func keyboardFrameWillChange(notification: NSNotification) {
        let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue?)?.cgRectValue
        let keyboardBeginFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue?)?.cgRectValue
        let animationCurve = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber?)?.intValue
        let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber?)?.doubleValue
        
        UIView.animate(withDuration: animationDuration!, delay: 0, options: [UIViewAnimationOptions(rawValue: UInt(animationCurve!))], animations: {
            if let oldFrame = self.wrapper?.bounds {
                var newFrame = oldFrame
                let keyboardFrameBegin = self.view.convert(keyboardBeginFrame!, to: nil)
                let keyboardFrameEnd = self.view.convert(keyboardEndFrame!, from: nil)
                if (keyboardFrameEnd.origin.y <  keyboardFrameBegin.origin.y) {
                    newFrame.size.height -= max(0.0, keyboardFrameEnd.size.height);
                }
                self.wrapper.textView?.frame = newFrame;
            }
        }, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? RhymeTableViewController else { return }
        dest.keyword = self.keyword
        chosenRange = wrapper.textView.selectedTextRange
    }


}

