//
//  SearchedGitHubViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit
import Observation

@MainActor
protocol SearchedGitHubViewModel {
    var loading: Bool { get }
    var repogitory: SearchedGitHubModel { get }
    var image: UIImage? { get }
}

@Observable
final class SearchedGitHubViewModelImpl: SearchedGitHubViewModel {

    deinit {
        print("[\(#file)] \(#function)")
    }

    private(set) var repogitory: SearchedGitHubModel
    private(set) var image: UIImage?
    var loading: Bool {
        task != nil
    }

    private var task: Task<Void, Error>?

    init(repogitory: SearchedGitHubModel) {
        self.repogitory = repogitory

        task?.cancel()
        task = Task {
            do {
                let image = try await repogitory.owner?.getImage()
                await MainActor.run {
                    self.image = image
                }
            } catch {
                await MainActor.run {
                    self.task = nil
                }
                throw error
            }
            await MainActor.run {
                task = nil
            }
        }
    }
}
