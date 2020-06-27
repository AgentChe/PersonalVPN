//
// Created by Anton Serov on 22.11.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation

protocol ResponseProtocol {
    init(rawResponse: Dictionary<String, AnyObject>) throws
}
