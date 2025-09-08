//
//  SearchGitHubListViewControllerTest.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit
import Observation
import XCTest
@testable import iOSEngineerCodeCheck

@MainActor
final class SearchGitHubListViewControllerTests: XCTestCase {

    // 各テストの実行前に呼ばれるセットアップメソッド
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // 各テストの実行後に呼ばれる後片付けメソッド
    override func tearDownWithError() throws {
    }

    // MARK: - Tests

    func test_SearchGitHubListの初期状態() {
        let app = XCUIApplication()
        app.launchArguments = [ProcessInfoForUITest.searchGitHubList.key]
        app.launch()

        // 検索バー
        let searchField = app.searchField(key: SearchGitHubListAccessibilityIdentifier.searchBar.rawValue)
        XCTAssertTrue(searchField.exists)

        // 初期値を確認
        guard let initialText = searchField.value as? String else {
            XCTFail("searchFieldの.valueをStringとして取得できませんでした。")
            return
        }
        XCTAssertEqual(initialText, "GitHubのリポジトリを検索できるよー")

        // indicator
        let indicator = app.activityIndicators[SearchGitHubListAccessibilityIdentifier.indicator.rawValue]
        XCTAssertTrue(indicator.exists)

        //初期値を確認
        XCTAssertEqual(indicator.value as? String, 0.description)

        // セル
        let cells = app.tables.cells
        // 初期値を確認
        XCTAssertEqual(cells.count, 0)
    }
}

private extension XCUIApplication {
    func searchField(key: String) -> XCUIElement {
        let searchBarContainer = self.otherElements[key]
        let searchField = searchBarContainer.searchFields.element
        return searchField
    }
}
