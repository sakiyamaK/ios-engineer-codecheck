import Testing
import Foundation
@testable import iOSEngineerCodeCheck

@MainActor
struct SearchGitHubListViewModelTests {

    // MARK: - Mock Objects

    final class MockAPI: APIProtocol {
        private var result: Result<[SearchGitHubListModel], Error>

        private(set) var callCount = 0
        private(set) var receivedQuery: String?

        init(result: Result<[SearchGitHubListModel], Error>) {
            self.result = result
        }

        func searchRepogitories(q: String) async throws -> [SearchGitHubListModel] {
            callCount += 1
            receivedQuery = q
            try await Task.sleep(for: .milliseconds(100))
            switch result {
            case .success(let models):
                return models
            case .failure(let error):
                throw error
            }
        }
    }

    struct DummyError: Error, Equatable { }

    // MARK: - Test Data

    let mockSuccessJSON = """
    [
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
    ]
    """.data(using: .utf8)!

    // MARK: - Test Cases

    @Test("検索が成功した場合、リポジトリリストが更新されること")
    func testSearch_Success() async throws {
        // Arrange
        let mockModels = try API.shared.jsonDecoder.decode([SearchGitHubListModel].self, from: mockSuccessJSON)
        let mockAPI = MockAPI(result: .success(mockModels))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        // Act
        try await viewModel.search(text: "swift")

        // Assert
        #expect(mockAPI.callCount == 1)
        #expect(mockAPI.receivedQuery == "swift")
        #expect(viewModel.repogitories.count == 1)
        #expect(viewModel.repogitories.first?.fullName == "apple/swift")
        #expect(viewModel.loading == false)
    }

    @Test("検索が失敗した場合、エラーがスローされること")
    func testSearch_Failure() async throws {
        // Arrange
        let mockAPI = MockAPI(result: .failure(DummyError()))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        // Act & Assert
        await #expect(throws: DummyError.self) {
            try await viewModel.search(text: "swift")
        }
        
        #expect(mockAPI.callCount == 1)
        #expect(viewModel.repogitories.isEmpty == true)
        #expect(viewModel.loading == false)
    }

    @Test("検索キーワードが空の場合、APIが呼び出されないこと")
    func testSearch_EmptyQuery() async throws {
        // Arrange
        let mockAPI = MockAPI(result: .success([]))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        // Act
        try await viewModel.search(text: "")

        // Assert
        #expect(mockAPI.callCount == 0)
        #expect(viewModel.repogitories.isEmpty == true)
    }

    @Test("検索キーワードがnilの場合、APIが呼び出されないこと")
    func testSearch_NilQuery() async throws {
        // Arrange
        let mockAPI = MockAPI(result: .success([]))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        // Act
        try await viewModel.search(text: nil)

        // Assert
        #expect(mockAPI.callCount == 0)
        #expect(viewModel.repogitories.isEmpty == true)
    }
}
