//
//  Untitled.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

@MainActor
protocol SearchGitHubListRouter {
    func pushToDetail(model: SearchGitHubListModel)
}

@MainActor
final class SearchGitHubListRouterImpl {
    deinit {
        print("[\(#file)] \(#function)")
    }

    private weak var viewController: UIViewController?
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    @MainActor
    static func makeModules() -> SearchGitHubListViewController {
        let viewModel = SearchGitHubListViewModelImpl()
        let vc = SearchGitHubListViewController.instantiate(viewModel: viewModel)
        let router = SearchGitHubListRouterImpl(viewController: vc)
        vc.set(router: router)
        return vc
    }
}

extension SearchGitHubListRouterImpl: SearchGitHubListRouter {
    func pushToDetail(model: SearchGitHubListModel) {
        guard let viewController, let nav = viewController.navigationController else { return }
        let next = SearchedGitHubRouterImpl.makeModules(repogitory: model)
        nav.pushViewController(next, animated: true)
    }
}

