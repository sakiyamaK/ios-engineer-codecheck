import Testing
import Foundation
@testable import iOSEngineerCodeCheck

@MainActor
struct SearchGitHubListViewModelTests {

    struct DummyError: Error, Equatable { }

    // MARK: - Test Cases

    @Test("テキスト入力して検索が成功した場合、リポジトリリストが更新されること")
    func testSearch_Success() async throws {
        let mockAPI = MockAPI(result: .success(SearchRepogitoriesDTO.mockSuccess.items))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        viewModel.set(searchText: "swift")
        try await viewModel.search()

        // Assert
        #expect(mockAPI.callCount == 1)
        #expect(mockAPI.receivedParameter?.q == "swift")
        #expect(viewModel.repogitories.count == 1)
        #expect(viewModel.repogitories.first?.fullName == "apple/swift")
        #expect(viewModel.loading == false)
    }

    @Test("テキスト入力して検索が失敗した場合、エラーがスローされること")
    func testSearch_Failure() async throws {
        // Arrange
        let mockAPI = MockAPI(result: .failure(DummyError()))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        // Act & Assert
        await #expect(throws: DummyError.self) {
            viewModel.set(searchText: "swift")
            try await viewModel.search()
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

        viewModel.set(searchText: "")
        try await viewModel.search()

        // Assert
        #expect(mockAPI.callCount == 0)
        #expect(viewModel.repogitories.isEmpty == true)
    }

    @Test("検索キーワードがnilの場合、APIが呼び出されないこと")
    func testSearch_NilQuery() async throws {
        // Arrange
        let mockAPI = MockAPI(result: .success([]))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        try await viewModel.search()

        // Assert
        #expect(mockAPI.callCount == 0)
        #expect(viewModel.repogitories.isEmpty == true)
    }

    @Test("ソートを切り替えて文字が入力されてなければ、APIが呼び出されないこと")
    func testSortSearch_NilQuery() async throws {
        let mockAPI = MockAPI(result: .success(SearchRepogitoriesDTO.mockSuccess.items))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        try await viewModel.search(sortType: .forks)

        // Assert
        #expect(mockAPI.callCount == 0)
        #expect(viewModel.repogitories.isEmpty == true)
    }

    @Test("ソートを切り替えて文字が入力されていれば、APIが呼び出されないこと")
    func testSortSearch_Success() async throws {
        let mockAPI = MockAPI(result: .success(SearchRepogitoriesDTO.mockSuccess.items))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        viewModel.set(searchText: "swift")
        try await viewModel.search(sortType: .helpWantedIssues)

        // Assert
        #expect(mockAPI.callCount == 1)
        #expect(mockAPI.receivedParameter?.q == "swift")
        #expect(viewModel.repogitories.count == 1)
        #expect(viewModel.repogitories.first?.fullName == "apple/swift")
        #expect(viewModel.loading == false)
    }

    @Test("同じ条件で検索した場合は何も起こらないこと、APIが呼び出されないこと")
    func testSearch_Twice_NoAPI() async throws {
        let mockAPI = MockAPI(result: .success(SearchRepogitoriesDTO.mockSuccess.items))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        viewModel.set(searchText: "swift")
        try await viewModel.search(sortType: .helpWantedIssues)

        viewModel.set(searchText: "swift")
        try await viewModel.search(sortType: .helpWantedIssues)

        // Assert
        #expect(mockAPI.callCount == 1)
        #expect(mockAPI.receivedParameter?.q == "swift")
        #expect(viewModel.repogitories.count == 1)
        #expect(viewModel.repogitories.first?.fullName == "apple/swift")
        #expect(viewModel.loading == false)
    }

    @Test("同じ条件でリフレッシュした場合はAPIが呼び出されること")
    func testSearch_Twice_Refresh() async throws {
        let mockAPI = MockAPI(result: .success(SearchRepogitoriesDTO.mockSuccess.items))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        viewModel.set(searchText: "swift")
        try await viewModel.search(sortType: .helpWantedIssues)

        try await viewModel.refresh()


        // Assert
        #expect(mockAPI.callCount == 2)
        #expect(mockAPI.receivedParameter?.q == "swift")
        #expect(viewModel.repogitories.count == 1)
        #expect(viewModel.repogitories.first?.fullName == "apple/swift")
        #expect(viewModel.loading == false)
    }

    @Test("検索した後にテキストをクリアにしてソートを切り替えたら検索されないこと")
    func testClearText_NoAPI() async throws {
        let mockAPI = MockAPI(result: .success(SearchRepogitoriesDTO.mockSuccess.items))
        let viewModel = SearchGitHubListViewModelImpl(api: mockAPI)

        viewModel.set(searchText: "swift")
        try await viewModel.search(sortType: .helpWantedIssues)

        viewModel.clearText()

        try await viewModel.search(sortType: .forks)

        // Assert
        #expect(mockAPI.callCount == 1)
        #expect(mockAPI.receivedParameter?.q == "swift")
        #expect(viewModel.repogitories.count == 1)
        #expect(viewModel.repogitories.first?.fullName == "apple/swift")
        #expect(viewModel.loading == false)
    }

}
