//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

final class SearchedGitHubViewController: UIViewController {

    static func instantiate(selectRepogitory: SearchedGitHubModel) -> SearchedGitHubViewController {
        let vc = UIStoryboard(name: "SearchedGitHubViewController", bundle: nil).instantiateInitialViewController() as! SearchedGitHubViewController
        vc.title = "検索結果"
        vc.selectRepogitory = selectRepogitory
        return vc
    }

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

    private var selectRepogitory: SearchedGitHubModel?

    private var task: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let selectRepogitory else {
            // 本来はアラートを出す
            print("selectRepogitory is empty")
            self.navigationController?.popViewController(animated: true)
            return
        }

        updateUI(repogigory: selectRepogitory)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        task?.cancel()
        task = nil
    }
}

private extension SearchedGitHubViewController {
    func updateUI(repogigory: SearchedGitHubModel) {
        langLabel.text = repogigory.langLabelText
        starCountLabel.text = repogigory.stargazersCountLabelText
        watcherCountLabel.text = repogigory.wwacherCountLabelText
        forkCountLabel.text = repogigory.forkCountLabelText
        issueCountLabel.text = repogigory.issueCountLabelText
        titleLabel.text = repogigory.titleLabelText

        task?.cancel()
        task = Task {
            do {
                guard let image = try await repogigory.owner?.getImage() else {
                    // avatarが設定されていないこともありエラーではないためアラートは出さなくてもいい
                    return
                }
                avaterImageView.image = image
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


private extension SearchedGitHubModel {
    var langLabelText: String {
        "Written in \(self.language)"
    }
    var stargazersCountLabelText: String {
        "\(self.stargazersCount) stars"
    }
    var wwacherCountLabelText: String {
        "\(self.watchersCount) watchers"
    }
    var forkCountLabelText: String {
        "\(self.forksCount) forks"
    }
    var issueCountLabelText: String {
        "\(self.openIssuesCount) open issues"
    }
    var titleLabelText: String {
        self.fullName
    }
}
