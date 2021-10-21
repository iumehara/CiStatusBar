enum ApiType: String, CaseIterable, Identifiable {
    case azureDevopsV6Pipeline
    case gitHubV3Workflow
    case gitLabV4Pipeline
    
    func details() -> ApiDetails {
        switch self {
        case .azureDevopsV6Pipeline:
            return AzureDevopsV6Pipeline.Details()
        case .gitHubV3Workflow:
            return GitHubV3Workflow.Details()
        case .gitLabV4Pipeline:
            return GitLabV4Pipeline.Details()
        }
    }
    
    var id: String { self.rawValue }
}
