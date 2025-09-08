import Foundation
import Observation

@MainActor
protocol SearchGitHubListViewModel {
    var loading: Bool { get }
    var repogitories: [SearchGitHubListModel] { get }
    var sortType: SearchGithubSortType { get }
    var initialLoading: Bool { get }

    func clearText()
    func set(searchText: String?)
    func search() async throws
    func search(sortType: SearchGithubSortType) async throws
    func refresh() async throws
}

@Observable
final class SearchGitHubListViewModelImpl: SearchGitHubListViewModel {
    deinit {
        print("[\(#file)] \(#function)")
    }
    private var _preSearchText: String?
    private var _searchText: String?
    private var _isRefresh: Bool = false
    private(set) var repogitories: [SearchGitHubListModel] = []
    private(set) var sortType: SearchGithubSortType = .default
    var loading: Bool {
        task != nil
    }
    var initialLoading: Bool {
        loading && !_isRefresh
    }

    private var task: Task<Void, Error>?
    private let api: APIProtocol

    init(api: APIProtocol = API.shared) {
        self.api = api
    }

    func clearText() {
        task?.cancel()
        _searchText = nil
    }

    func set(searchText: String?){
        _searchText = searchText
    }

    func search() async throws {
        try await search(
            text: _searchText,
            sortType: sortType,
            isRefresh: false
        )
    }

    func search(sortType: SearchGithubSortType) async throws {
        try await search(
            text: _searchText,
            sortType: sortType,
            isRefresh: false
        )
    }

    func refresh() async throws {
        try await search(
            text: _searchText,
            sortType: sortType,
            isRefresh: true
        )
    }

}

private extension SearchGitHubListViewModelImpl {
    func checkNessarySearch(seachText: String, sortType: SearchGithubSortType, isRefresh: Bool) -> Bool {
        !seachText.isEmpty
        && (
            seachText != _preSearchText
            || sortType != self.sortType
            || isRefresh
        )
    }

    func search(text searchText: String?, sortType: SearchGithubSortType, isRefresh: Bool) async throws {
        defer {
            task = nil
        }
        guard let searchText, checkNessarySearch(seachText: searchText, sortType: sortType, isRefresh: isRefresh) else {
            return
        }
        self._preSearchText = searchText
        self.sortType = sortType
        self._isRefresh = isRefresh

        task?.cancel()
        task = Task {
            self.repogitories = try await api.searchRepogitories(
                parameter: .init(
                    q: searchText,
                    sort: sortType
                )
            )
        }

        // 通信が終わったことを知らせる
        _ = try await task?.value
    }
}
