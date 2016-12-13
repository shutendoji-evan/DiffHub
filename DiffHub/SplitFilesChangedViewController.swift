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
        
        guard let pull = self.pull else {
            return
        }
        
        self.navigationItem.title = "#" + String(pull.number)
        
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
        guard let lines = self.files?[section].codeLines else {
            return 0
        }
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let lines = self.files?[indexPath.section].codeLines else {
            return 0
        }
        
        let type = lines[indexPath.row].type
        
        switch type {
        case .title:
            return 28
        case .plusOrMinor:
            return 18
        case .common:
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
        
        guard let codeLines = self.files?[indexPath.section].codeLines else {
            return UITableViewCell()
        }
        
        let codeLine = codeLines[indexPath.row]
        
        switch codeLine.type {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitle", for: indexPath) as! SectionTitleTableViewCell
            cell.sectionTitleLabel.text = codeLine.sharedContent
            cell.selectionStyle = .none
            
            return cell
        case .common:
            let cell = tableView.dequeueReusableCell(withIdentifier: "code", for: indexPath) as! CodeLineTableViewCell
            cell.leftCodeLabel.text = codeLine.leftContent
            cell.leftLineNumLabel.text = String(codeLine.leftNum)
            cell.leftCodeLabel.backgroundColor = UIColor.white
            cell.leftLineNumLabel.backgroundColor = UIColor.white
            
            cell.rightCodeLabel.text = codeLine.rightContent
            cell.rightLineNumLabel.text = String(codeLine.rightNum)
            cell.rightCodeLabel.backgroundColor = UIColor.white
            cell.rightLineNumLabel.backgroundColor = UIColor.white
            
            return cell
        case .plusOrMinor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "code", for: indexPath) as! CodeLineTableViewCell
            if codeLine.isLeftNull {
                cell.leftCodeLabel.text = codeLine.leftContent
                cell.leftLineNumLabel.text = ""
                cell.leftCodeLabel.backgroundColor = UIColor.getNoContentGrayColor()
                cell.leftLineNumLabel.backgroundColor = UIColor.getNoContentGrayColor()
            }
            else {
                cell.leftCodeLabel.text = codeLine.leftContent
                cell.leftLineNumLabel.text = String(codeLine.leftNum)
                cell.leftCodeLabel.backgroundColor = UIColor.getOriFileRedColor()
                cell.leftLineNumLabel.backgroundColor = UIColor.getOriLineNumRedColor()
            }
            
            if codeLine.isRightNull {
                cell.rightCodeLabel.text = codeLine.rightContent
                cell.rightLineNumLabel.text = ""
                cell.rightCodeLabel.backgroundColor = UIColor.getNoContentGrayColor()
                cell.rightLineNumLabel.backgroundColor = UIColor.getNoContentGrayColor()
            }
            else {
                cell.rightCodeLabel.text = codeLine.rightContent
                cell.rightLineNumLabel.text = String(codeLine.rightNum)
                cell.rightCodeLabel.backgroundColor = UIColor.getNewFileGreenColor()
                cell.rightLineNumLabel.backgroundColor = UIColor.getNewLineNumGreenColor()
            }

            return cell
        }
        
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
        
        //parse file
        let allLines = diffFile.lines
        
        let organizedArray = NSMutableArray()
        var lastFirstChar : Character?
        var diffCodeBlock = DiffCodeBlock()
        
        for (_, line) in allLines.enumerated() {
            let firstChar = line.characters.first
            
            if firstChar != "+" && firstChar != "-" {
                if lastFirstChar != "+" && lastFirstChar != "-" {
                    //plain info
                    organizedArray.add(line)
                    lastFirstChar = firstChar
                }
                else {
                    //exit groupMode
                    diffCodeBlock.generateBlocks()
                    organizedArray.add(diffCodeBlock)
                    diffCodeBlock = DiffCodeBlock()
                    
                    organizedArray.add(line)
                    lastFirstChar = firstChar
                    continue
                }

            }
            else {
                if lastFirstChar != "+" && lastFirstChar != "-" {
                    //enter groupMode
                    diffCodeBlock.blockArray.append(line)
                    if firstChar == "+" {
                        diffCodeBlock.plusNum += 1
                    }
                    else if firstChar == "-" {
                        diffCodeBlock.minorNum += 1
                    }
                    lastFirstChar = firstChar
                    
                }
                else {
                    //inside groupMode
                    diffCodeBlock.blockArray.append(line)
                    if firstChar == "+" {
                        diffCodeBlock.plusNum += 1
                    }
                    else if firstChar == "-" {
                        diffCodeBlock.minorNum += 1
                    }
                    lastFirstChar = firstChar

                }
                
            }
            
        }
        
        if diffCodeBlock.blockArray.count != 0 {
            diffCodeBlock.generateBlocks()
            organizedArray.add(diffCodeBlock)
            diffCodeBlock = DiffCodeBlock()
        }

        //Get codelines DataSource
        var leftLineNum = 0
        var rightLineNum = 0
        
        var codeLines = Array<DiffCodeLine>()
        for item in organizedArray {
            if item is DiffCodeBlock {
                let blockObj = item as! DiffCodeBlock
                for i in 0..<blockObj.blockMinor!.count {
                    let codeLine = DiffCodeLine()
                    codeLine.type = .plusOrMinor
                    
                    if blockObj.blockMinor![i].characters.first == "$" {
                        codeLine.leftContent = ""
                        codeLine.isLeftNull = true
                    }
                    else {
                        codeLine.leftContent = blockObj.blockMinor![i]
                        codeLine.leftNum = leftLineNum
                        leftLineNum += 1
                    }
                    if blockObj.blockPlus![i].characters.first == "$" {
                        codeLine.rightContent = ""
                        codeLine.isRightNull = true
                    }
                    else {
                        codeLine.rightContent = blockObj.blockPlus![i]
                        codeLine.rightNum = rightLineNum
                        rightLineNum += 1
                    }
                    
                    codeLines.append(codeLine)
                }

            }
            else {
                let str = item as! String
                let codeLine = DiffCodeLine()
                
                let type : DiffCodeLine.CodeLineType = str.characters.first == "@" ? .title : .common
                codeLine.type = type
                
                if type == .title {
                    codeLine.sharedContent = str
                    guard let startNum = self.parseStartLineNumber(title: str) else {
                        return
                    }
                    codeLine.leftStartNum = startNum.0
                    leftLineNum = startNum.0
                    codeLine.rightStartNum = startNum.1
                    rightLineNum = startNum.1
                    
                }
                else if type == .common {
                    codeLine.leftContent = str
                    codeLine.rightContent = str
                    codeLine.leftNum = leftLineNum
                    codeLine.rightNum = rightLineNum
                    leftLineNum += 1
                    rightLineNum += 1
                }
                
                codeLines.append(codeLine)
            }
        }
        
        diffFile.codeLines = codeLines
        
        self.filesTV.reloadData()
    }
    
}
