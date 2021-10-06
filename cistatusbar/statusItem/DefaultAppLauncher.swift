import Cocoa
import SwiftUI

class DefaultAppLauncher: AppLauncher {
    private var preferencesWindow: NSWindow?
    
    init(preferencesWindow: NSWindow?) {
        self.preferencesWindow = preferencesWindow
    }
    
    func launchPreferences() {
        if preferencesWindow == nil {
            let jobDao = JobDaoImpl()
            let runHttpClient = RunHttpClientImpl()
            let runRepo = RunRepoImpl(jobDao: jobDao, runHttpClient: runHttpClient)
            let jobRepo = JobRepoImpl(jobDao: jobDao)
            let preferencesViewModel = PreferencesViewModel(jobRepo: jobRepo,
                                                            runRepo: runRepo)
            let preferencesView = PreferencesView().environmentObject(preferencesViewModel)
            preferencesWindow = NSWindow(
                    contentRect: NSRect(x: 20, y: 20, width: 700, height: 200),
                    styleMask: [.titled, .closable],
                    backing: .buffered,
                    defer: false)
            preferencesWindow?.center()
            preferencesWindow?.title = "Preferences"
            preferencesWindow?.setFrameAutosaveName("Preferences")
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.contentView = NSHostingView(rootView: preferencesView)
            preferencesWindow?.setAccessibilityIdentifier("PreferencesWindow")
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        
        var accessibilityChildren: [Any] = []
        if let currentChildren = NSApp.accessibilityChildren() {
            accessibilityChildren = currentChildren
        }
        accessibilityChildren.append(preferencesWindow!)
                
        NSApp.setAccessibilityChildren(accessibilityChildren)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func quitApp() {
        NSApp.terminate(nil)
    }
}
