import Foundation
import Combine
import Cocoa

class StatusItemPresenter: NSObject {
    private var appLauncher: AppLauncher!
    private var timeService: TimeService!
    private var repo: RunRepo!
    private var button: CisbButton!
    private var menu: CisbMenu!
    private var disposables = Set<AnyCancellable>()
    private var iconProvider = DefaultIconProvider()
    
    init(appLauncher: AppLauncher,
         timeService: TimeService,
         repo: RunRepo,
         button: CisbButton,
         menu: CisbMenu) {
        self.appLauncher = appLauncher
        self.timeService = timeService
        self.repo = repo
        self.button = button
        self.menu = menu
    }
    
    func present() {
        menu.setDelegate(self)
        update()
        startUpdateScheduler()
    }
    
    private func startUpdateScheduler() {
        timeService.startScheduler(frequency: 1, callback: self.update)?
                .store(in: &disposables)
    }
    
    func update() {
        displayLoading()
        timeService.startTimer()
        
        self.repo.getAll()
                .map { [weak self] result -> [Run] in
                    if let self = self {
                        let interval = self.timeService.timeIntervalSinceStart()
                        if interval < 3 {
                            self.timeService.sleep(for: 3 - interval)
                        }
                    }
                    return result
                }
                .receive(on: DispatchQueue.main)
                .sink(
                        receiveCompletion: { [weak self] value in
                            guard let self = self else {
                                return
                            }
                            
                            switch value {
                            case .failure:
                                self.button.setIcon(self.iconProvider.unknown)
                                self.updateMenu(runs: [])
                                break
                            case .finished:
                                break
                            }
                        },
                        receiveValue: { [weak self] runs in
                            guard let self = self else {
                                return
                            }
                            
                            self.updateButton(runs: runs)
                            self.updateMenu(runs: runs)
                            self.menu.updateMenuItem(title: "Update", withTag: .updateButton, isEnabled: true)
                        })
                .store(in: &disposables)
    }
    
    private func displayLoading() {
        button.setIcon(iconProvider.loading)
        menu.updateMenuItem(title: "Updating...", withTag: .updateButton, isEnabled: false)
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
        if (menu.menuItemsCount() != expectedNumberOfItems) {
            menu.removeAllItems()
            setupUpdateSection()
            setupJobsSection(runs: runs)
            setupPreferencesSection()
            setupQuitSection()
        } else {
            runs.forEach { run in
                let title = jobMenuItemTitle(name: run.name, status: run.status)
                menu.updateMenuItem(title: title, at: jobItemIndex)
                jobItemIndex += 1
            }
        }
        
        menu.updateMenuItem(title: getCurrentTimeLabel(), withTag: .jobUpdatedLabel, isEnabled: false)
    }
    
    private func setupUpdateSection() {
        menu.addMenuItem(title: "Update",
                         tag: .updateButton,
                         action: #selector(self.updateSelector(_:)),
                         delegate: self)
        
        menu.addMenuItemSeparator(tag: .updateSectionSeparator)
    }
    
    private func setupJobsSection(runs: [Run]) {
        menu.addMenuItem(title: "Updated: N/A", tag: .jobUpdatedLabel)
        
        var jobItemIndex = 3
        
        runs.forEach { run in
            let title = jobMenuItemTitle(name: run.name, status: run.status)
            menu.insertMenuItem(title, at: jobItemIndex)
            jobItemIndex += 1
        }
        
        menu.addMenuItemSeparator(tag: .jobsSectionSeparator)
    }
    
    private func setupPreferencesSection() {
        menu.addMenuItem(title: "Preferences...",
                         tag: .preferencesButton,
                         action: #selector(launchPreferences(_:)),
                         delegate: self)
        
        menu.addMenuItemSeparator(tag: .preferencesSectionSeparator)
    }
    
    private func setupQuitSection() {
        menu.addMenuItem(title: "Quit CI Status Bar",
                         tag: .quitButton,
                         action: #selector(quitApp(_:)),
                         delegate: self)
    }
    
    private func jobMenuItemTitle(name: String, status: ApiResponseStatus) -> String {
        let statusIcon = iconProvider.iconFor(status: status)
        return "\(statusIcon) \(name)"
    }
    
    private func getCurrentTimeLabel() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeService.timeZone()
        formatter.dateFormat = "hh:mm:ss"
        let dateString = formatter.string(from: timeService.dateNow())
        return "Updated: \(dateString)"
    }
    
    @objc func updateSelector(_ sender: Any?) {
        update()
    }
    
    @objc func launchPreferences(_ sender: Any?) {
        self.appLauncher.launchPreferences()
    }
    
    @objc func quitApp(_ sender: Any?) {
        self.appLauncher.quitApp()
    }
}

extension StatusItemPresenter: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        update()
    }
}

