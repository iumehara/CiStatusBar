import XCTest

class GitHubV3WorkflowTests: AbstractResponseTests {
    override func getTestClass() -> XCTestCase.Type {
        return GitHubV3WorkflowTests.self
    }

    override func getDecoder() -> ApiResponseDecoder {
        return GitHubV3Workflow.ResponseDecoder()
    }
    
    override func test_everyScenario() {
        XCTAssertEqual(GitHubV3Workflow.Response(workflow_runs: []).toStatus(), .unknown)
        
        XCTAssertEqual(getStatusFor(status: .queued, conclusion: .success), .running)
        XCTAssertEqual(getStatusFor(status: .queued, conclusion: .failure), .running)
        XCTAssertEqual(getStatusFor(status: .queued, conclusion: .neutral), .running)
        XCTAssertEqual(getStatusFor(status: .queued, conclusion: .cancelled), .running)
        XCTAssertEqual(getStatusFor(status: .queued, conclusion: .skipped), .running)
        XCTAssertEqual(getStatusFor(status: .queued, conclusion: .timed_out), .running)
        XCTAssertEqual(getStatusFor(status: .queued, conclusion: .action_required), .running)

        XCTAssertEqual(getStatusFor(status: .in_progress, conclusion: .success), .running)
        XCTAssertEqual(getStatusFor(status: .in_progress, conclusion: .failure), .running)
        XCTAssertEqual(getStatusFor(status: .in_progress, conclusion: .neutral), .running)
        XCTAssertEqual(getStatusFor(status: .in_progress, conclusion: .cancelled), .running)
        XCTAssertEqual(getStatusFor(status: .in_progress, conclusion: .skipped), .running)
        XCTAssertEqual(getStatusFor(status: .in_progress, conclusion: .timed_out), .running)
        XCTAssertEqual(getStatusFor(status: .in_progress, conclusion: .action_required), .running)

        XCTAssertEqual(getStatusFor(status: .completed, conclusion: .success), .success)
        XCTAssertEqual(getStatusFor(status: .completed, conclusion: .failure), .fail)
        XCTAssertEqual(getStatusFor(status: .completed, conclusion: .neutral), .unknown)
        XCTAssertEqual(getStatusFor(status: .completed, conclusion: .cancelled), .fail)
        XCTAssertEqual(getStatusFor(status: .completed, conclusion: .skipped), .unknown)
        XCTAssertEqual(getStatusFor(status: .completed, conclusion: .timed_out), .fail)
        XCTAssertEqual(getStatusFor(status: .completed, conclusion: .action_required), .unknown)
    }

    private func getStatusFor(status: GitHubV3Workflow.Response.GithubStatus,
                              conclusion: GitHubV3Workflow.Response.GithubConclusion) -> ApiResponseStatus {
        let run = GitHubV3Workflow.Response.WorkflowRun(conclusion: conclusion.rawValue, status: status.rawValue)
        return GitHubV3Workflow.Response(workflow_runs: [run]).toStatus()
    }
}
