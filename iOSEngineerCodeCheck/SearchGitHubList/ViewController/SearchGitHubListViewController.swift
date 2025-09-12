//
//  ViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import DeclarativeUIKit

final class SearchGitHubListViewController: UIViewController {

    private var viewModel: SearchGitHubListViewModel!
    private var router: SearchGitHubListRouter!

    @MainActor
    static func instantiate(viewModel: SearchGitHubListViewModel) -> SearchGitHubListViewController {
        let vc = SearchGitHubListViewController()
        vc.viewModel = viewModel
        vc.title = "検索"
        return vc
    }

    func set(router: SearchGitHubListRouter) {
        self.router = router
    }

    deinit {
        print("[\(#file)] \(#function)")
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, SearchGitHubListModel.ID>!

    override func loadView() {
        super.loadView()

        if viewModel == nil {
            fatalError("viewModel is nil. please run instantiate(viewModel: SearchGitHubListViewModel)")
        }
        if router == nil {
            fatalError("router is nil. please run set(router: SearchGitHubListRouter)")
        }

        self.view.backgroundColor = .systemBackground

        self.applyNavigationItem {
            $0.rightBarButtonItem = UIBarButtonItem(
                customView: UIButton(
                    configuration:
                            .plain()
                            .title("並び替え")
                )
                .showsMenuAsPrimaryAction(true)
                .menu(UIMenu(options: .displayInline, children: [
                    UIDeferredMenuElement.uncached { completion in
                        completion(SearchGithubSortType.allCases.compactMap {[weak self] sortType in
                            UIAction(
                                title: sortType.text,
                                state: sortType == self!.viewModel.sortType ? .on : .off
                            ) {[weak self] _ in
                                Task {
                                    do {
                                        try await self!.viewModel.search(sortType: sortType)
                                    } catch {
                                        self!.alert(message: error.localizedDescription)
                                    }
                                }
                            }
                        })
                    }
                ]))
            )
        }
        self.declarative {
            UIStackView {
                UISearchBar()
                    .placeholder("GitHubのリポジトリを検索できるよー")
                    .apply {
                        $0.accessibilityIdentifier = SearchGitHubListAccessibilityIdentifier.searchBar.rawValue
                    }.delegate(self)

                UICollectionView {
                    UICollectionViewCompositionalLayout.list(
                        using: .init(appearance: .plain)
                    )
                }.apply {[weak self] collectionView in

                    guard let self else { return }

                    // CellRegistrationを定義
                    let itemCell = UICollectionView.CellRegistration<
                        UICollectionViewListCell,
                        SearchGitHubListModel
                    > { cell, indexPath, item in
                        var configuration = cell.defaultContentConfiguration()
                        configuration.text = item.language
                        configuration.secondaryText = item.fullName
                        cell.contentConfiguration = configuration

                    }

                    // データソースを定義
                    dataSource = UICollectionViewDiffableDataSource<Int, SearchGitHubListModel.ID>(collectionView: collectionView) {
                        [weak self] collectionView, indexPath, cellIdentifier in
                        return collectionView.dequeueConfiguredReusableCell(
                            using: itemCell,
                            for: indexPath,
                            item: self!.viewModel.repogitories[id: cellIdentifier]
                        )
                    }
                }
                .tracking({[weak self] in
                    self!.viewModel.repogitories
                }, onChange: {[weak self] collectionView, repogitories in
                    guard let self else { return }
                    collectionView.refreshControl?.endRefreshing()
                    var snapshot = NSDiffableDataSourceSnapshot<Int, SearchGitHubListModel.ID>()
                    snapshot.appendSections([0])
                    snapshot.appendItems(repogitories.compactMap(\.id))
                    self.dataSource.apply(snapshot, animatingDifferences: true)
                })
                .delegate(self)
                .refreshControl {
                    let refreshControl = UIRefreshControl()
                    return refreshControl.addAction(.valueChanged, handler: { [weak self] _ in
                        Task {
                            do {
                                try await self!.viewModel.refresh()
                                refreshControl.endRefreshing()
                            } catch {
                                self!.alert(message: error.localizedDescription)
                            }
                        }
                    })
                }
            }
        }
        .declarative {
            UIActivityIndicatorView(style: .large)
                .apply { indicator in
                    indicator.accessibilityIdentifier = SearchGitHubListAccessibilityIdentifier.indicator.rawValue
                }
                .tracking {[weak self] in
                    self!.viewModel.initialLoading
                } onChange: { indicator, loading in
                    if loading {
                        indicator.startAnimating()
                    } else {
                        indicator.stopAnimating()
                    }
                }
        }
    }
}

extension SearchGitHubListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

    }
}

extension SearchGitHubListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectepogitory = viewModel.repogitories[safe: indexPath.row] else {
            self.alert(message: ServiceError.unknown.localizedDescription)
            return
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        router.pushToDetail(model: selectepogitory)
    }
}


extension SearchGitHubListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        viewModel.set(searchText: searchBar.text)
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.clearText()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        Task {
            do {
                try await viewModel.search()
            } catch {
                self.alert(message: error.localizedDescription)
            }
        }
    }
}


#Preview {
    SearchGitHubListRouterImpl.makeModulesForUITest().withUINavigationController
}

