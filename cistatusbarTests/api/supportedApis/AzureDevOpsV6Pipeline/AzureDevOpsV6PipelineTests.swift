import XCTest

class AzureDevOpsV6PipelineTests: AbstractResponseTests {
    override func getTestClass() -> XCTestCase.Type {
        return AzureDevOpsV6PipelineTests.self
    }
    
    override func getDecoder() -> ApiResponseDecoder {
        return AzureDevopsV6Pipeline.ResponseDecoder()
    }

    override func test_everyScenario() {
        XCTAssertEqual(AzureDevopsV6Pipeline.Response.init(value: []).toStatus(), .unknown)

        XCTAssertEqual(getStatusFor(state: .completed, result: .succeeded), .success)
        XCTAssertEqual(getStatusFor(state: .completed, result: .failed), .fail)
        XCTAssertEqual(getStatusFor(state: .completed, result: .canceled), .fail)
        XCTAssertEqual(getStatusFor(state: .completed, result: .unknown), .unknown)

        XCTAssertEqual(getStatusFor(state: .inProgress, result: .succeeded), .running)
        XCTAssertEqual(getStatusFor(state: .inProgress, result: .failed), .running)
        XCTAssertEqual(getStatusFor(state: .inProgress, result: .canceled), .running)
        XCTAssertEqual(getStatusFor(state: .inProgress, result: .unknown), .running)

        XCTAssertEqual(getStatusFor(state: .canceling, result: .succeeded), .running)
        XCTAssertEqual(getStatusFor(state: .canceling, result: .failed), .running)
        XCTAssertEqual(getStatusFor(state: .canceling, result: .canceled), .running)
        XCTAssertEqual(getStatusFor(state: .canceling, result: .unknown), .running)

        XCTAssertEqual(getStatusFor(state: .unknown, result: .succeeded), .unknown)
        XCTAssertEqual(getStatusFor(state: .unknown, result: .failed), .unknown)
        XCTAssertEqual(getStatusFor(state: .unknown, result: .canceled), .unknown)
        XCTAssertEqual(getStatusFor(state: .unknown, result: .unknown), .unknown)
    }

    private func getStatusFor(state: AzureDevopsV6Pipeline.Response.RunState,
                              result: AzureDevopsV6Pipeline.Response.RunResult) -> ApiResponseStatus {
        let run = AzureDevopsV6Pipeline.Response.Run(state: state.rawValue, result: result.rawValue)
        return AzureDevopsV6Pipeline.Response.init(value: [run]).toStatus()
    }
}
