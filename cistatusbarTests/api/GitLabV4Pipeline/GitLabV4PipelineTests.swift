import XCTest

class GitLabV4PipelineTests: AbstractResponseTests {
    override func getTestClass() -> XCTestCase.Type {
        return GitLabV4PipelineTests.self
    }
    
    override func getDecoder() -> ApiResponseDecoder {
        return GitLabV4Pipeline.ResponseDecoder()
    }
    
    func test_everyScenario() {
        XCTAssertEqual(getStatusFor(status: .created), .running)
        XCTAssertEqual(getStatusFor(status: .waiting_for_resource), .running)
        XCTAssertEqual(getStatusFor(status: .preparing), .running)
        XCTAssertEqual(getStatusFor(status: .pending), .running)
        XCTAssertEqual(getStatusFor(status: .running), .running)
        XCTAssertEqual(getStatusFor(status: .success), .success)
        XCTAssertEqual(getStatusFor(status: .failed), .fail)
        XCTAssertEqual(getStatusFor(status: .canceled), .fail)
        XCTAssertEqual(getStatusFor(status: .skipped), .unknown)
        XCTAssertEqual(getStatusFor(status: .manual), .unknown)
        XCTAssertEqual(getStatusFor(status: .scheduled), .running)
    }

    private func getStatusFor(status: GitLabV4Pipeline.Response.Status) -> ApiResponseStatus {
        return GitLabV4Pipeline.Response.init(status: status.rawValue).toStatus()
    }
}
