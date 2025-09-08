
import UIKit

protocol ImageFetcher {
    func fetchImage(from url: URL) async throws -> UIImage
}

final class DefaultImageFetcher: ImageFetcher {
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let image = UIImage(data: data) else {
            throw ServiceError.decodeImage
        }
        return image
    }
}

// MARK: - Mock Objects
#if DEBUG
final class MockImageFetcher: ImageFetcher {
    private var result: Result<UIImage, Error>
    private(set) var callCount = 0

    init(result: Result<UIImage, Error>) {
        self.result = result
    }

    func fetchImage(from url: URL) async throws -> UIImage {
        self.callCount += 1
        try await Task.sleep(for: .milliseconds(100))
        switch result {
        case .success(let image):
            return image
        case .failure(let error):
            throw error
        }
    }
}
#endif
