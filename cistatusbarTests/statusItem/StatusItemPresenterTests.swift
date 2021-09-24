import XCTest
import Combine

class StatusItemPresenterTests: XCTestCase {
    private var appLauncher: SpyAppLauncher!
    private var timeService: SpyTimeService!
    private var repo: StubRunRepo!
    private var button: SpyCisbButton!
    private var menu: SpyCisbMenu!
    private var presenter: StatusItemPresenter!
    private let testTimeout = 0.5
    
    override func setUp() {
        appLauncher = SpyAppLauncher()
        repo = StubRunRepo()
        button = SpyCisbButton()
        menu = SpyCisbMenu()
        timeService = SpyTimeService()
        presenter = StatusItemPresenter(appLauncher: appLauncher,
                                        timeService: timeService,
                                        repo: repo,
                                        button: button,
                                        menu: menu)
    }
    
    func test_present_displaysMenuItemsInCorrectOrder() throws {
        presenter.present()
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            XCTAssertEqual(self.menu.menuItemsCount(), 9)
            XCTAssertEqual(self.menu.menuItems[0].title, "Update")
            XCTAssertEqual(self.menu.menuItems[1].title, "separator")
            XCTAssertEqual(self.menu.menuItems[2].title, "Updated: 02:02:02")
            XCTAssertEqual(self.menu.menuItems[3].title, "🟢 Project Build")
            XCTAssertEqual(self.menu.menuItems[4].title, "🔴 Project Test")
            XCTAssertEqual(self.menu.menuItems[5].title, "separator")
            XCTAssertEqual(self.menu.menuItems[6].title, "Preferences...")
            XCTAssertEqual(self.menu.menuItems[7].title, "separator")
            XCTAssertEqual(self.menu.menuItems[8].title, "Quit CI Status Bar")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func test_present_startsTimer() {
        presenter.present()
    
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            XCTAssertEqual(self.timeService.startScheduler_calledWith?.frequency, 1)
            XCTAssertNotNil(self.timeService.startScheduler_calledWith?.callback)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: testTimeout)
    
    }
    
    func test_present_displaysCorrectMenuButtonIcon_allSuccess() {
        repo.getAll_response = [Run(name: "Project Build", status: .success),
                                Run(name: "Project Test", status: .success)]
        
        presenter.present()
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            XCTAssertEqual(self.button.setIcon_wasCalledWith, "🟢")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func test_present_displaysCorrectMenuButtonIcon_atLeastOneFail() {
        repo.getAll_response = [Run(name: "Project Build", status: .success),
                                Run(name: "Project Test", status: .fail),
                                Run(name: "Project Test", status: .unknown),
                                Run(name: "Project Test", status: .running)]
        
        presenter.present()
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            XCTAssertEqual(self.button.setIcon_wasCalledWith, "🔴")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func test_present_displaysCorrectMenuButtonIcon_atLeastOneUnknownWithNoFail() {
        repo.getAll_response = [Run(name: "Project Build", status: .success),
                                Run(name: "Project Test", status: .unknown),
                                Run(name: "Project Test", status: .running)]
        
        presenter.present()
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            XCTAssertEqual(self.button.setIcon_wasCalledWith, "⁉️")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func test_present_sleepsForUpTo3Second() {
        presenter.present()
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        timeService.timeIntervalSinceStart_returnValue = 1
        DispatchQueue.main.async {
            XCTAssertEqual(self.timeService.startTimer_called, true)
            XCTAssertEqual(self.timeService.sleep_calledWith, 2)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: self.testTimeout)
    }
    
    func test_clickUpdate_displaysUpdatedStatus() {
        presenter.present()
        
        let setup = XCTestExpectation(description: "waiting for initial present to fulfill")
        DispatchQueue.main.async {
            XCTAssertEqual(self.menu.menuItems[2].title, "Updated: 02:02:02")
            XCTAssertEqual(self.menu.menuItems[3].title, "🟢 Project Build")
            XCTAssertEqual(self.menu.menuItems[4].title, "🔴 Project Test")
            setup.fulfill()
        }
        wait(for: [setup], timeout: testTimeout)
        
        repo.getAll_response = [Run(name: "Project Test", status: .success)]
        timeService.isoDateNow = "2020-02-02T02:02:03+0000"
        
        let updateMenuItem = self.menu.menuItems.filter {
            $0.title == "Update"
        }.first!
        presenter.performSelector(onMainThread: updateMenuItem.action!, with: nil, waitUntilDone: true)
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            XCTAssertEqual(self.menu.menuItems[2].title, "Updated: 02:02:03")
            XCTAssertEqual(self.menu.menuItems[3].title, "🟢 Project Test")
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: self.testTimeout)
    }
    
    func test_clickPreferences() {
        presenter.present()
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            let preferencesMenuItem = self.menu.menuItems.filter {
                $0.title == "Preferences..."
            }.first!
            
            self.presenter.performSelector(onMainThread: preferencesMenuItem.action!, with: nil, waitUntilDone: true)
            
            XCTAssertEqual(self.appLauncher.launchPreferences_wasCalled, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func test_clickQuit() {
        presenter.present()
        
        let expectation = XCTestExpectation(description: "to be fulfilled after assertion")
        DispatchQueue.main.async {
            let quitMenuItem = self.menu.menuItems.filter {
                $0.title == "Quit CI Status Bar"
            }.first!
            
            self.presenter.performSelector(onMainThread: quitMenuItem.action!, with: nil, waitUntilDone: true)
            
            XCTAssertEqual(self.appLauncher.quitApp_wasCalled, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: testTimeout)
    }
}
