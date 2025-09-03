//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

final class SearchedGitHubViewController: UIViewController {

    deinit {
        print("[\(#file)] \(#function): \(#line)")
    }

    @IBOutlet private weak var avaterImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var langLabel: UILabel!
    
    @IBOutlet private weak var starCountLabel: UILabel!
    @IBOutlet private weak var watcherCountLabel: UILabel!
    @IBOutlet private weak var forkCountLabel: UILabel!
    @IBOutlet private weak var issueCountLabel: UILabel!
    
    @IBOutlet private weak var mainStackView: UIStackView! {
        didSet {
            // Interaface Builderで設定できないパラメータを初期化
            mainStackView.isLayoutMarginsRelativeArrangement = true
            mainStackView.layoutMargins = .init(top: 55, left: 24, bottom: 0, right: 24)
        }
    }

    var selectRepogitory: [String: Any] = [:]

    private var task: URLSessionTask?

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        task?.cancel()
        task = nil
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

        task = URLSession.shared.dataTask(with: imageUrl) {[weak self] (data, res, err) in
            guard let self else {
                fatalError()
            }
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

            DispatchQueue.main.async {[weak self] in
                self?.avaterImageView.image = image
            }
        }
        task?.resume()
    }
}
