//
//  Bool+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-07.
//

import Foundation

extension Bool {

    var inverted: Self {
        return !self
    }

    var isTruthy: Bool {
        return self == true
    }

    var isFalsy: Bool {
        return self == false
    }

}
