import XCTest

class GitLabV4PipelineTests: XCTestCase, AbstractResponseTests {
    func getTestClass() -> XCTestCase.Type {
        return GitLabV4PipelineTests.self
    }
    
    func getDecoder() -> ApiResponseDecoder {
        return GitLabV4Pipeline.ResponseDecoder()
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
