//
//  SplitChangesViewController.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AMScrollingNavbar
import NVActivityIndicatorView

class SplitChangesViewController: UIViewController {
    
    var pull : Pull?
    var pullId : Int?
    var files = NSMutableArray() //append file to files on main thread only!
    var downloadSpinner : NVActivityIndicatorView?
    
    @IBOutlet weak var filesTV : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTV()

        guard let pull = self.pull else {
            print("pull is not been setup")
            return
        }
        
        self.pullId = pull.id
        
        //load from local disk if downloaded else download it
        guard let diffStr = self.readSavedStringFromFile(pull: pull) else {
            print("Fetch local diff file failed. Will download it")
            self.downloadDiffFile()
            return
        }
        self.parseDiff(diffString: diffStr)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupOrientation()
        
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        
        if deviceIdiom == .phone {
            if let navigationController = navigationController as? ScrollingNavigationController {
                navigationController.followScrollView(filesTV, delay: 50.0)
            }
        }

    }

    func setupNavBar() {

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackBtn"), style: .done, target: self, action: #selector(SplitChangesViewController.goBack))
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
        
        //no seperatorLine
        self.filesTV.separatorStyle = .none
        
        //auto height
        self.filesTV.rowHeight = UITableViewAutomaticDimension
        self.filesTV.estimatedRowHeight = 18

    }
    
    func setupOrientation() {
        
        let currentOri = UIApplication.shared.statusBarOrientation
        
        if currentOri.isPortrait {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }

        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }

}

extension SplitChangesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let file = self.files.object(at: section) as? DiffFile else {
            return 0
        }
        return file.codeLines.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 43
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PullFileTableViewHeaderView") as?PullFileTableViewHeaderView else {
            return UIView()
        }
        guard let file = self.files[section] as? DiffFile else {
            return headerView
        }
        
        if file.sourceFileA == "" && file.sourceFileB == "" {
            headerView.sectionTitle.text = file.title
        }
        else if file.sourceFileA == "" {
             headerView.sectionTitle.text = file.sourceFileB
        }
        else if file.sourceFileB == "" {
            headerView.sectionTitle.text = file.sourceFileA
        }
        else if file.sourceFileA == file.sourceFileB {
            headerView.sectionTitle.text = file.sourceFileA
        }
        else {
            headerView.sectionTitle.text = file.sourceFileA + " -> " + file.sourceFileB
        }
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let file = self.files.object(at: indexPath.section) as? DiffFile else {
            return UITableViewCell()
        }
        
        let codeLine = file.codeLines[indexPath.row]
        
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

extension SplitChangesViewController : RegexParser {
    
