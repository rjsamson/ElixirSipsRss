//
//  ArrayExtension.swift
//  ElixirSipsRss
//
//  Created by Robert J Samson on 9/3/15.
//  Copyright (c) 2015 rjsamson. All rights reserved.
//

import Foundation

extension Array {
    func take(var limit: Int) -> Array {
        if (limit > count) {
            limit = count
        }
        return Array(self[0..<limit])
    }
}
