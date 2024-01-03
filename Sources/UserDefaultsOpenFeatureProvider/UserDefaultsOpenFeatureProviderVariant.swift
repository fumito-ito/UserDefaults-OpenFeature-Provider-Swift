//
//  UserDefaultsOpenFeatureProviderVariant.swift
//
//
//  Created by Fumito Ito on 2023/12/27.
//

import Foundation
import OpenFeature

/// > In cases of normal execution, the provider SHOULD populate the resolution details structure's variant field with a string identifier corresponding to the returned flag value.
///
/// For example, the flag value might be 3.14159265359, and the variant field's value might be "pi".
///
/// The value of the variant field might only be meaningful in the context of the flag management system associated with the provider.
/// For example, the variant may be a UUID corresponding to the variant in the flag management system, or an index corresponding to the variant in the flag management system.
///
/// https://openfeature.dev/specification/sections/providers#requirement-224
typealias UserDefaultsOpenFeatureProviderVariant = Value
