import Foundation
import Combine

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
    
    func addMenuItem(title: String, tag: Int, action: Selector, delegate: StatusItemPresenter) {
        menuItems.append(MenuItem(title: title, tag: tag, action: action, delegate: delegate))
    }
    
    func addMenuItem(title: String, tag: Int) {
        menuItems.append(MenuItem(title: title, tag: tag))
    }
    
    func addMenuItemSeparator(tag: Int) {
        menuItems.append(MenuItem(title: "separator", tag: tag))
    }
    
    func insertMenuItem(_ title: String, at index: Int) {
        menuItems.insert(MenuItem(title: title, tag: nil), at: index)
    }
    
    func updateMenuItem(title: String, withTag tag: Int) {
        let menuItem = menuItems.filter {
            $0.tag == tag
        }.first
        menuItem!.title = title
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