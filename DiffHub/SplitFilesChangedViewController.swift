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
        
        let nib = UINib(nibName: "PullFileTableViewHeaderView", bundle: nil)
        self.filesTV.register(nib, forHeaderFooterViewReuseIdentifier: "PullFileTableViewHeaderView")
        
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

        
        let cell = UITableViewCell()
        guard let line = self.files?[indexPath.section].lines else {
            return cell
        }
        
        let data = line[indexPath.row]
        if data.characters.first == "@" {
            cell.backgroundColor = UIColor.getSectionTitleBlueColor()
        }
        else if data.characters.first == "-" {
            cell.backgroundColor = UIColor.getOriFileRedColor()
        }
        else if data.characters.first == "+" {
            cell.backgroundColor = UIColor.getNewFileGreenColor()
        }
        else if data.characters.first == " " {
            cell.backgroundColor = UIColor.white
        }
        else {
            cell.backgroundColor = UIColor.groupTableViewBackground
        }
        
        cell.textLabel?.text = line[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Hack-Regular", size: 11)
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
            //DataManager.sharedInstance.writeDiffFile(diffFile: diffFile)
        }
        
        //DataManager.sharedInstance.writeFilesIntoPull(pull: pull)
        self.filesTV.reloadData()
        
    }
    
}
