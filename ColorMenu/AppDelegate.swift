//
//  AppDelegate.swift
//  ColorMenu
//
//  Created by Carson Katri on 11/23/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    var settings = PickerSettings()
    let statusItem = NSStatusBar.system.statusItem(withLength: 185)
    
    let colorSpaces: [Int: (String, NSColorSpace)] = [
        0: ("Device RGB", .deviceRGB),
        1: ("P3", .displayP3),
        2: ("sRGB", .sRGB),
        3: ("Generic RGB", .genericRGB),
        4: ("Adobe RGB", .adobeRGB1998),
    ]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        settings.colorSpace = getColorspace()
        settings.displayMode = getDisplayMode()
        let contentView = ContentView().environmentObject(settings)
        
        if let button = statusItem.button {
            let view = NSHostingView(rootView: contentView)
            view.frame = CGRect(x: 0, y: 0, width: 185, height: 25)
            button.addSubview(view)
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func constructMenu() {
        let menu = NSMenu()
        
        for (_, colorSpace) in colorSpaces.sorted(by: { $0.key < $1.key }) {
            let item = NSMenuItem(title: colorSpace.0, action: #selector(clickedColorspace(_:)), keyEquivalent: "")
            item.state = colorSpace.1 == settings.colorSpace ? .on : .off
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Display Mode", action: nil, keyEquivalent: ""))
        for displayMode in ["RGB", "Hex"] {
            let item = NSMenuItem(title: displayMode, action: #selector(clickedDisplayMode(_:)), keyEquivalent: "")
            if (displayMode == "RGB" && settings.displayMode == .rgb) || (displayMode == "Hex" && settings.displayMode == .hex) {
                item.state = .on
            }
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func getColorspace() -> NSColorSpace {
        guard let colorSpace = colorSpaces[UserDefaults.standard.integer(forKey: "colorSpace")] else {
            setColorspace(0)
            return .deviceRGB
        }
        return colorSpace.1
    }
    
    func setColorspace(_ key: Int) {
        UserDefaults.standard.set(key, forKey: "colorSpace")
        settings.colorSpace = colorSpaces[key]?.1 ?? .deviceRGB
    }
    
    @objc func clickedColorspace(_ sender: NSMenuItem) {
        sender.state = .on
        if let menu = sender.menu {
            for (i, item) in menu.items.enumerated() {
                if item.title == sender.title {
                    setColorspace(i)
                } else if item.title != "RGB" && item.title != "Hex" {
                    item.state = .off
                }
            }
        }
    }
    
    func getDisplayMode() -> PickerSettings.DisplayMode {
        PickerSettings.DisplayMode(rawValue: UserDefaults.standard.integer(forKey: "displayMode")) ?? .rgb
    }
    
    func setDisplayMode(_ mode: PickerSettings.DisplayMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: "displayMode")
        settings.displayMode = mode
    }
    
    @objc func clickedDisplayMode(_ sender: NSMenuItem) {
        setDisplayMode(sender.title == "RGB" ? .rgb : .hex)
        sender.state = .on
        if let items = sender.menu?.items {
            for item in items {
                if sender.title == item.title {
                    item.state = .on
                } else if (sender.title == "RGB" && item.title == "Hex") || (sender.title == "Hex" && item.title == "RGB") {
                    item.state = .off
                }
            }
        }
    }
}
