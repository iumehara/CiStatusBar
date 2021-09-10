import SwiftUI
import Combine

enum MenuItemTag: Int {
    case updateButton = 1
    case updateSectionSeparator = 2
    case jobUpdatedLabel = 3
    case jobsSectionSeparator = 7
    case preferencesButton = 8
    case preferencesSectionSeparator = 9
    case quitButton = 10
}

class StatusItemPresenter: NSObject {
    private var repo: RunRepo
    private var button: NSStatusBarButton!
    private var menu: NSMenu!
    private var disposables = Set<AnyCancellable>()
    private var runs: [Run] = []
    private var lastUpdate: Date?
    private var subscription: AnyCancellable? = nil
    private var iconProvider = DefaultIconProvider()
    
    init(repo: RunRepo,
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
                .sink { _ in
                    self.update()
                }
    }
    
    func update() {
        self.button.setIcon(iconProvider.loading)
        self.repo.getAll()
                .receive(on: DispatchQueue.main)
                .sink(
                        receiveCompletion: { value in
                            switch value {
                            case .failure:
                                self.button.setIcon(self.iconProvider.unknown)
                                self.updateMenu(runs: [])
                                break
                            case .finished:
                                self.lastUpdate = Date()
                                break
                            }
                        },
                        receiveValue: { runs in
                            self.runs = runs
                            self.updateButton(runs: runs)
                            self.updateMenu(runs: runs)
                        })
                .store(in: &disposables)
    }
    
    private func presentButton() {
        button.target = self
        button.action = #selector(self.updateSelector)
    }
    
    private func updateButton(runs: [Run]) {
        let statuses = runs.map { run in
            run.status
        }
        
        if statuses.contains(ApiResponseStatus.fail) {
            self.button.setIcon(iconProvider.fail)
            return
        }
        
        if statuses.contains(ApiResponseStatus.unknown) {
            self.button.setIcon(iconProvider.unknown)
            return
        }
        
        self.button.setIcon(iconProvider.success)
    }
    
    private func updateMenu(runs: [Run]) {
        let updateSectionItemCount = 2
        let jobsSectionItemCount = runs.count + 2
        let preferencesSectionItemCount = 2
        let quitSectionItemCount = 1
        let expectedNumberOfItems = updateSectionItemCount + jobsSectionItemCount + preferencesSectionItemCount + quitSectionItemCount
        
        var jobItemIndex = updateSectionItemCount + 1
        if (menu.items.count != expectedNumberOfItems) {
            menu.removeAllItems()
            setupUpdateSection()
            setupJobsSection(runs: runs)
            setupPreferencesSection()
            setupQuitSection()
        } else {
            runs.forEach { run in
                let menuItem = menu.item(at: jobItemIndex)
                menuItem?.title = jobMenuItemTitle(name: run.name, status: run.status)
                jobItemIndex += 1
            }
        }
        
        menu.displayUpdateTime(date: Date())
    }
    
    private func setupUpdateSection() {
        let update = NSMenuItem(title: "Update", action: #selector(self.updateSelector(_:)), keyEquivalent: "")
        update.target = self
        update.tag = MenuItemTag.updateButton.rawValue
        menu.addItem(update)
        
        menu.addItem(NSMenuItem.separator())
    }
    
    private func setupJobsSection(runs: [Run]) {
        let updatedTime = NSMenuItem(title: "Updated: N/A", action: nil, keyEquivalent: "")
        updatedTime.tag = MenuItemTag.jobUpdatedLabel.rawValue
        menu.addItem(updatedTime)
        
        var jobItemIndex = 3
        
        runs.forEach { run in
            let title = jobMenuItemTitle(name: run.name, status: run.status)
            menu.insertMenuItemWithTitle(title, at: jobItemIndex)
            jobItemIndex += 1
        }
        
        menu.addItem(NSMenuItem.separator())
    }
    
    private func setupPreferencesSection() {
        let preferences = NSMenuItem(title: "Preferences...", action: #selector(self.launchPreferences(_:)), keyEquivalent: "")
        preferences.target = self
        preferences.tag = MenuItemTag.preferencesButton.rawValue
        menu.addItem(preferences)
        
        menu.addItem(NSMenuItem.separator())
    }
    
    private func setupQuitSection() {
        let action = #selector(NSApp.terminate(_:))
        let quit = NSMenuItem(title: "Quit CI Status Bar", action: action, keyEquivalent: "")
        quit.tag = MenuItemTag.quitButton.rawValue
        menu.addItem(quit)
    }
    
    private func jobMenuItemTitle(name: String, status: ApiResponseStatus) -> String {
        let statusIcon = iconProvider.iconFor(status: status)
        return "\(statusIcon) \(name)"
    }
    
    @objc func updateSelector(_ sender: Any?) {
        update()
    }
    
    @objc func launchPreferences(_ sender: Any?) {
        NSApp.sendAction(#selector(AppDelegate.showPreferences), to: nil, from: nil)
    }
}

extension NSStatusBarButton {
    func setIcon(_ icon: String) {
        self.title = icon
    }
}

extension NSMenu {
    func displayUpdateTime(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        let date = formatter.string(from: Date())
        let menuItem = self.item(withTag: MenuItemTag.jobUpdatedLabel.rawValue)
        menuItem?.title = "Updated: \(date)"
        menuItem?.isEnabled = false
    }
    
    func insertMenuItemWithTitle(_ title: String, at index: Int) {
        let image = NSImage(size: NSMakeSize(1, 16))
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.image = image
        menuItem.isEnabled = false
        
        self.insertItem(menuItem, at: index)
    }
}
