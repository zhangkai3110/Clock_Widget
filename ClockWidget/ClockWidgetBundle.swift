//
//  ClockWidgetBundle.swift
//  ClockWidget
//
//  Created by Quentin Beukelman on 21/01/2023.
//

import WidgetKit
import SwiftUI

@main
struct ClockWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClockWidget()
        ClockWidgetLiveActivity()
    }
}
