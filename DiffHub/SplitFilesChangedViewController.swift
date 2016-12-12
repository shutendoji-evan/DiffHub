//
//  SplitFilesChangedViewController.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AMScrollingNavbar

class SplitFilesChangedViewController: UIViewController, RegexParser {
    
    var pull : Pull?
    var diffString : String?
    var lastScreenOri = UIInterfaceOrientation.unknown
    var files : Array<DiffFile>?
    
    @IBOutlet weak var filesTV : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupOrientation()
        self.setupNavBar()
        self.setupTV()
        
        //TODO : Check if it's downloaded
        
        self.downloadDiffFile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(filesTV, delay: 50.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func setupNavBar() {

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackBtn"), style: .done, target: self, action: #selector(SplitFilesChangedViewController.goBack))
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.hidesBarsOnSwipe = true
        
    }
    
    func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func setupTV() {
        
        //header
        let nib = UINib(nibName: "PullFileTableViewHeaderView", bundle: nil)
        self.filesTV.register(nib, forHeaderFooterViewReuseIdentifier: "PullFileTableViewHeaderView")
        
        //section title cell
        self.filesTV.register(UINib(nibName: "SectionTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "sectionTitle")
        
        //left-right code cell
        self.filesTV.register(UINib(nibName: "CodeLineTableViewCell", bundle: nil), forCellReuseIdentifier: "code")
        
        self.filesTV.separatorStyle = .none

    }
    
    func setupOrientation() {
        
        let currentOri = UIApplication.shared.statusBarOrientation
        self.lastScreenOri = currentOri
        
        if currentOri.isPortrait {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.setValue(self.lastScreenOri.rawValue, forKey: "orientation")
    }

}

extension SplitFilesChangedViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = self.files?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lines = self.files?[section].lines else {
            return 0
        }
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let line = self.files?[indexPath.section].lines else {
            return 0
        }
        let data = line[indexPath.row]
        if data.characters.first == "@" {
            return 28
        }
        else if data.characters.first == "+" || data.characters.first == "-" || data.characters.first == " " {
            return 18
        }
        else {
            return 18
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 43
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PullFileTableViewHeaderView") as?PullFileTableViewHeaderView else {
            return UIView()
        }
        guard let files = self.files else {
            return headerView
        }
        
        if files[section].sourceFileA == "" && files[section].sourceFileB == "" {
            headerView.sectionTitle.text = files[section].title
        }
        else if files[section].sourceFileA == "" {
             headerView.sectionTitle.text = files[section].sourceFileB
        }
        else if files[section].sourceFileB == "" {
            headerView.sectionTitle.text = files[section].sourceFileA
        }
        else if files[section].sourceFileA == files[section].sourceFileB {
            headerView.sectionTitle.text = files[section].sourceFileA
        }
        else {
            headerView.sectionTitle.text = files[section].sourceFileA + " -> " + files[section].sourceFileB
        }
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let leftLine = self.files?[indexPath.section].leftLines else {
            return UITableViewCell()
        }
        guard let rightLine = self.files?[indexPath.section].rightLines else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "code", for: indexPath) as! CodeLineTableViewCell
        
        var dataLeft : String?
        if indexPath.row < leftLine.count {
            dataLeft = leftLine[indexPath.row]
        }
        
        if let leftLine = dataLeft {
            
            if leftLine.characters.first == "@" {
                //section title
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitle", for: indexPath) as! SectionTitleTableViewCell
                cell.sectionTitleLabel.text = dataLeft
                cell.selectionStyle = .none
                return cell
            }
            if leftLine.characters.first == "-" {
                cell.leftCodeLabel.text = leftLine
                cell.leftLineNumLabel.text = "0"
                cell.leftCodeLabel.backgroundColor = UIColor.getOriFileRedColor()
                cell.leftLineNumLabel.backgroundColor = UIColor.getOriLineNumRedColor()
            }
            
            if leftLine.characters.first == " " {
                cell.leftCodeLabel.text = leftLine
                cell.leftLineNumLabel.text = "0"
                cell.leftLineNumLabel.backgroundColor = UIColor.white
                cell.leftCodeLabel.backgroundColor = UIColor.white
            }
            
            if leftLine.characters.first == "$" {
                cell.leftCodeLabel.text = ""
                cell.leftLineNumLabel.text = ""
                cell.leftLineNumLabel.backgroundColor = UIColor.groupTableViewBackground
                cell.leftCodeLabel.backgroundColor = UIColor.groupTableViewBackground
            }
        }

        var dataRight : String?
        if indexPath.row < rightLine.count {
            dataRight = rightLine[indexPath.row]
        }
        if let rightLine = dataRight {
            if rightLine.characters.first == "+" {
                cell.rightCodeLabel.text = rightLine
                cell.rightLineNumLabel.text = "0"
                cell.rightCodeLabel.backgroundColor = UIColor.getNewFileGreenColor()
                cell.rightLineNumLabel.backgroundColor = UIColor.getNewLineNumGreenColor()
            }
            
            if rightLine.characters.first == " " {
                cell.rightCodeLabel.text = dataRight
                cell.rightLineNumLabel.text = "0"
                cell.rightLineNumLabel.backgroundColor = UIColor.white
                cell.rightCodeLabel.backgroundColor = UIColor.white
            }
            
            if rightLine.characters.first == "$" {
                cell.rightCodeLabel.text = ""
                cell.rightLineNumLabel.text = ""
                cell.rightLineNumLabel.backgroundColor = UIColor.groupTableViewBackground
                cell.rightCodeLabel.backgroundColor = UIColor.groupTableViewBackground
            }

        }
        
        cell.selectionStyle = .none
        return cell
    }
}

extension SplitFilesChangedViewController {
    
