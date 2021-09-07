import Foundation
import Combine

struct GitLabV4Pipeline {
    struct Details: ApiDetails {
        var apiType = ApiType.gitLabV4Pipeline
        var description = "GitLab V4 Pipeline"
        var format = "https://gitlab.com/api/v4/projects/:owner%2F:repo/pipelines"
        var apiReference = URL(string: "https://docs.gitlab.com/ee/api/pipelines.html#list-project-pipelines")!
    }

    struct Response: Codable, ApiResponse {
        var status: String = ""

        enum Status: String {
            case created
            case waiting_for_resource
            case preparing
            case pending
            case running
            case success
            case failed
            case canceled
            case skipped
            case manual
            case scheduled
        }
        
        func toStatus() -> ApiResponseStatus {
            switch status {
            case Status.success.rawValue:
                return .success
            case Status.failed.rawValue:
                return .fail
            case Status.created.rawValue,
                 Status.waiting_for_resource.rawValue,
                 Status.preparing.rawValue,
                 Status.pending.rawValue,
                 Status.running.rawValue,
                 Status.scheduled.rawValue:
                return .running
            default:
                return .unknown
            }
        }
    }
    
    struct ResponseDecoder: ApiResponseDecoder {
        func decode(jobName: String, data: Data) -> AnyPublisher<Run, CisbError> {
            let type = [GitLabV4Pipeline.Response].self
            return Just(data)
                .decode(type: type, decoder: JSONDecoder())
                .map { Run(name: jobName, status: $0[0].toStatus()) }
                .mapError { e in CisbError()}
                .eraseToAnyPublisher()
        }
    }
}
