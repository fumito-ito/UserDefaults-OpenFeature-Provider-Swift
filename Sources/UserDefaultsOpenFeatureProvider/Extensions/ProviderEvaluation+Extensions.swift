//
//  ProviderEvaluation+Extensions.swift
//  
//
//  Created by Fumito Ito on 2023/12/27.
//

import Foundation
import OpenFeature

// MARK: - Convenience

extension ProviderEvaluation {
    init(
        value: T,
        variant: UserDefaultsOpenFeatureProviderVariant,
        reason: Reason,
        errorCode: ErrorCode? = nil,
        errorMessage: String? = nil
    ) {
        self.init(
            value: value,
            variant: variant.description,
            reason: reason.rawValue,
            errorCode: errorCode,
            errorMessage: errorMessage
        )
    }
}

// MARK: - Convertion from typed ProviderEvaluation to ProviderEvaluation<Valu>
extension ProviderEvaluation where T == Bool {
    var asValueEvaluation: ProviderEvaluation<Value> {
        ProviderEvaluation<Value>(
            value: Value.of(self.value),
            variant: self.variant,
            reason: self.reason,
            errorCode: self.errorCode,
            errorMessage: self.errorMessage
        )
    }
}

extension ProviderEvaluation where T == String {
    var asValueEvaluation: ProviderEvaluation<Value> {
        ProviderEvaluation<Value>(
            value: Value.of(self.value),
            variant: self.variant,
            reason: self.reason,
            errorCode: self.errorCode,
            errorMessage: self.errorMessage
        )
    }
}

extension ProviderEvaluation where T == Int64 {
    var asValueEvaluation: ProviderEvaluation<Value> {
        ProviderEvaluation<Value>(
            value: Value.of(self.value),
            variant: self.variant,
            reason: self.reason,
            errorCode: self.errorCode,
            errorMessage: self.errorMessage
        )
    }
}

extension ProviderEvaluation where T == Double {
    var asValueEvaluation: ProviderEvaluation<Value> {
        ProviderEvaluation<Value>(
            value: Value.of(self.value),
            variant: self.variant,
            reason: self.reason,
            errorCode: self.errorCode,
            errorMessage: self.errorMessage
        )
    }
}

extension ProviderEvaluation where T == Date {
    var asValueEvaluation: ProviderEvaluation<Value> {
        ProviderEvaluation<Value>(
            value: Value.of(self.value),
            variant: self.variant,
            reason: self.reason,
            errorCode: self.errorCode,
            errorMessage: self.errorMessage
        )
    }
}

extension ProviderEvaluation where T == [Value] {
    var asValueEvaluation: ProviderEvaluation<Value> {
        ProviderEvaluation<Value>(
            value: Value.list(self.value),
            variant: self.variant,
            reason: self.reason,
            errorCode: self.errorCode,
            errorMessage: self.errorMessage
        )
    }
}

extension ProviderEvaluation where T == [String: Value] {
    var asValueEvaluation: ProviderEvaluation<Value> {
        ProviderEvaluation<Value>(
            value: Value.structure(self.value),
            variant: self.variant,
            reason: self.reason,
            errorCode: self.errorCode,
            errorMessage: self.errorMessage
        )
    }
}
