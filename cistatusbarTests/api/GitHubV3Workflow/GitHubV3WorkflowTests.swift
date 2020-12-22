import XCTest
@testable import cistatusbar
import Combine

class GitHubV3WorkflowTests: XCTestCase {
    private var decoder: GitHubV3Workflow.ResponseDecoder!
    
    override func setUpWithError() throws {
        decoder = GitHubV3Workflow.ResponseDecoder()
    }

    func test_success() throws {
        let expectedResponse = Job(name: "job", status: .success)
        _ = decoder.decode(jobName: "job", data: dataFrom(filename: "SuccessResponse"))
            .sink(receiveCompletion: { completion in XCTAssertEqual(completion, .finished) },
                  receiveValue: { value in XCTAssertEqual(value, expectedResponse) })
    }

    func test_running() throws {
        let expectedResponse = Job(name: "job", status: .running)
        _ = decoder.decode(jobName: "job", data: dataFrom(filename: "RunningResponse"))
            .sink(receiveCompletion: { completion in XCTAssertEqual(completion, .finished) },
                  receiveValue: { value in XCTAssertEqual(value, expectedResponse) })
    }

    func test_fail() throws {
        let expectedResponse = Job(name: "job", status: .fail)
        _ = decoder.decode(jobName: "job", data: dataFrom(filename: "FailResponse"))
            .sink(receiveCompletion: { completion in XCTAssertEqual(completion, .finished) },
                  receiveValue: { value in XCTAssertEqual(value, expectedResponse) })
    }
    func test_unknown() throws {
        let expectedResponse = Job(name: "job", status: .unknown)
        _ = decoder.decode(jobName: "job", data: dataFrom(filename: "UnknownResponse"))
            .sink(receiveCompletion: { completion in XCTAssertEqual(completion, .finished) },
                  receiveValue: { value in XCTAssertEqual(value, expectedResponse) })
    }

    private func dataFrom(filename: String) -> Data {        
        let dataJson = Bundle(for: GitHubV3WorkflowTests.self)
            .path(forResource: filename, ofType: "json")!
        
        return try! Data(contentsOf: URL(fileURLWithPath: dataJson))
    }
}

