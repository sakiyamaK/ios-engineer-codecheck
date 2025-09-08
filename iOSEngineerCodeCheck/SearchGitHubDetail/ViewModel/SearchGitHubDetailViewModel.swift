//
//  SearchGitHubDetailViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit
import Observation

@MainActor
protocol SearchGitHubDetailViewModel {
    var loading: Bool { get }
    var repogitory: SearchGitHubDetailModel { get }
    var image: UIImage? { get }
    func fetchImage() async throws
}

@Observable
final class SearchGitHubDetailViewModelImpl: SearchGitHubDetailViewModel {

    deinit {
        print("[\(#file)] \(#function)")
    }

    private(set) var repogitory: SearchGitHubDetailModel
    private(set) var image: UIImage?
    var loading: Bool {
        task != nil
    }

    private var task: Task<Void, Error>?
    private let imageFetcher: ImageFetcher

    init(repogitory: SearchGitHubDetailModel, imageFetcher: ImageFetcher = DefaultImageFetcher()) {
        self.repogitory = repogitory
        self.imageFetcher = imageFetcher
    }
    
    func fetchImage() async throws {
        defer {
            task = nil
        }

        guard let url = repogitory.owner?.avatarUrl else { return }

        task?.cancel()
        task = Task {
            self.image = try await imageFetcher.fetchImage(from: url)
        }

        // 通信が終わったことを知らせる
        _ = try await task?.value
    }
}
