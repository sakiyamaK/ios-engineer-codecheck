//
//  UIView+Constraint.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

extension UIView {
    func applyArroundConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func applyCenterConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
