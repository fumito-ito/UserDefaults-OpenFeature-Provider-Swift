//
//  UserDefaultsOpenFeatureProviderStatus.swift
//
//
//  Created by Fumito Ito on 2024/01/04.
//

import Foundation

public enum UserDefaultsOpenFeatureProviderStatus: String {
    case notReady = "NOT_READY"
    case ready = "READY"
    @available(*, deprecated, message: "`STALE` is not supported in this library")
    case stale = "STALE"
    case error = "ERROR"
}