    //downloadDiffFile if needed
    func downloadDiffFile() {
        
        //start the spinner
        self.downloadSpinner = self.startSpinner(spinner: self.downloadSpinner, onView: self.view)
        
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
                        //save
                        self.saveStringToFile(pull: pull, content: diffString)
                        
                        //parse
                        self.parseDiff(diffString: diffString)
                        
                        //stop spinner
                        self.stopSpinner(spinner: self.downloadSpinner)
                    }
                    
                }
        }
        
    }
    
    func parseDiff(diffString : String) {
 
        DispatchQueue.global(qos: .userInitiated).async {
            guard let checkResults = self.parseStringToFiles(diffStr: diffString) else {
                return
            }
            let diffStrNS = diffString as NSString
            self.generateFiles(diffStrNS: diffStrNS, checkResults: checkResults)
        }
    }
    
    private func saveStringToFile(pull: Pull, content: String) {
        
        do {
            // get the documents folder url
            let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            // create the destination url for the text file to be saved
            let fileDestinationUrl = documentDirectoryURL.appendingPathComponent(String(pull.id) + ".diff")
            
            let text = content
            do {
                // writing to disk
                try text.write(to: fileDestinationUrl, atomically: false, encoding: .utf8)
                print("saving was successful")
                
                //save diffFile path into pull
                DataManager.writeFilePathToPull(filePath: fileDestinationUrl, pull: pull)
                
            } catch let error {
                print("error writing to url \(fileDestinationUrl)")
                print(error.localizedDescription)
            }
        } catch let error {
            print("error getting documentDirectoryURL")
            print(error.localizedDescription)
        }
        
    }
    
    func readSavedStringFromFile(pull: Pull) -> String? {
        // reading from disk
        
        do {
            // get the documents folder url
            let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            // create the destination url for the text file to be saved
            let fileDestinationUrl = documentDirectoryURL.appendingPathComponent(String(pull.id) + ".diff")
            
            do {
                let diffString = try String(contentsOf: fileDestinationUrl)
                return diffString
                
            } catch let error as NSError {
                print("error loading contentsOf url \(pull.diffFileDir)")
                print(error.localizedDescription)
                
                return nil
            }
            
            
        } catch let error {
            print("error getting documentDirectoryURL")
            print(error.localizedDescription)
            
            return nil
        }

    }
    
    private func generateFiles(diffStrNS: NSString, checkResults: [NSTextCheckingResult]) {

        //re-fetch the pull item for multiThreading
        guard let id = self.pullId else {
            print("fetch pull id failed")
            return
        }
        guard let pull = DataManager.getPull(id: id) else {
            print("fetch pull failed")
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
            
            self.seperateLeftAndRight(diffFile: diffFile, index: index)
        }

    }
    
    private func seperateLeftAndRight(diffFile : DiffFile, index: Int) {

        let array = self.parseFileToArray(diffFile: diffFile)
        guard let codeLines = self.parseArrayToCodeLines(organizedArray: array) else {
            return
        }
        
        diffFile.codeLines = codeLines
        DispatchQueue.main.async {
            self.didFinishedProcessFile(diffFile: diffFile, index: index)
        }

    }
    
    private func didFinishedProcessFile(diffFile: DiffFile, index: Int) {
        //once one file processed, append and load it to tableView

        self.files.add(diffFile) //on main-thread
        
        UIView.performWithoutAnimation {
            //uitableview begin update animation not cool
            self.filesTV.insertSections(IndexSet(integer: index) , with: .none)
        }
        
    }
    
    private func parseFileToArray(diffFile : DiffFile) -> NSMutableArray  {
        //parse file
        let allLines = diffFile.lines
        
        let organizedArray = NSMutableArray()
        var lastFirstChar : Character?
        var diffCodeBlock = DiffCodeBlock()
        
        for line in allLines {
            
            let firstChar = line.characters.first
            let lastChar = line.characters.last
            
            var line = line
            //remove "\r"s
            if lastChar == "\r" {
                line = String(line.characters.dropLast())
            }
            if firstChar == "\r" {
                line = String(line.characters.dropFirst())
            }
            
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
                    diffCodeBlock.append(line: line)
                    lastFirstChar = firstChar
                    
                }
                else {
                    //inside groupMode
                    diffCodeBlock.append(line: line)
                    lastFirstChar = firstChar
                }
                
            }
        }
        
        if diffCodeBlock.blockArray.count != 0 {
            diffCodeBlock.generateBlocks()
            organizedArray.add(diffCodeBlock)
            diffCodeBlock = DiffCodeBlock()
        }
        
        return organizedArray
    }
    
    private func parseArrayToCodeLines(organizedArray: NSMutableArray) -> Array<DiffCodeLine>?  {
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
                        return nil
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
        
        return codeLines
    }
}


extension SplitChangesViewController {
    func startSpinner(spinner: NVActivityIndicatorView?, onView: UIView) -> NVActivityIndicatorView {
        if let spinner = spinner {
            //start
            spinner.startAnimating()
            
            return spinner
        }
        else {
            //create and start
            let currentOri = UIApplication.shared.statusBarOrientation

            let width = currentOri.isPortrait ? UIScreen.main.bounds.width/6 : UIScreen.main.bounds.height/6
            
            let spinnerFrame = CGRect(x: 0, y: 0, width: width, height: width)
            let spinner = NVActivityIndicatorView(frame: spinnerFrame,
                                                  type: .cubeTransition,
                                                  color: UIColor.getIconBackgroundColor(), padding: 0)
            spinner.center = currentOri.isPortrait ? CGPoint(x: self.view.center.y, y: self.view.center.x) : self.view.center

            onView.addSubview(spinner)
            spinner.startAnimating()
            
            return spinner
        }
    }
    
    func stopSpinner(spinner: NVActivityIndicatorView?) {
        guard let spinner = spinner else {
            print("no spinner to stop")
            return
        }
        
        spinner.stopAnimating()
    }
}
