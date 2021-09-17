import Cocoa
class DefaultCisbMenu: CisbMenu {
    private var menu: NSMenu!
    
    init(_ menu: NSMenu) {
        self.menu = menu
    }
    
    func addMenuItem(title: String, tag: Int, action: Selector, delegate: StatusItemPresenter) {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
        menuItem.target = delegate
        menuItem.tag = tag
        menuItem.isEnabled = true
        menu.addItem(menuItem)
    }
    
    func addMenuItem(title: String, tag: Int) {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.tag = tag
        menuItem.isEnabled = false
        menu.addItem(menuItem)
    }
    
    func addMenuItemSeparator(tag: Int) {
        let menuItem = NSMenuItem.separator()
        menuItem.tag = tag
        menuItem.isEnabled = false
        menu.addItem(menuItem)
    }
    
    func insertMenuItem(_ title: String, at index: Int) {
        let image = NSImage(size: NSMakeSize(1, 16))
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.image = image
        menuItem.isEnabled = false
        menu.insertItem(menuItem, at: index)
    }
    
    func updateMenuItem(title: String, withTag tag: Int) {
        let menuItem = menu.item(withTag: tag)
        menuItem?.title = title
    }
    
    func updateMenuItem(title: String, at index: Int) {
        let menuItem = menu.item(at: index)
        menuItem?.title = title
    }
    
    func removeAllItems() {
        menu.removeAllItems()
    }
    
    func menuItemsCount() -> Int {
        return menu.items.count
    }
}
