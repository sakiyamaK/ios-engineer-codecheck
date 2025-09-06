//
//  SearchedGtiHubRouter.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

@MainActor
protocol SearchedGitHubRouter {
}

@MainActor
final class SearchedGitHubRouterImpl {
    deinit {
        print("[\(#file)] \(#function)")
    }

    private weak var viewController: UIViewController?
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    @MainActor
    static func makeModules(repogitory: SearchedGitHubModel) -> SearchedGitHubViewController {
        let viewModel = SearchedGitHubViewModelImpl(repogitory: repogitory)
        let vc = SearchedGitHubViewController.instantiate(viewModel: viewModel)
        let router = SearchedGitHubRouterImpl(viewController: vc)
        vc.set(router: router)
        return vc
    }
}

extension SearchedGitHubRouterImpl: SearchedGitHubRouter {
}

