import Cocoa

class DefaultCisbButton: CisbButton {
    private var button: NSStatusBarButton!
    
    init(_ button: NSStatusBarButton) {
        self.button = button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIcon(_ icon: String) {
        self.button.title = icon
    }
    
    func setAction(_ delegate: StatusItemPresenter, selector: Selector) {
        self.button.target = delegate
        self.button.action = selector
    }
}

