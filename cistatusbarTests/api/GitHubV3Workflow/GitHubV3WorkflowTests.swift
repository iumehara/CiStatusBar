import XCTest

class GitHubV3WorkflowTests: XCTestCase, AbstractResponseTests {
    func getTestClass() -> XCTestCase.Type {
        return GitHubV3WorkflowTests.self
    }
    
    func getDecoder() -> ApiResponseDecoder {
        return GitHubV3Workflow.ResponseDecoder()
    }
    
    func test_success() {
        run_test_success()
    }

    func test_running() {
        run_test_running()
    }
    
    func test_fail() {
        run_test_fail()
    }
    
    func test_unknown() {
        run_test_unknown()
    }
}
