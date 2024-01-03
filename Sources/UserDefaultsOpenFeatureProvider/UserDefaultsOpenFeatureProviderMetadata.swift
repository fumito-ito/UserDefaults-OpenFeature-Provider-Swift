//
//  UserDefaultsOpenFeatureProviderMetadata.swift
//
//
//  Created by Fumito Ito on 2023/12/25.
//

import Foundation
import OpenFeature

public struct UserDefaultsOpenFeatureProviderMetadata: ProviderMetadata {
    public var name: String? {
        return "UserDefaultsOpenFeatureProvider"
    }
}
