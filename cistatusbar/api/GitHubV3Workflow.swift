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
            
        struct WorkflowRun: Codable {
            var conclusion: String
        }
        
        func toStatus() -> ApiResponseStatus {
            if self.workflow_runs.count == 0 {
                return .fail
            }
            
            if self.workflow_runs[0].conclusion == "success" {
                return .success
            }
            
            return .fail
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

