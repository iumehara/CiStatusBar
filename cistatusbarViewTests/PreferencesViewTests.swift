import XCTest
import ViewInspector
@testable import cistatusbar

extension PreferencesView: Inspectable {}
extension JobList: Inspectable {}
extension JobDetail: Inspectable {}
extension Inspection: InspectionEmissary { }

class PreferencesViewTests: XCTestCase {
    var preferencesView: PreferencesView!
    var viewModel: PreferencesViewModel!
    var expectation: XCTestExpectation!
    
    override func setUp() {
        let runRepo = RunRepoSpy()
        let jobRepo = JobRepoSpy()
        viewModel = PreferencesViewModel(jobRepo: jobRepo,
                                         runRepo: runRepo)
        preferencesView = PreferencesView()
    }
    
    func test_onAppear_jobListDisplays() throws {
        let expectation = preferencesView.inspection.inspect(after: 1) { view in
            XCTAssertNotNil(try? view.find(text: "First Project Test"))
            XCTAssertNotNil(try? view.find(text: "First Project Build"))
        }
        
        ViewHosting.host(view: preferencesView.environmentObject(viewModel))
        wait(for: [expectation], timeout: 1)
    }

    func test_onAppear_jobsDetailsDisplays() throws {
        let expectation = preferencesView.inspection.inspect(after: 2) { view in
            XCTAssertNotNil(try? view.find(ViewType.TextField.self, where: {try $0.input() == "First Project Test"}))
        }
        
        ViewHosting.host(view: preferencesView.environmentObject(viewModel))
        wait(for: [expectation], timeout: 3)
    }

    func test_onAddButtonClick_addsDefaultJobToList() throws {
        expectation = preferencesView.inspection.inspect { view in
            XCTAssertNil(try? view.find(text: "job 1"))
            XCTAssertNil(try? view.find(ViewType.TextField.self, where: {try $0.input() == "job 1"}))

            let addButton = try view.find(button: "+")
            try addButton.tap()

            XCTAssertNotNil(try? view.find(text: "job 1"))
            XCTAssertNotNil(try? view.find(ViewType.TextField.self, where: {try $0.input() == "job 1"}))
        }

        ViewHosting.host(view: preferencesView.environmentObject(viewModel))
        wait(for: [expectation], timeout: 1)
    }
}
