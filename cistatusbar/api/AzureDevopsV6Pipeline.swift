import Foundation
import Combine

struct AzureDevopsV6Pipeline {
    struct Details: ApiDetails {
        var apiType = ApiType.azureDevopsV6Pipeline
        var description = "Azure DevOps V6 Pipeline"
        var format = "https://dev.azure.com/:owner/:repo/_apis/pipelines/{pipelineId}/runs?api-version=6.1-preview.1"
        var apiReference = URL(string: "https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/list?view=azure-devops-rest-6.1")!
    }
    
    struct Response: Codable, ApiResponse {
        var value: [Run] = []
        
        struct Run: Codable {
            var state: String
            var result: String
        }
        
        enum RunState: String, CaseIterable {
            case canceling
            case completed
            case inProgress
            case unknown
        }
        
        enum RunResult: String, CaseIterable {
            case canceled
            case failed
            case succeeded
            case unknown
        }
        
        func toStatus() -> ApiResponseStatus {
            guard let latestRun = value.first else {
                return .unknown
            }
            
            if latestRun.state == RunState.unknown.rawValue {
                return .unknown
            }
            
            if latestRun.state == RunState.inProgress.rawValue ||
                       latestRun.state == RunState.canceling.rawValue {
                return .running
            }
            
            switch latestRun.result {
            case RunResult.succeeded.rawValue:
                return .success
            case RunResult.failed.rawValue,
                 RunResult.canceled.rawValue:
                return .fail
            default:
                return .unknown
            }
        }
    }
    
    struct ResponseDecoder: ApiResponseDecoder {
        func decode(jobName: String, data: Data) -> AnyPublisher<Run, CisbError> {
            let type = AzureDevopsV6Pipeline.Response.self
            return Just(data)
                    .decode(type: type, decoder: JSONDecoder())
                    .map {
                        Run(name: jobName, status: $0.toStatus())
                    }
                    .mapError { e in
                        CisbError()
                    }
                    .eraseToAnyPublisher()
        }
    }
}
