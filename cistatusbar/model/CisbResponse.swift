import Foundation

enum ApiType: String, CaseIterable, Identifiable {
    case gitHubV3Workflow
    case gitLabV4Pipeline
    
    func responseType() -> CisbResponse {
        switch self {
        case .gitHubV3Workflow:
            return GitHubV3WorkflowResponse()
        case .gitLabV4Pipeline:
            return GitLabV4PipelineResponse()
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
    func description() -> String
    func format() -> String
    func apiReference() -> String
}

struct GitHubV3WorkflowResponse: Codable, CisbResponse {
    var workflow_runs: [WorkflowRun] = []
        
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
    
    func description() -> String {
        "GitHub V3 Workflow"
    }
    
    func format() -> String {
        "https://api.github.com/repos/:owner/:repo/actions/workflows/:workflow_id/runs"
    }
    
    func apiReference() -> String {
        "https://developer.github.com/v3/actions/workflow-runs/#list-workflow-runs"
    }
}

struct GitLabV4PipelineResponse: Codable, CisbResponse {
    var status: String = ""

    func toStatus() -> CisbStatus {
        if status == "success" {
            return .success
        }
        
        return .fail
    }
    
    func description() -> String {
        "GitLab V4 Pipeline"
    }
    
    func format() -> String {
        "https://gitlab.com/api/v4/projects/:owner%2F:repo/pipelines"
    }
    
    func apiReference() -> String {
        "https://docs.gitlab.com/ee/api/pipelines.html#list-project-pipelines"
    }
}
