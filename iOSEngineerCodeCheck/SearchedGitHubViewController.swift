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
    
    var selectRepogitory: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        guard !selectRepogitory.isEmpty else {
            // 本来はアラートを出す
            print("selectRepogitory is empty")
            self.navigationController?.popViewController(animated: true)
            return
        }

        langLabel.text = "Written in \(selectRepogitory["language"] as? String ?? "")"
        starCountLabel.text = "\(selectRepogitory["stargazers_count"] as? Int ?? 0) stars"
        watcherCountLabel.text = "\(selectRepogitory["wachers_count"] as? Int ?? 0) watchers"
        forkCountLabel.text = "\(selectRepogitory["forks_count"] as? Int ?? 0) forks"
        issueCountLabel.text = "\(selectRepogitory["open_issues_count"] as? Int ?? 0) open issues"
        titleLabel.text = selectRepogitory["full_name"] as? String

        getImage()
    }
}

private extension SearchedGitHubViewController {
    func getImage(){
        guard let owner = selectRepogitory["owner"] as? [String: Any],
              let imageUrlStr = owner["avatar_url"] as? String,
              let imageUrl = imageUrlStr.url
        else {
            // avatarが設定されていないこともありエラーではないためアラートは出さなくてもいい
            return
        }

        URLSession.shared.dataTask(with: imageUrl) { (data, res, err) in
            if let err {
                // 本来はアラートを出す
                print(err)
                return
            }
            guard let data else {
                // 本来はアラートを出す
                print("[\(imageUrl)] : data is nil")
                return
            }
            guard let image = UIImage(data: data) else {
                // 本来はアラートを出す
                print("[\(imageUrl)] : data is not image")
                return
            }

            DispatchQueue.main.async {
                self.avaterImageView.image = image
            }
        }.resume()
    }
}
