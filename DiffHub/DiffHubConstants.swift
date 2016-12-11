//
//  DiffHubConstants.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation

struct DiffHubConstants {
    static var githubAPI = "https://api.github.com"
    static var repos = "repos"
    static var owner = "magicalpanda"
    static var repositoryName = "MagicalRecord"
    static var pulls = "pulls"
    
    static var pullsURL = DiffHubConstants.githubAPI + "/" + DiffHubConstants.repos + "/" + DiffHubConstants.owner + "/" + DiffHubConstants.repositoryName + "/" + DiffHubConstants.pulls

}
