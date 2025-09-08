//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

final class SearchGitHubDetailViewController: UIViewController {

    deinit {
        print("[\(#file)] \(#function)")
    }

    private var viewModel: SearchGitHubDetailViewModel!
    private var router: SearchGitHubDetailRouter!

    static func instantiate(viewModel: SearchGitHubDetailViewModel) -> SearchGitHubDetailViewController {
        let vc = UIStoryboard(name: "SearchGitHubDetailViewController", bundle: nil).instantiateInitialViewController() as! SearchGitHubDetailViewController
        vc.title = "検索結果"
        vc.viewModel = viewModel
        return vc
    }

    func set(router: SearchGitHubDetailRouter) {
        self.router = router
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

    private let indicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil {
            fatalError("viewModel is nil. please run instantiate(viewModel: SearchGitHubListViewModel)")
        }
        if router == nil {
            fatalError("router is nil. please run set(router: SearchGitHubListRouter)")
        }

        avaterImageView.addSubview(indicator)
        avaterImageView.applyCenterConstraints(view: indicator)

        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            do {
                try await viewModel.fetchImage()
            } catch {
                self.alert(message: error.localizedDescription)
            }
        }
    }
}

private extension SearchGitHubDetailViewController {
    func bind() {
        self.tracking {[weak self] in
            self?.viewModel.repogitory
        } onChange: { _self, repogitory in
            _self.langLabel.text = repogitory.langLabelText
            _self.starCountLabel.text = repogitory.stargazersCountLabelText
            _self.watcherCountLabel.text = repogitory.wwacherCountLabelText
            _self.forkCountLabel.text = repogitory.forkCountLabelText
            _self.issueCountLabel.text = repogitory.issueCountLabelText
            _self.titleLabel.text = repogitory.titleLabelText
        }.trackingOptional {[weak self] in
            self?.viewModel.image
        } onChange: { _self, image in
            _self.avaterImageView.image = image
        }.tracking {[weak self] in
            self?.viewModel.loading
        } onChange: { _self, loading in
            if loading {
                _self.indicator.startAnimating()
            } else {
                _self.indicator.stopAnimating()
            }
        }
    }
}

private extension SearchGitHubDetailModel {
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

// MARK: - Test Data
#if DEBUG
extension SearchGitHubDetailModel {
    static var mock: Self {
        let mockRepoJSON = """
    {
      "id": 1,
      "full_name": "apple/swift",
      "language": "C++",
      "stargazers_count": 60000,
      "watchers_count": 7000,
      "forks_count": 9000,
      "open_issues_count": 600,
      "owner": {
        "id": 10639145,
        "avatar_url": "https://avatars.githubusercontent.com/u/10639145?v=4"
      }
    }
    """.data(using: .utf8)!

        return try! API.jsonDecoder.decode(Self.self, from: mockRepoJSON)
    }
}
#endif


