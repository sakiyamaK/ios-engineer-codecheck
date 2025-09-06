
import UIKit

// ServiceErrorが他の場所で定義されていることを想定
// enum ServiceError: Error {
//     case decodeImage
// }

protocol ImageFetcher {
    func fetchImage(from url: URL) async throws -> UIImage
}

struct DefaultImageFetcher: ImageFetcher {
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
