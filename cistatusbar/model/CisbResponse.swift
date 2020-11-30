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

enum CisbStatus: String, Codable {
    case success
    case fail
}

protocol CisbResponse: Codable {
    func toStatus() -> CisbStatus
}

struct GitHubV3WorkflowResponse: Codable, CisbResponse {
    var workflow_runs: [WorkflowRun]
    
    struct WorkflowRun: Codable {
        var conclusion: String
    }
    
    func toStatus() -> CisbStatus {
        if self.workflow_runs.count == 0 {
            return .fail
        }
        
        if self.workflow_runs[0].conclusion == "success" {
            return .success
        }
        
        return .fail
    }
}

struct GitLabV4PipelineResponse: Codable, CisbResponse {
    var stringStatus: String

    func toStatus() -> CisbStatus {
        if stringStatus == "success" {
            return .success
        }
        
        return .fail
    }
}

struct OtherResponse: Codable, CisbResponse {
    func toStatus() -> CisbStatus {
        return .fail
    }
}
