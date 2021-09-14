import Foundation

protocol CisbButton {
    func setIcon(_ icon: String)
    func setAction(_ delegate: StatusItemPresenter, selector: Selector)
}