//
//  SearchGitHubListViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation
import Observation

@MainActor
protocol SearchGitHubListViewModel {
    var loading: Bool { get }
    var repogitories: [SearchGitHubListModel] { get }
    func search(text searchText: String?) async throws
    func cancelSearch()
}

@Observable
final class SearchGitHubListViewModelImpl: SearchGitHubListViewModel {
    deinit {
        print("[\(#file)] \(#function)")
    }

    private var _searchText: String = ""
    private(set) var repogitories: [SearchGitHubListModel] = []
    var loading: Bool {
        task != nil
    }

    private var task: Task<Void, Error>?

    func search(text searchText: String?) async throws {

        guard let searchText, !searchText.isEmpty, _searchText != searchText else {
            return
        }

        _searchText = searchText
        task?.cancel()
        task = Task {
            do {
                let repogitories = try await API.shared.searchRepogitories(q: searchText)
                await MainActor.run {
                    self.repogitories = repogitories
                }
            } catch {
                await MainActor.run {
                    self.task = nil
                }
                throw error
            }
            await MainActor.run {
                task = nil
            }
        }
    }

    func cancelSearch() {
        task?.cancel()
    }
}
