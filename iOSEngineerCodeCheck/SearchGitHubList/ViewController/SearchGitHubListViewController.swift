//
//  ViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

final class SearchGitHubListViewController: UITableViewController {

    static func instantiate() -> SearchGitHubListViewController {
        let vc = UIStoryboard(name: "SearchGitHubListViewController", bundle: nil).instantiateInitialViewController() as! SearchGitHubListViewController
        vc.title = "検索"
        return vc
    }

    deinit {
        print("[\(#file)] \(#function): \(#line)")
    }

    private let cellIdentifier: String = "Repository"

    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var repogitories: [SearchedGitHubModel] = []

    private var task: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.text = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        task?.cancel()
        task = nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repogitories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier),
            let repository = repogitories[safe: indexPath.row] else {
            // クラッシュログをサーバーにあげる
            fatalError()
        }
        cell.textLabel?.text = repository.language
        cell.detailTextLabel?.text = repository.fullName
        cell.tag = indexPath.row
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectepogitory = repogitories[safe: indexPath.row] else {
            // 本来はアラートを出す
            return
        }
        let nextVC = SearchedGitHubViewController.instantiate(selectRepogitory: selectepogitory)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension SearchGitHubListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // ↓こうすれば初期のテキストを消せる
        searchBar.text = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        task?.cancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchWord = searchBar.text, !searchWord.isEmpty else {
            // 本来はアラートを出す
            return
        }

        task?.cancel()
        task = Task {
            do {
                self.repogitories = try await API.shared.searchRepogitories(q: searchWord)
                self.tableView.reloadData()
            } catch {
                // 本来はアラートを出す
                print(error.localizedDescription)
            }
        }

    }
}
