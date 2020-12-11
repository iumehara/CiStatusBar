import Foundation
import Combine

enum ApiType: String, CaseIterable, Identifiable {
    case gitHubV3Workflow
    case gitLabV4Pipeline
    
    func details() -> ApiDetails {
        switch self {
        case .gitHubV3Workflow:
            return GitHubV3Workflow.Details()
        case .gitLabV4Pipeline:
            return GitLabV4Pipeline.Details()
        }
    }
    
    var id: String { self.rawValue }
}

enum ApiResponseStatus: String, Codable {
    case success
    case fail
    case running
    case unknown
}

protocol ApiDetails {
    var apiType: ApiType { get }
    var description: String { get }
    var format: String { get }
    var apiReference: URL { get }
}

protocol ApiResponse: Codable {
    func toStatus() -> ApiResponseStatus
}

protocol ApiResponseDecoder {
    func decode(jobName: String, data: Data) -> AnyPublisher<Job, CisbError>
}

