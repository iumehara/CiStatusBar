import Foundation
import Combine
import Cocoa

class SpyAppLauncher: AppLauncher {
    var launchPreferences_wasCalled = false
    
    func launchPreferences() {
        launchPreferences_wasCalled = true
    }
    
    var quitApp_wasCalled = false
    
    func quitApp() {
        quitApp_wasCalled = true
    }
}

class StubRunRepo: RunRepo {
    func get(job: Job) -> AnyPublisher<Run, CisbError> {
        Just(Run(name: "Project Build", status: .success))
                .setFailureType(to: CisbError.self)
                .eraseToAnyPublisher()
    }
    
    var getAll_response = [Run(name: "Project Build", status: .success),
                           Run(name: "Project Test", status: .fail)]
    
    func getAll() -> AnyPublisher<[Run], CisbError> {
        return Just(getAll_response)
                .setFailureType(to: CisbError.self)
                .eraseToAnyPublisher()
    }
}

class SpyCisbButton: CisbButton {
    var setIcon_wasCalledWith: String? = nil
    
    func setIcon(_ icon: String) {
        setIcon_wasCalledWith = icon
    }
    
    var setAction_wasCalledWith: (delegate: StatusItemPresenter, selector: Selector)? = nil
    
    func setAction(_ delegate: StatusItemPresenter, selector: Selector) {
        setAction_wasCalledWith = (delegate: delegate, selector: selector)
    }
}

class SpyCisbMenu: CisbMenu {
    var setDelegate_calledWith: NSMenuDelegate? = nil
    func setDelegate(_ delegate: NSMenuDelegate) {
        setDelegate_calledWith = delegate
    }
    
    var menuItems: [MenuItem] = []
    
    class MenuItem {
        var title: String
        var tag: Int?
        var action: Selector?
        var delegate: StatusItemPresenter?
        
        init(title: String,
             tag: Int?,
             action: Selector? = nil,
             delegate: StatusItemPresenter? = nil) {
            self.title = title
            self.tag = tag
            self.action = action
            self.delegate = delegate
        }
    }
    
    func addMenuItem(title: String, tag: MenuItemTag, action: Selector, delegate: StatusItemPresenter) {
        menuItems.append(MenuItem(title: title, tag: tag.rawValue, action: action, delegate: delegate))
    }
    
    func addMenuItem(title: String, tag: MenuItemTag) {
        menuItems.append(MenuItem(title: title, tag: tag.rawValue))
    }
    
    func addMenuItemSeparator(tag: MenuItemTag) {
        menuItems.append(MenuItem(title: "separator", tag: tag.rawValue))
    }
    
    func insertMenuItem(_ title: String, at index: Int) {
        menuItems.insert(MenuItem(title: title, tag: nil), at: index)
    }
    
    func updateMenuItem(title: String, withTag tag: MenuItemTag, isEnabled: Bool) {
        let menuItem = menuItems.filter {
            $0.tag == tag.rawValue
        }.first
        menuItem?.title = title
    }
    
    func updateMenuItem(title: String, at index: Int) {
        let menuItem = menuItems[index]
        menuItem.title = title
    }
    
    func removeAllItems() {
        menuItems.removeAll()
    }
    
    func menuItemsCount() -> Int {
        menuItems.count
    }
}

class SpyTimeService: TimeService {
    var isoDateNow = "2020-02-02T02:02:02+0000"
    
    func dateNow() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: isoDateNow)!
    }
    
    func timeZone() -> TimeZone {
        TimeZone.init(abbreviation: "UTC")!
    }
    
    var startScheduler_calledWith: (frequency: Int, callback: () -> Void)? = nil
    
    func startScheduler(frequency: Int, callback: @escaping () -> Void) -> AnyCancellable? {
        startScheduler_calledWith = (frequency: frequency, callback: callback)
        return AnyCancellable({})
    }
    
    var startTimer_called = false
    
    func startTimer() {
        startTimer_called = true
    }
    
    var timeIntervalSinceStart_returnValue = 1
    
    func timeIntervalSinceStart() -> Int {
        timeIntervalSinceStart_returnValue
    }
    
    var sleep_calledWith: Int? = nil
    
    func sleep(for seconds: Int) {
        sleep_calledWith = seconds
    }
}