    //downloadDiffFile if needed
    func downloadDiffFile() {
        
        guard let pull = self.pull else {
            print("Fetch pull failed")
            return
        }
        
        let diff_url = pull.diff_url
        
        Alamofire.request(diff_url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseString { (response) in
                if response.result.isSuccess {
                    print(response.data!)
                    if let data = response.data {
                        guard let diffString = String(data: data, encoding: .utf8) else {
                            print("parse diff string failed.")
                            return
                        }
                        self.diffString = diffString
                        let diffStrNS = diffString as NSString
                        
                        guard let checkResults = self.parseStringToFiles(diffStr: diffString) else {
                            return
                        }
                        self.generateFiles(diffStrNS: diffStrNS, checkResults: checkResults)
                        
                    }
                    
                }
                
        }
        
    }
    
    func generateFiles(diffStrNS: NSString, checkResults: [NSTextCheckingResult]) {
        
        self.files = Array<DiffFile>()
        guard let pull = self.pull else {
            print("Fetch pull failed")
            return
        }
        
        for (index, file) in checkResults.enumerated() {
            let lastIndex = checkResults.last == file ?
                diffStrNS.length - file.range.location - 1 :
                checkResults[index + 1].range.location - file.range.location - 1
            
            let diffFile = DiffFile()
            diffFile.startIndex = file.range.location
            diffFile.endIndex = lastIndex
            diffFile.title = diffStrNS.substring(with: file.range) as String
            diffFile.pullRequestId = pull.id
            //diffFile.id = String(pull.id) + "|" + diffFile.title //unique id
            
            //names
            let fileStr = diffFile.parseSource(sourceStr: diffStrNS as String)
            if let aAndBName = self.parseFileNames(fileStr: fileStr)  {
                diffFile.sourceFileA = aAndBName.0
                diffFile.sourceFileB = aAndBName.1
            }
            
            //sections
            guard let sectionResults = self.parseSections(fileStr: fileStr) else {
                print("parse section failed")
                continue
            }
            for (index, section) in sectionResults.enumerated() {
                
                let lastIndex = sectionResults.last == section ?
                    (fileStr as NSString).length - section.range.location :
                    sectionResults[index + 1].range.location - section.range.location - 1
                
                let fileSection = FileSection()
                fileSection.startIndex = section.range.location
                fileSection.endIndex = lastIndex
                let resultNS = fileSection.parseSource(sourceStr: fileStr) as NSString
                fileSection.sectionSource = resultNS.components(separatedBy: "\n")
                
                for line in fileSection.sectionSource {
                    diffFile.lines.append(line)
                }
                
                diffFile.sections.append(fileSection)
            }
            
            self.files?.append(diffFile)
            self.seperateLeftAndRight(diffFile: diffFile)
        }

    }
    
    func seperateLeftAndRight(diffFile : DiffFile) {
        let allLines = diffFile.lines
        var lineTypeIndicator : Character?
        var leftLines = Array<String>()
        var rightLines = Array<String>()
        
        for line in allLines {
            if line.characters.first == "-" || line.characters.first == "+" {
                if line.characters.first == "-" {
                    leftLines.append(line)
                }
                if line.characters.first == "+" {
                    rightLines.append(line)
                }
                
                if (lineTypeIndicator == "-" || lineTypeIndicator == "+") && (line.characters.first != lineTypeIndicator) {
                    //fill the different while switching from (- to +) or (+ to -) append $ let the tableView know it's a empty line
                    if leftLines.count < rightLines.count {
                        let num = rightLines.count - leftLines.count
                        for _ in 0..<num {
                            leftLines.append("$")
                        }
                    }
                    else if leftLines.count > rightLines.count {
                        let num = leftLines.count - rightLines.count
                        for _ in 0..<num {
                            rightLines.append("$")
                        }
                    }
                    
                    lineTypeIndicator = line.characters.first
                }

            }
            else {
                leftLines.append(line)
                rightLines.append(line)
            }
        }
        
        diffFile.leftLines = leftLines
        diffFile.rightLines = rightLines
        
        
        
        self.filesTV.reloadData()
    }
    
}
