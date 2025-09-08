import Foundation
import Observation

@MainActor
protocol SearchGitHubListViewModel {
    var loading: Bool { get }
    var repogitories: [SearchGitHubListModel] { get }
    func cancelSearch()
    func search(text searchText: String?) async throws
    func refresh() async throws
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
    private let api: APIProtocol

    init(api: APIProtocol = API.shared) {
        self.api = api
    }

    func cancelSearch() {
        task?.cancel()
    }

    func search(text searchText: String?) async throws {
        try await search(text: searchText, isRefresh: false)
    }


    func refresh() async throws {
        try await search(text: _searchText, isRefresh: true)
    }
}

private extension SearchGitHubListViewModelImpl {
    func search(text searchText: String?, isRefresh: Bool) async throws {
        defer {
            task = nil
        }
        guard let searchText, !searchText.isEmpty, isRefresh || _searchText != searchText else {
            return
        }
        _searchText = searchText

        task?.cancel()
        task = Task {
            self.repogitories = try await api.searchRepogitories(q: searchText)
        }

        // 通信が終わったことを知らせる
        _ = try await task?.value
    }
}
