//
//  UserDefaults+Extensions.swift
//
//
//  Created by Fumito Ito on 2023/12/27.
//

import Foundation

extension UserDefaults {
    func has(_ key: String) -> Bool {
        object(forKey: key) != nil
    }
}
