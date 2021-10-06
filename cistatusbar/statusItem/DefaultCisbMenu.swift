import Cocoa

enum MenuItemTag: Int {
    case updateButton = 1
    case updateSectionSeparator = 2
    case jobUpdatedLabel = 3
    case jobsSectionSeparator = 7
    case preferencesButton = 8
    case preferencesSectionSeparator = 9
    case quitButton = 10
}

class DefaultCisbMenu: CisbMenu {
    private var menu: NSMenu!
    
    init(_ menu: NSMenu) {
        self.menu = menu
        self.menu.autoenablesItems = false
    }
    
    func setDelegate(_ delegate: NSMenuDelegate) {
        menu.delegate = delegate
    }
    
    func addMenuItem(title: String, tag: MenuItemTag, action: Selector, delegate: StatusItemPresenter) {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
        menuItem.target = delegate
        menuItem.tag = tag.rawValue
        menuItem.isEnabled = true
        menuItem.setAccessibilityIdentifier(title)
        menu.addItem(menuItem)
    }
    
    func addMenuItem(title: String, tag: MenuItemTag) {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.tag = tag.rawValue
        menuItem.isEnabled = false
        menu.addItem(menuItem)
    }
    
    func addMenuItemSeparator(tag: MenuItemTag) {
        let menuItem = NSMenuItem.separator()
        menuItem.tag = tag.rawValue
        menuItem.isEnabled = false
        menu.addItem(menuItem)
    }
    
    func insertMenuItem(_ title: String, at index: Int) {
        let image = NSImage(size: NSMakeSize(1, 16))
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.image = image
//        menuItem.isEnabled = false
        menu.insertItem(menuItem, at: index)
    }
    
    func updateMenuItem(title: String, withTag tag: MenuItemTag, isEnabled: Bool) {
        guard let menuItem = menu.item(withTag: tag.rawValue) else { return }
        menuItem.title = title
        menuItem.isEnabled = isEnabled
    }
    
    func updateMenuItem(title: String, at index: Int) {
        let menuItem = menu.item(at: index)
        menuItem?.title = title
        menuItem?.setAccessibilityIdentifier(title)
    }
    
    func removeAllItems() {
        menu.removeAllItems()
    }
    
    func menuItemsCount() -> Int {
        menu.items.count
    }
}
