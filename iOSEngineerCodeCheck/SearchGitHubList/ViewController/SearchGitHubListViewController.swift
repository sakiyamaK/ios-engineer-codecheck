//
//  ViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

final class SearchGitHubListViewController: UITableViewController {

    private var viewModel: SearchGitHubListViewModel!
    private var router: SearchGitHubListRouter!

    @MainActor
    static func instantiate(viewModel: SearchGitHubListViewModel) -> SearchGitHubListViewController {
        let vc = UIStoryboard(name: "SearchGitHubListViewController", bundle: nil).instantiateInitialViewController() as! SearchGitHubListViewController
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

    private let cellIdentifier: String = "Repository"

    @IBOutlet private weak var searchBar: UISearchBar!

    private let indicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            fatalError("viewModel is nil. please run instantiate(viewModel: SearchGitHubListViewModel)")
        }
        if router == nil {
            fatalError("router is nil. please run set(router: SearchGitHubListRouter)")
        }
        // Do any additional setup after loading the view.
        searchBar.text = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self

        self.view.addSubview(indicator)
        self.view.applyCenterConstraints(view: indicator)

        bind()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repogitories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
            // クラッシュログをサーバーにあげる
            fatalError()
        }
        return cell.trackingOptional {[weak self] in
            self?.viewModel.repogitories[safe: indexPath.row]
        } onChange: { cell, repogitory in
            cell.textLabel?.text = repogitory?.language ?? ""
            cell.detailTextLabel?.text = repogitory?.fullName ?? ""
            cell.tag = indexPath.row
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectepogitory = viewModel.repogitories[safe: indexPath.row] else {
            self.alert(message: ServiceError.unknown.localizedDescription)
            return
        }
        router.pushToDetail(model: selectepogitory)
    }
}

private extension SearchGitHubListViewController {
    func bind() {
        self.tracking {[weak self] in
            self?.viewModel.repogitories
        } onChange: { _self, _ in
            _self.tableView.reloadData()
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

extension SearchGitHubListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // ↓こうすれば初期のテキストを消せる
        searchBar.text = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.cancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task {
            do {
                try await viewModel.search(text: searchBar.text)
            } catch {
                self.alert(message: error.localizedDescription)
            }
        }
    }
}
