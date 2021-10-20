import Foundation
import Combine
import XCTest

class AbstractResponseTests: XCTestCase {
    func getTestClass() -> XCTestCase.Type {
        fatalError("Subclass must implement getTestClass()")
    }
    
    func getDecoder() -> ApiResponseDecoder {
        fatalError("Subclass must implement getDecoder()")
    }
    
    func test_success() {
        run_test(jobName: "success job", typeOfJsonFileToParse: "SuccessResponse", expectedStatus: .success)
    }
    
    func test_running() {
        run_test(jobName: "running job", typeOfJsonFileToParse: "RunningResponse", expectedStatus: .running)
    }
    
    func test_fail() {
        run_test(jobName: "fail job", typeOfJsonFileToParse: "FailResponse", expectedStatus: .fail)
    }
    
    func test_unknown() {
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
        
        guard let dataJson = Bundle(for: getTestClass())
                .path(forResource: resourceName, ofType: "json") else {
            XCTFail("Could not find test json file: \(resourceName).json")
            return Data(capacity: 0)
        }
        
        return try! Data(contentsOf: URL(fileURLWithPath: dataJson))
    }
}
//
//enum TestError: Error {
//    case runtimeError(String)
//}
