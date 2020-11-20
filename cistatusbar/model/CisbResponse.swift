import Foundation

enum ApiType: String, CaseIterable, Identifiable {
    case gitHubV3Workflow
    case gitLabV4Pipeline
    case other
    
    var description: String {
        switch self {
        case .gitHubV3Workflow:
            return "GitHub V3 Workflow"
        case .gitLabV4Pipeline:
            return "GitLab V4 Pipeline"
        case .other:
            return "Other"
        }
    }
    
    var id: String { self.rawValue }
}

protocol CisbResponse: Codable {
    func toStatus() -> String
}

struct GitHubV3WorkflowResponse: Codable, CisbResponse {
    var workflow_runs: [WorkflowRun]
    
    struct WorkflowRun: Codable {
        var conclusion: String
    }
    
    func toStatus() -> String {
        if self.workflow_runs.count == 0 {
            return "fail"
        }
        
        return self.workflow_runs[0].conclusion
    }
}

struct GitLabV4PipelineResponse: Codable, CisbResponse {
    var status: String

    func toStatus() -> String {
        return self.status
    }
}

struct OtherResponse: Codable, CisbResponse {
    func toStatus() -> String {
        return "fail"
    }
}
