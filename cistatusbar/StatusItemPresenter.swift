import SwiftUI
import Combine

enum MenuItemTag: Int {
    case updatedTime = 0
    case update = 1
    case updateSectionSeparator = 2
    case jobsSectionSeparator = 9
    case quit = 10
}

class StatusItemPresenter: NSObject {
    private var repo: JobsRepo
    private var button: NSStatusBarButton!
    private var menu: NSMenu!
    private var disposables = Set<AnyCancellable>()
    private var jobs: [Job] = []
    private var lastUpdate: Date?
    private var subscription: AnyCancellable? = nil
    
    init(repo: JobsRepo,
         button: NSStatusBarButton,
         menu: NSMenu) {
        self.repo = repo
        self.button = button
        self.menu = menu
    }
    
    func present() {
        presentButton()
        update()
        startUpdateScheduler()
    }
    
    private func startUpdateScheduler() {
        let frequency = 5 * 60.0
        self.startTimer(frequency: frequency)
    }
    
    private func startTimer(frequency: Double) {
        subscription = Timer.publish(every: frequency, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink() {_ in
                self.update()
            }
    }
    
    func update() {
        self.button.displayLoading()
        self.repo.getAll()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { value in
                    switch value {
                    case .failure:
                        self.button.displayUnavailable()
                        self.updateMenu(jobs: [])
                        break
                    case .finished:
                        self.lastUpdate = Date()
                        break
                    }
                },
                receiveValue:  { jobs in
                    self.jobs = jobs
                    self.updateButton(jobs: jobs)
                    self.updateMenu(jobs: jobs)
                })
            .store(in: &disposables)
    }
    
    private func presentButton() {
        button.target = self
        button.action = #selector(self.updateSelector)
    }
        
    private func updateButton(jobs: [Job]) {
        let statuses = jobs.map { job in job.status }
        
        if statuses.contains(ApiResponseStatus.fail) {
            self.button.displayFailed()
            return
        }
        
        if statuses.contains(ApiResponseStatus.unknown) {
            self.button.displayUnavailable()
            return
        }
        
        self.button.displaySuccessful()
    }
        
    private func updateMenu(jobs: [Job]) {
        let updateSectionItemCount = 3
        let jobCountSeparator = 1
        let quitSectionItemCount = 1
        let currentNumberOfItems = updateSectionItemCount + jobs.count + jobCountSeparator + quitSectionItemCount
        
        var jobItemIndex = updateSectionItemCount - 1
        if (menu.items.count != currentNumberOfItems) {
            menu.removeAllItems()
            setupUpdateSection()
            jobs.forEach { job in
                let menuItem = menu.createJobMenuItem(name: job.name, status: job.status)
                menu.insertItem(menuItem, at: jobItemIndex)
                jobItemIndex += 1
            }
            setupPreferencesSection()
            setupQuitSection()
        } else {
            jobs.forEach { job in
                let menuItem = menu.item(at: jobItemIndex)
                menuItem?.title = menu.jobMenuItemTitle(name: job.name, status: job.status)
                jobItemIndex += 1
            }
        }

        menu.displayUpdateTime(date: Date())
    }
    
    private func setupUpdateSection() {
        let updatedTime = NSMenuItem(title: "Updated: N/A", action: nil, keyEquivalent: "")
        updatedTime.tag = MenuItemTag.updatedTime.rawValue
        menu.addItem(updatedTime)
        
        let update = NSMenuItem(title: "Update", action: #selector(self.updateSelector(_:)), keyEquivalent: "")
        update.target = self
        update.tag = MenuItemTag.update.rawValue
        menu.addItem(update)
        
        let updateSectionSeparator = NSMenuItem.separator()
        updateSectionSeparator.tag = MenuItemTag.updateSectionSeparator.rawValue
        menu.addItem(updateSectionSeparator)
    }
    
    private func setupPreferencesSection() {
        let preferences = NSMenuItem(title: "Preferences...", action: #selector(self.launchPreferences(_:)), keyEquivalent: "")
        preferences.target = self
        preferences.tag = MenuItemTag.update.rawValue
        menu.addItem(preferences)

        menu.addItem(NSMenuItem.separator())
    }
    
    private func setupQuitSection() {
        let action = #selector(NSApp.terminate(_:))
        let quit = NSMenuItem(title: "Quit", action: action, keyEquivalent: "")
        quit.tag = MenuItemTag.quit.rawValue
        menu.addItem(quit)
    }
    
    @objc func updateSelector(_ sender: Any?) {
        update()
    }
    
    @objc func launchPreferences(_ sender: Any?) {
        NSApp.sendAction(#selector(AppDelegate.showPreferences),to: nil, from: nil)
    }
}

extension NSStatusBarButton {
    func displaySuccessful() {
        self.title = "🟢"
        self.isBordered = false
        self.wantsLayer = true
    }

    func displayFailed() {
        self.title = "🔴"
        self.isBordered = false
        self.wantsLayer = true
    }
    
    func displayUnavailable() {
        self.title = "⁉️"
        self.isBordered = false
        self.wantsLayer = true
    }

    func displayLoading() {
        self.title = "⌚️"
        self.isBordered = false
        self.wantsLayer = true
    }
}

extension NSMenu {
    func displayUpdateTime(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        let date = formatter.string(from: Date())
        let view = NSView(frame: NSRect.zero)
        view.layer?.backgroundColor = NSColor.blue.cgColor
        let menuItem = self.item(withTag: MenuItemTag.updatedTime.rawValue)
        menuItem?.title = "Updated: \(date)"
    }
    
    func createJobMenuItem(name: String, status: ApiResponseStatus) -> NSMenuItem {
        let title = jobMenuItemTitle(name: name, status: status)
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.isEnabled = false
        return menuItem
    }
    
    func jobMenuItemTitle(name: String, status: ApiResponseStatus) -> String {
        var statusIcon: String
        switch status {
        case ApiResponseStatus.success:
            statusIcon = "🟢"
        case ApiResponseStatus.fail:
            statusIcon = "🔴"
        case ApiResponseStatus.running:
            statusIcon = "⌚️"
        default:
            statusIcon = "⁉️"
        }
        
        return "\(statusIcon) \(name)"
    }
}
