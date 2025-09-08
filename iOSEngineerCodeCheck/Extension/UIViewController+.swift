//
//  UIViewController+.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    var withUINavigationController: UINavigationController {
        UINavigationController(rootViewController: self)
    }

    func alert(title: String? = nil, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(vc, animated: true, completion: nil)
    }
}
