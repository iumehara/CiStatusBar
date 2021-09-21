import Foundation
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
    private var appLauncher: AppLauncher!
    private var timeService: TimeService!
    private var repo: RunRepo!
    private var button: CisbButton!
    private var menu: CisbMenu!
    private var disposables = Set<AnyCancellable>()
    private var runs: [Run] = []
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
        presentButton()
        update()
        startUpdateScheduler()
    }
    
    private func startUpdateScheduler() {
        timeService.startTimer(frequency: 1, callback: self.update)?
                .store(in: &disposables)
    }
    
    func update() {
        self.button.setIcon(iconProvider.loading)
        self.repo.getAll()
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
                            self.runs = runs
                            self.updateButton(runs: runs)
                            self.updateMenu(runs: runs)
                        })
                .store(in: &disposables)
    }
    
    private func presentButton() {
        button.setAction(self, selector: #selector(self.updateSelector))
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
        
        menu.updateMenuItem(title: getCurrentTimeLabel(), withTag: MenuItemTag.jobUpdatedLabel.rawValue)
    }
    
    private func setupUpdateSection() {
        menu.addMenuItem(title: "Update",
                         tag: MenuItemTag.updateButton.rawValue,
                         action: #selector(self.updateSelector(_:)),
                         delegate: self)
        
        menu.addMenuItemSeparator(tag: MenuItemTag.updateSectionSeparator.rawValue)
    }
    
    private func setupJobsSection(runs: [Run]) {
        menu.addMenuItem(title: "Updated: N/A", tag: MenuItemTag.jobUpdatedLabel.rawValue)
        
        var jobItemIndex = 3
        
        runs.forEach { run in
            let title = jobMenuItemTitle(name: run.name, status: run.status)
            menu.insertMenuItem(title, at: jobItemIndex)
            jobItemIndex += 1
        }
        
        menu.addMenuItemSeparator(tag: MenuItemTag.jobsSectionSeparator.rawValue)
    }
    
    private func setupPreferencesSection() {
        menu.addMenuItem(title: "Preferences...",
                         tag: MenuItemTag.preferencesButton.rawValue,
                         action: #selector(launchPreferences(_:)),
                         delegate: self)
        
        menu.addMenuItemSeparator(tag: MenuItemTag.preferencesSectionSeparator.rawValue)
    }
    
    private func setupQuitSection() {
        menu.addMenuItem(title: "Quit CI Status Bar",
                         tag: MenuItemTag.quitButton.rawValue,
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