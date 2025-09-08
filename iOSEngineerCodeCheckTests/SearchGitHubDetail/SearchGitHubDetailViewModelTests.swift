import Testing
import UIKit
@testable import iOSEngineerCodeCheck

@MainActor
struct SearchGitHubDetailViewModelTests {

    struct DummyError: Error, Equatable {}

    // MARK: - Test Cases

    @Test("画像取得が成功した場合、imageプロパティが更新されること")
    func testFetchImage_Success() async throws {

        let dummyImage = UIImage.star
        let mockImageFetcher = MockImageFetcher(
            result: .success(dummyImage)
        )

        let viewModel = SearchGitHubDetailViewModelImpl(
            repogitory: SearchRepogitoriesDTO.mockSuccess.items.first!,
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

        let mockImageFetcher = MockImageFetcher(result: .failure(DummyError()))
        let repoModel = SearchRepogitoriesDTO.mockSuccess.items.first!

        let viewModel = SearchGitHubDetailViewModelImpl(
            repogitory: repoModel,
            imageFetcher: mockImageFetcher
        )

        await #expect(throws: DummyError.self) {
            try await viewModel.fetchImage()
        }

        #expect(mockImageFetcher.callCount == 1)
        #expect(viewModel.image == nil)
        #expect(viewModel.loading == false)
    }
}
