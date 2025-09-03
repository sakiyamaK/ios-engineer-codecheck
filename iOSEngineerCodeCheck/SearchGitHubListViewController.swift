//
//  ViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

final class SearchGitHubListViewController: UITableViewController {

    deinit {
        print("[\(#file)] \(#function): \(#line)")
    }

    private let nextSeguueIdentifier: String = "Detail"
    private let gitHubRepositoryUrlEndPointStr: String = "https://api.github.com/search/repositories"
    private let cellIdentifier: String = "Repository"

    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var repogitories: [[String: Any]] = []
    private var selectepogitory: [String: Any] = [:]

    private var task: URLSessionTask?

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == nextSeguueIdentifier,
              let searchedGitHubViewController = segue.destination as? SearchedGitHubViewController else {
            return
        }
        searchedGitHubViewController.selectRepogitory = selectepogitory
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
        cell.textLabel?.text = repository["full_name"] as? String ?? ""
        cell.detailTextLabel?.text = repository["language"] as? String ?? ""
        cell.tag = indexPath.row
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectepogitory = repogitories[safe: indexPath.row] else {
            // 本来はアラートを出す
            return
        }
        self.selectepogitory = selectepogitory
        performSegue(withIdentifier: nextSeguueIdentifier, sender: self)
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

        guard let url = gitHubRepositoryUrlEndPointStr.url(
            withQueryItemDic: ["q": searchWord]
        ) else {
            // 本来はアラートを出す
            return
        }

        task = URLSession.shared.dataTask(with: url) {[weak self] (data, res, err) in
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
                print("[\(url)] : data is nil")
                return
            }
            do {
                guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    // 本来はアラートを出す
                    print("[\(url)] : json serialization error")
                    return
                }
                guard let items = obj["items"] as? [[String: Any]] else {
                    // 本来はアラートを出す
                    print("[\(url)] : items is nil")
                    return
                }
                self.repogitories = items
                DispatchQueue.main.async {[weak self] in
                    self?.tableView.reloadData()
                }
            } catch let err {
                // 本来はアラートを出す
                print(err.localizedDescription)
                return
            }
        }
        // これ呼ばなきゃAPI通信が発生しません
        task?.resume()
    }
}

