import XCTest
import ViewInspector
@testable import cistatusbar

extension PreferencesView: Inspectable {}
extension JobInfoList: Inspectable {}
extension JobInfoDetail: Inspectable {}

class PreferencesViewTests: XCTestCase {

    func testExample() throws {
        let jobInfoDao = JobInfoDaoImpl()
        let jobHttpClient = JobHttpClientImpl()
        let jobRepo = JobsRepoImpl(jobInfoDao: jobInfoDao, jobHttpClient: jobHttpClient)
        let jobInfoRepo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        let viewModel = PreferencesViewModel(jobInfoRepo: jobInfoRepo,
                                            jobRepo: jobRepo)

        var sut = PreferencesView()

        let exp = sut.on(\.didAppear) { view in
            XCTAssertNil(try? view.find(button: "job 1"))

            let addButton = try view.find(button: "+")
            try addButton.tap()
            
            XCTAssertNotNil(try? view.find(button: "job 1"))
        }
        
        ViewHosting.host(view: sut.environmentObject(viewModel))
        wait(for: [exp], timeout: 1)
    }
}
