import Testing
import Foundation
@testable import iOSEngineerCodeCheck

@MainActor
struct SearchGitHubListViewModelTests {

    struct DummyError: Error, Equatable { }

    // MARK: - Test Cases

    @Test("検索が成功した場合、リポジトリリストが更新されること")
    func testSearch_Success() async throws {
        // Arrange
        let mockAPI = MockAPI(result: .success(SearchRepogitoriesDTO.mockSuccess.items))
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
