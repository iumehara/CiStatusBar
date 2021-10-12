import XCTest

class happyPathTests: XCTestCase {
     var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
    }
    
    func testHappyPath() throws {
        print("launching app")
        app.launch()
        wait()
        
        print("saving new job")
        clickMenuButton()
        clickPreferencesMenuItem()
        clickAddJobButton()
        saveNewJob()

        print("checking run status for new job")
        clickMenuButton()
        wait()
        assertJobStatus()

        print("deleting new job")
        clickPreferencesMenuItem()
        selectNewJobInJobList()
        clickDeleteJobButton()
    }

    private func wait() {
        sleep(20)
    }
    
    private func clickMenuButton() {
        let menuButton = app.buttons["MenuIcon"]
        XCTAssertTrue(menuButton.exists)
        menuButton.click()
    }
    
    private func clickPreferencesMenuItem() {
        let preferencesMenuItem = app.menuItems["Preferences..."]
        XCTAssertTrue(preferencesMenuItem.exists)
        preferencesMenuItem.click()
    }
    
    private func clickAddJobButton() {
        let addJobButton = app.buttons["add job"]
        XCTAssertTrue(addJobButton.exists)
        addJobButton.click()
    }
    
    private func saveNewJob() {
        let nameTextField = app.textFields["name"]
        XCTAssertTrue(nameTextField.exists)
        nameTextField.doubleClick()
        nameTextField.typeKey(XCUIKeyboardKey.delete, modifierFlags: [])
        nameTextField.doubleClick()
        nameTextField.typeKey(XCUIKeyboardKey.delete, modifierFlags: [])
        nameTextField.typeText("Starter-Workflows CI")

        let urlTextField = app.textFields["url"]
        XCTAssertTrue(urlTextField.exists)
        urlTextField.click()
        urlTextField.typeText("https://api.github.com/repos/actions/starter-workflows/actions/workflows/1678965/runs")

        let saveButton = app.buttons["save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.click()
    }
    
    private func assertJobStatus() {
        let successfulJob = app.menuItems["🟢 Starter-Workflows CI"]
        XCTAssertTrue(successfulJob.exists)
    }
        
    private func selectNewJobInJobList() {
        let jobListItem = app.staticTexts["Starter-Workflows CI"]
        XCTAssertTrue(jobListItem.exists)
        jobListItem.click()
    }

    private func clickDeleteJobButton() {
        let deleteJobButton = app.buttons["remove job"]
        XCTAssertTrue(deleteJobButton.exists)
        deleteJobButton.click()
        let jobListItem = app.staticTexts["Starter-Workflows CI"]
        XCTAssertFalse(jobListItem.exists)
    }
}
