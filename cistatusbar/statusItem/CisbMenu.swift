import Cocoa

protocol CisbMenu {
    func setDelegate(_ delegate: NSMenuDelegate)
    func addMenuItem(title: String, tag: MenuItemTag, action: Selector, delegate: StatusItemPresenter)
    func addMenuItem(title: String, tag: MenuItemTag)
    func addMenuItemSeparator(tag: MenuItemTag)
    func insertMenuItem(_ title: String, at index: Int)
    func updateMenuItem(title: String, withTag tag: MenuItemTag, isEnabled: Bool)
    func updateMenuItem(title: String, at index: Int)
    func removeAllItems()
    func menuItemsCount() -> Int
}
