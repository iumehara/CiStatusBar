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
        run_test(jobName: "success job", typeOfJsonFileToParse: "SuccessResponse", expectedStatus: .success)
    }

    func run_test_running() {
        run_test(jobName: "running job", typeOfJsonFileToParse: "RunningResponse", expectedStatus: .running)
    }
    
    func run_test_fail() {
        run_test(jobName: "fail job", typeOfJsonFileToParse: "FailResponse", expectedStatus: .fail)
    }
    
    func run_test_unknown() {
        run_test(jobName: "unknown job", typeOfJsonFileToParse: "UnknownResponse", expectedStatus: .unknown)
    }

    private func run_test(jobName: String,
                          typeOfJsonFileToParse: String,
                          expectedStatus: ApiResponseStatus) {
        _ = getDecoder().decode(jobName: jobName, data: dataFrom(filetype: typeOfJsonFileToParse))
            .sink(receiveCompletion: { completion in XCTAssertEqual(completion, .finished) },
                  receiveValue: { value in XCTAssertEqual(value, Run(name: jobName, status: expectedStatus)) })
    }

    private func dataFrom(filetype: String) -> Data {
        let className = getTestClass().className().components(separatedBy: ".")[1]
        let resourceName = className + "_" + filetype
        
        let dataJson = Bundle(for: getTestClass())
            .path(forResource: resourceName, ofType: "json")!
        
        return try! Data(contentsOf: URL(fileURLWithPath: dataJson))
    }
}
