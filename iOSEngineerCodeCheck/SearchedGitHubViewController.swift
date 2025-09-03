//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

final class SearchedGitHubViewController: UIViewController {
    
    @IBOutlet private weak var avaterImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var langLabel: UILabel!
    
    @IBOutlet private weak var starCountLabel: UILabel!
    @IBOutlet private weak var watcherCountLabel: UILabel!
    @IBOutlet private weak var forkCountLabel: UILabel!
    @IBOutlet private weak var issueCountLabel: UILabel!
    
    var searchGitHubListViewController: SearchGitHubListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let searchGitHubListViewController
        else { return }

        let repo = searchGitHubListViewController.repogitories[searchGitHubListViewController.selectRepogitoryIndex]

        langLabel.text = "Written in \(repo["language"] as? String ?? "")"
        starCountLabel.text = "\(repo["stargazers_count"] as? Int ?? 0) stars"
        watcherCountLabel.text = "\(repo["wachers_count"] as? Int ?? 0) watchers"
        forkCountLabel.text = "\(repo["forks_count"] as? Int ?? 0) forks"
        issueCountLabel.text = "\(repo["open_issues_count"] as? Int ?? 0) open issues"
        getImage()
    }
}

private extension SearchedGitHubViewController {
    func getImage(){

        guard let searchGitHubListViewController else { return }
        let repogitory = searchGitHubListViewController.repogitories[searchGitHubListViewController.selectRepogitoryIndex]

        titleLabel.text = repogitory["full_name"] as? String

        if let owner = repogitory["owner"] as? [String: Any] {
            if let imgURL = owner["avatar_url"] as? String {
                URLSession.shared.dataTask(with: URL(string: imgURL)!) { (data, res, err) in
                    let img = UIImage(data: data!)!
                    DispatchQueue.main.async {
                        self.avaterImageView.image = img
                    }
                }.resume()
            }
        }
    }
}
