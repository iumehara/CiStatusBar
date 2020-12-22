import XCTest
@testable import cistatusbar
import Combine

class GitHubV3WorkflowTests: XCTestCase {

    func test_example() throws {
        let dataJson = Bundle(for: GitHubV3WorkflowTests.self)
            .path(forResource: "GitHubV3WorkflowResponse", ofType: "json")!
        

        let data = try! Data(contentsOf: URL(fileURLWithPath: dataJson))
        
        _ = GitHubV3Workflow.ResponseDecoder().decode(jobName: "job", data: data)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, .finished)
                },
                receiveValue: { value in
                    XCTAssertEqual(value, Job(name: "job", status: .success))
                })
    }
}

