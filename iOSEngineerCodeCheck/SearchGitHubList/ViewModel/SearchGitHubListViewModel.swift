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
    private let api: APIProtocol

    init(api: APIProtocol = API.shared) {
        self.api = api
    }

    func search(text searchText: String?) async throws {
        defer {
            task = nil
        }
        guard let searchText, !searchText.isEmpty, _searchText != searchText else {
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

    func cancelSearch() {
        task?.cancel()
    }
}
