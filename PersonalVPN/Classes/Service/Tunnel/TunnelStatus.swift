//
// Created by Anton Serov on 23.10.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation

enum TunnelStatus: String {
    case invalid = "Invalid" 
    case disconnected = "Disconnected" 
    case connecting = "Connecting" 
    case connected = "Connected" 
    case reasserting = "Reasserting" 
    case disconnecting = "Disconnecting" 
}