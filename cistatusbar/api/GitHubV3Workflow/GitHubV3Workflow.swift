import Foundation
import Combine

struct GitHubV3Workflow {
    struct Details: ApiDetails {
        var apiType = ApiType.gitHubV3Workflow
        var description = "GitHub V3 Workflow"
        var format = "https://api.github.com/repos/:owner/:repo/actions/workflows/:workflow_id/runs"
        var apiReference = URL(string: "https://developer.github.com/v3/actions/workflow-runs/#list-workflow-runs")!
    }
    
    struct Response: Codable, ApiResponse {
        var workflow_runs: [WorkflowRun] = []
        
        enum GithubStatus: String {
            case queued
            case in_progress
            case completed
        }
        
        enum GithubConclusion: String {
            case success
            case failure
            case neutral
            case cancelled
            case skipped
            case timed_out
            case action_required
        }
        
            
        struct WorkflowRun: Codable {
            var conclusion: String
            var status: String
        }
        
        func toStatus() -> ApiResponseStatus {
            if self.workflow_runs.count == 0 {
                return .fail
            }
            
            let workflowRun = self.workflow_runs[0]

            if workflowRun.status != GithubStatus.completed.rawValue {
                return .running
            }
            
            if workflowRun.conclusion == GithubConclusion.success.rawValue {
                return .success
            }

            if workflowRun.conclusion == GithubConclusion.failure.rawValue {
                return .fail
            }

            return .unknown
        }
    }

    struct ResponseDecoder: ApiResponseDecoder {
        func decode(jobName: String, data: Data) -> AnyPublisher<Job, CisbError> {
            let type = GitHubV3Workflow.Response.self
            return Just(data)
                .decode(type: type, decoder: JSONDecoder())
                .map { Job(name: jobName, status: $0.toStatus())}
                .mapError { e in CisbError() }
                .eraseToAnyPublisher()
        }
    }
}

