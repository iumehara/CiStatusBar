import Foundation
import Combine
import XCTest

protocol AbstractResponseTests {
    func getTestClass() -> XCTestCase.Type
    func getDecoder() -> ApiResponseDecoder
    func test_success()
    func test_running()
    func test_fail()
    func test_unknown()
}

extension AbstractResponseTests {
    func run_test_success() {
        run_test(jobName: "success job", nameOfJsonFileToParse: "SuccessResponse", expectedStatus: .success)
    }

    func run_test_running() {
        run_test(jobName: "running job", nameOfJsonFileToParse: "RunningResponse", expectedStatus: .running)
    }
    
    func run_test_fail() {
        run_test(jobName: "fail job", nameOfJsonFileToParse: "FailResponse", expectedStatus: .fail)
    }
    
    func run_test_unknown() {
        run_test(jobName: "unknown job", nameOfJsonFileToParse: "UnknownResponse", expectedStatus: .unknown)
    }

    private func run_test(jobName: String,
                          nameOfJsonFileToParse: String,
                          expectedStatus: ApiResponseStatus) {
        _ = getDecoder().decode(jobName: jobName, data: dataFrom(filename: nameOfJsonFileToParse))
            .sink(receiveCompletion: { completion in XCTAssertEqual(completion, .finished) },
                  receiveValue: { value in XCTAssertEqual(value, Job(name: jobName, status: expectedStatus)) })
    }

    private func dataFrom(filename: String) -> Data {
        let dataJson = Bundle(for: getTestClass())
            .path(forResource: filename, ofType: "json")!
        
        return try! Data(contentsOf: URL(fileURLWithPath: dataJson))
    }
}
