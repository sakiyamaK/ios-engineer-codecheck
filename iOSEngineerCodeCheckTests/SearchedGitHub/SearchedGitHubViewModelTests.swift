import Testing
import UIKit
@testable import iOSEngineerCodeCheck

@MainActor
struct SearchedGitHubViewModelTests {

    // MARK: - Mock Objects

    struct MockImageFetcher: ImageFetcher {
        private var result: Result<UIImage, Error>
        private(set) var callCount = 0

        init(result: Result<UIImage, Error>) {
            self.result = result
        }

        func fetchImage(from url: URL) async throws -> UIImage {
            try await Task.sleep(for: .milliseconds(100))
            switch result {
            case .success(let image):
                return image
            case .failure(let error):
                throw error
            }
        }
    }

    struct DummyError: Error, Equatable {}

    // MARK: - Test Data

    let mockRepoJSON = """
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
    """.data(using: .utf8)!

    // MARK: - Test Cases

    @Test("画像取得が成功した場合、imageプロパティが更新されること")
    func testFetchImage_Success() async throws {
        // Arrange
        let dummyImage = UIImage(systemName: "star")! // テスト用のダミー画像
        let mockImageFetcher = MockImageFetcher(result: .success(dummyImage))
        let repoModel = try API.shared.jsonDecoder.decode(SearchedGitHubModel.self, from: mockRepoJSON)

        let viewModel = SearchedGitHubViewModelImpl(
            repogitory: repoModel,
            imageFetcher: mockImageFetcher
        )

        // Act
        try await viewModel.fetchImage()

        // Assert
        #expect(mockImageFetcher.callCount == 1)
        #expect(viewModel.image === dummyImage)
        #expect(viewModel.loading == false)
    }

    @Test("画像取得が失敗した場合、エラーがスローされること")
    func testFetchImage_Failure() async throws {
        // Arrange
        let mockImageFetcher = MockImageFetcher(result: .failure(DummyError()))
        let repoModel = try API.shared.jsonDecoder.decode(SearchedGitHubModel.self, from: mockRepoJSON)

        let viewModel = SearchedGitHubViewModelImpl(
            repogitory: repoModel,
            imageFetcher: mockImageFetcher
        )

        // Act & Assert
        await #expect(throws: DummyError.self) {
            try await viewModel.fetchImage()
        }

        #expect(mockImageFetcher.callCount == 1)
        #expect(viewModel.image == nil)
        #expect(viewModel.loading == false)
    }
}
