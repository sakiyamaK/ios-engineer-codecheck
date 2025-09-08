//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import DeclarativeUIKit
import ObservableUIKit

final class SearchGitHubDetailViewController: UIViewController {

    deinit {
        print("[\(#file)] \(#function)")
    }

    private var viewModel: SearchGitHubDetailViewModel!
    private var router: SearchGitHubDetailRouter!

    static func instantiate(viewModel: SearchGitHubDetailViewModel) -> SearchGitHubDetailViewController {
        let vc = SearchGitHubDetailViewController()
        vc.title = "検索結果"
        vc.viewModel = viewModel
        return vc
    }

    func set(router: SearchGitHubDetailRouter) {
        self.router = router
    }

    override func loadView() {
        super.loadView()

        if viewModel == nil {
            fatalError("viewModel is nil. please run instantiate(viewModel: SearchGitHubListViewModel)")
        }
        if router == nil {
            fatalError("router is nil. please run set(router: SearchGitHubListRouter)")
        }

        self.view.backgroundColor = .systemBackground

        self.declarative {
            UIScrollView {
                UIStackView(spacing: 22) {
                    UIImageView()
                        .contentMode(.scaleAspectFit)
                        .aspectRatio(1.0)
                        .trackingOptional({[weak self] in
                            self!.viewModel.image
                        }, to: \.image)
                        .zStack {
                            UIActivityIndicatorView(style: .large)
                                .tracking {[weak self] in
                                    self!.viewModel.loading
                                } onChange: { indicator, loading in
                                    if loading {
                                        indicator.startAnimating()
                                    } else {
                                        indicator.stopAnimating()
                                    }
                                }
                        }

                    UILabel()
                        .textAlignment(.center)
                        .contentPriorities(.init(vertical: .required))
                        .font(UIFont.preferredFont(forTextStyle: .title1))
                        .tracking({[weak self] in
                            self!.viewModel.repogitory.titleLabelText
                        }, to: \.text)

                    UIStackView.horizontal(alignment: .top) {
                        UILabel()
                            .contentPriorities(.init(all: .required))
                            .font(UIFont.preferredFont(forTextStyle: .headline))
                            .tracking({[weak self] in
                                self!.viewModel.repogitory.langLabelText
                            }, to: \.text)

                        UIView.spacer()

                        UIStackView(alignment: .trailing, spacing: 16) {
                            UILabel()
                                .contentPriorities(.init(all: .required))
                                .font(UIFont.preferredFont(forTextStyle: .subheadline))
                                .tracking({[weak self] in
                                    self!.viewModel.repogitory.stargazersCountLabelText
                                }, to: \.text)

                            UILabel()
                                .contentPriorities(.init(all: .required))
                                .font(UIFont.preferredFont(forTextStyle: .subheadline))
                                .tracking({[weak self] in
                                    self!.viewModel.repogitory.wwacherCountLabelText
                                }, to: \.text)

                            UILabel()
                                .contentPriorities(.init(all: .required))
                                .font(UIFont.preferredFont(forTextStyle: .subheadline))
                                .tracking({[weak self] in
                                    self!.viewModel.repogitory.forkCountLabelText
                                }, to: \.text)

                            UILabel()
                                .contentPriorities(.init(all: .required))
                                .font(UIFont.preferredFont(forTextStyle: .subheadline))
                                .tracking({[weak self] in
                                    self!.viewModel.repogitory.issueCountLabelText
                                }, to: \.text)
                        }
                    }

                }
                .margins(
                    .init(top: 55, leading: 24, bottom: 0, trailing: 24)
                )
            }
        }
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

#Preview {
    SearchGitHubDetailRouterImpl.makeModules(
        repogitory: SearchRepogitoriesDTO.mockSuccess.items.first!
    )
}
