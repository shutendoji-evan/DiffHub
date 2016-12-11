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

class SplitFilesChangedViewController: UIViewController, RegexParser {
    
    var pull : Pull?
    var diffString : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO : Check if it's downloaded
        
        self.downloadDiffFile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    
    func setupOrientation() {
        
        let currentOri = UIApplication.shared.statusBarOrientation
        
        if currentOri.isPortrait {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
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
            diffFile.id = String(pull.id) + "|" + diffFile.title //unique id
            
            DataManager.sharedInstance.writeDiffFile(diffFile: diffFile)
        }
        
        DataManager.sharedInstance.writeFilesIntoPull(pull: pull)
        
    }
}
