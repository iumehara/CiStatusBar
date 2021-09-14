import Foundation

protocol CisbMenu {
    func addMenuItem(title: String, tag: Int, action: Selector, delegate: StatusItemPresenter)
    func addMenuItem(title: String, tag: Int)
    func addMenuItemSeparator(tag: Int)
    func insertMenuItem(_ title: String, at index: Int)
    func updateMenuItem(title: String, withTag tag: Int)
    func updateMenuItem(title: String, at index: Int)
    func removeAllItems()
    func menuItemsCount() -> Int
}
