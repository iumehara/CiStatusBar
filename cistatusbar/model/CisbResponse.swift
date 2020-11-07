import Foundation

protocol CisbResponse {
    func toStatus() -> String
}

struct GitHubV3WorkflowResponse: Codable, CisbResponse {
    var workflow_runs: [GitHubV3WorkflowResponse.WorkflowRun]
    
    struct WorkflowRun: Codable {
        var conclusion: String
    }
    
    func toStatus() -> String {
        return self.workflow_runs[0].conclusion
    }
}
