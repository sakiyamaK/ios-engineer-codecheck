//
//  UIViewController+Observation.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/06.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

public protocol ObservableUIKit: AnyObject, Sendable {}
public extension ObservableUIKit {

    // 監視対象のパラメータがnilになったら停止する
    @MainActor
    @discardableResult
    func tracking<T>(
        useInitialValue: Bool = true,
        shouldStop: @escaping (@Sendable () -> Bool) = { false },
        _ apply: @escaping @Sendable @MainActor () -> T?,
        onChange: @escaping (@Sendable @MainActor (Self, T) -> Void)
    ) -> Self {

        if useInitialValue, let value = apply() {
            onChange(self, value)
        }

        _ = withObservationTracking(apply, onChange: {[weak self] in

            Task { @MainActor in
                guard let self, let value = apply() else { return }

                onChange(self, value)

                if shouldStop() {
                    return
                }

                self.tracking(
                    useInitialValue: useInitialValue,
                    shouldStop: shouldStop,
                    apply,
                    onChange: onChange
                )
            }
        })

        return self
    }

    // 監視対象のパラメータがnilになったら停止する
    @MainActor
    @discardableResult
    func tracking<T>(
        useInitialValue: Bool = true,
        sendOptional: Bool = false,
        shouldStop: @escaping (@Sendable () -> Bool) = { false },
        _ apply: @escaping @Sendable @MainActor () -> T?,
        to : ReferenceWritableKeyPath<Self, T>
    ) -> Self {
        tracking(
            useInitialValue: useInitialValue,
            shouldStop: shouldStop,
            apply) { _self, value in
                _self[keyPath: to] = value
            }
    }

    // 監視対象のパラメータがnilになっても監視し続ける
    @MainActor
    @discardableResult
    func trackingOptional<T>(
        useInitialValue: Bool = true,
        shouldStop: @escaping (@Sendable () -> Bool) = { false },
        _ apply: @escaping @Sendable @MainActor () -> T?,
        onChange: @escaping (@Sendable @MainActor (Self, T?) -> Void)
    ) -> Self {

        if useInitialValue {
            onChange(self, apply())
        }

        _ = withObservationTracking(apply, onChange: {[weak self] in

            Task { @MainActor in
                guard let self else { return }

                onChange(self, apply())

                if shouldStop() {
                    return
                }

                self.tracking(
                    useInitialValue: useInitialValue,
                    shouldStop: shouldStop,
                    apply,
                    onChange: onChange
                )
            }
        })
        return self
    }

    // 監視対象のパラメータがnilになっても監視し続ける
    @MainActor
    @discardableResult
    func trackingOptional<T>(
        useInitialValue: Bool = true,
        shouldStop: @escaping (@Sendable () -> Bool) = { false },
        _ apply: @escaping @Sendable @MainActor () -> T?,
        to: ReferenceWritableKeyPath<Self, T?>
    ) -> Self {

        trackingOptional(
            useInitialValue: useInitialValue,
            shouldStop: shouldStop,
            apply) { _self, value in
                _self[keyPath: to] = value
            }
    }
}

extension UIView: @retroactive Sendable {}
extension UIView: ObservableUIKit {}
extension UIViewController: @retroactive Sendable {}
extension UIViewController: ObservableUIKit {}
