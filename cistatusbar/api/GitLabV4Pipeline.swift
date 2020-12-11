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

        func toStatus() -> ApiResponseStatus {
            if status == "success" {
                return .success
            }
            
            return .fail
        }
    }
    
    struct ResponseDecoder: ApiResponseDecoder {
        func decode(jobName: String, data: Data) -> AnyPublisher<Job, CisbError> {
            let type = [GitLabV4Pipeline.Response].self
            return Just(data)
                .decode(type: type, decoder: JSONDecoder())
                .map { Job(name: jobName, status: $0[0].toStatus()) }
                .mapError { e in CisbError()}
                .eraseToAnyPublisher()
        }
    }
}
