//
//  OpenPanelExtension.swift
//  ElixirSipsRssSwift
//
//  Created by Robert J Samson on 9/2/15.
//  Copyright (c) 2015 rjsamson. All rights reserved.
//

import Cocoa

extension NSOpenPanel {
    var selectUrl: NSURL? {
        let fileOpenPanel = NSOpenPanel()
        fileOpenPanel.title = "Choose Directory"
        fileOpenPanel.allowsMultipleSelection = false
        fileOpenPanel.canChooseDirectories = true
        fileOpenPanel.canChooseFiles = false
        fileOpenPanel.canCreateDirectories = true
        fileOpenPanel.runModal()
        if let urL = fileOpenPanel.URLs.first as? NSURL {
            return urL
        }
        return nil
    }
}
