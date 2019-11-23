//
//  PickerSettings.swift
//  ColorMenu
//
//  Created by Carson Katri on 11/23/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import AppKit

class PickerSettings: ObservableObject {
    @Published var colorSpace: NSColorSpace = .deviceRGB
}
