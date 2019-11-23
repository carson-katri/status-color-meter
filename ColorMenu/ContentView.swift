//
//  ContentView.swift
//  ColorMenu
//
//  Created by Carson Katri on 11/23/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var image: CGImage? = nil
    @EnvironmentObject var settings: PickerSettings
    @State private var color: NSColor = NSColor.white.usingColorSpace(.deviceRGB)
    
    var body: some View {
        HStack {
            if image != nil {
                ZStack {
                    Image(decorative: image!, scale: 1)
                        .scaleEffect(2)
                    Rectangle()
                        .frame(width: 5, height: 5)
                        .background(Color((color ?? .clear).usingColorSpace(settings.colorSpace) ?? .clear))
                        .border(Color.white, width: 1)
                }
            }
            if color != nil {
                HStack(spacing: 0) {
                    Text("R:")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    Text({
                        let red = "\(Int(255 * color!.redComponent))"
                        return "\(String(repeating: " ", count: 3 - red.count))\(red)"
                    }())
                        .font(.system(size: 13, design: .monospaced))
                    
                    Text(" G:")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    Text({
                        let green = "\(Int(255 * color!.greenComponent))"
                        return "\(String(repeating: " ", count: 3 - green.count))\(green)"
                    }())
                        .font(.system(size: 13, design: .monospaced))
                    
                    Text(" B:")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    Text({
                        let blue = "\(Int(255 * color!.blueComponent))"
                        return "\(String(repeating: " ", count: 3 - blue.count))\(blue)"
                    }())
                        .font(.system(size: 13, design: .monospaced))
                }
            }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved], handler: self.mouseEventHandler(_:))
                NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved], handler: { event in
                    self.mouseEventHandler(event)
                    return nil
                })
            }
    }
    
    func mouseEventHandler(_ event: NSEvent) {
        // Mouse location
        guard let mouseLoc = CGEvent(source: nil)?.location else {
            return
        }
        // Display mouse is on
        var count: UInt32 = 0
        var displayForPoint: CGDirectDisplayID = .zero
        if CGGetDisplaysWithPoint(NSPointToCGPoint(mouseLoc), 1, &displayForPoint, &count) != CGError.success {
            // ERROR!
            print("Failed to get display")
        } else {
            // Get color at mouseLoc
            if let image = CGDisplayCreateImage(displayForPoint, rect: CGRect(x: mouseLoc.x, y: mouseLoc.y, width: 1, height: 1)), let prevImage = CGDisplayCreateImage(displayForPoint, rect: CGRect(x: mouseLoc.x - 3.5, y: mouseLoc.y, width: 7, height: 7)) {
                let bitmap = NSBitmapImageRep(cgImage: image)
                if let bitColor = bitmap.colorAt(x: 0, y: 0) {
                    let components = UnsafeMutablePointer<CGFloat>.allocate(capacity: bitColor.numberOfComponents)
                    bitColor.getComponents(components)
                    self.color = NSColor(colorSpace: bitmap.colorSpace, components: components, count: bitColor.numberOfComponents).usingColorSpace(settings.colorSpace)
                }
                self.image = prevImage
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
