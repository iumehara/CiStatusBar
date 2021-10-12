import XCTest

class happyPathTests: XCTestCase {
    var app: XCUIApplication!
    let timeout: TimeInterval = 10
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
    }
    
    func testHappyPath() throws {
        print("launching app")
        app.launch()
        
        print("saving new job")
        clickMenuButtonWithNoJobs()
        clickPreferencesMenuItem()
        clickAddJobButton()
        saveNewJob()
        
        print("checking run status for new job")
        clickMenuButtonWithSuccessfulJob()
        assertJobStatus()
        
        print("deleting new job")
        clickPreferencesMenuItem()
        selectNewJobInJobList()
        clickDeleteJobButton()
    }
    
    private func clickMenuButtonWithNoJobs() {
        sleep(5)
        let menuButton = app.buttons["MenuIcon"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: timeout))
        menuButton.click()
    }
    
    private func clickMenuButtonWithSuccessfulJob() {
        let menuButton = app.buttons["🟢"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: timeout))
        menuButton.click()
    }
    
    private func clickPreferencesMenuItem() {
        let preferencesMenuItem = app.menuItems["Preferences..."]
        XCTAssertTrue(preferencesMenuItem.waitForExistence(timeout: timeout))
        preferencesMenuItem.click()
    }
    
    private func clickAddJobButton() {
        let addJobButton = app.buttons["add job"]
        XCTAssertTrue(addJobButton.waitForExistence(timeout: timeout))
        addJobButton.click()
    }
    
    private func saveNewJob() {
        let nameTextField = app.textFields["name"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: timeout))
        nameTextField.doubleClick()
        nameTextField.typeKey(XCUIKeyboardKey.delete, modifierFlags: [])
        nameTextField.doubleClick()
        nameTextField.typeKey(XCUIKeyboardKey.delete, modifierFlags: [])
        nameTextField.typeText("Starter-Workflows CI")
        
        let urlTextField = app.textFields["url"]
        XCTAssertTrue(urlTextField.waitForExistence(timeout: timeout))
        urlTextField.click()
        urlTextField.typeText("https://api.github.com/repos/actions/starter-workflows/actions/workflows/1678965/runs")
        
        let saveButton = app.buttons["save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: timeout))
        saveButton.click()
    }
    
    private func assertJobStatus() {
        let successfulJob = app.menuItems["🟢 Starter-Workflows CI"]
        XCTAssertTrue(successfulJob.waitForExistence(timeout: timeout))
    }
    
    private func selectNewJobInJobList() {
        let jobListItem = app.staticTexts["Starter-Workflows CI"]
        XCTAssertTrue(jobListItem.waitForExistence(timeout: timeout))
        jobListItem.click()
    }
    
    private func clickDeleteJobButton() {
        let deleteJobButton = app.buttons["remove job"]
        XCTAssertTrue(deleteJobButton.waitForExistence(timeout: timeout))
        deleteJobButton.click()
        let jobListItem = app.staticTexts["Starter-Workflows CI"]
        XCTAssertFalse(jobListItem.exists)
    }
}
