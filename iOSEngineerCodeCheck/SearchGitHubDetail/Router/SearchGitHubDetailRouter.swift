//
//  SearchedGtiHubRouter.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

@MainActor
protocol SearchGitHubDetailRouter {
}

@MainActor
final class SearchGitHubDetailRouterImpl {
    deinit {
        print("[\(#file)] \(#function)")
    }

    private weak var viewController: UIViewController?
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    @MainActor
    static func makeModules(repogitory: SearchGitHubDetailModel) -> SearchGitHubDetailViewController {
        let viewModel = SearchGitHubDetailViewModelImpl(repogitory: repogitory)
        let vc = SearchGitHubDetailViewController.instantiate(viewModel: viewModel)
        let router = SearchGitHubDetailRouterImpl(viewController: vc)
        vc.set(router: router)
        return vc
    }
}

extension SearchGitHubDetailRouterImpl: SearchGitHubDetailRouter {
}

extension SearchGitHubDetailRouterImpl {
    @MainActor
    static func makeModulesForUITest() -> SearchGitHubDetailViewController {
        let viewModel = SearchGitHubDetailViewModelImpl(
            repogitory: SearchRepogitoriesDTO.mockSuccess.items.first!,
            imageFetcher: MockImageFetcher(result: .success(UIImage.star))
        )
        let vc = SearchGitHubDetailViewController.instantiate(viewModel: viewModel)
        let router = SearchGitHubDetailRouterImpl(viewController: vc)
        vc.set(router: router)
        return vc
    }

}

