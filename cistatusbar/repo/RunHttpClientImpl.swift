import Foundation
import Combine

class RunHttpClientImpl: RunHttpClient {
    func get(jobInfo: JobInfo) -> AnyPublisher<Run, CisbError> {
        guard let url = URL(string: jobInfo.url) else {
            return Fail(error: CisbError()).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                CisbError()
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                return self.decodeResponse(apiType: jobInfo.apiType,
                                           jobName: jobInfo.name,
                                           data: pair.data)
            }
        .eraseToAnyPublisher()
    }

    private func decodeResponse(apiType: ApiType,
                                jobName: String,
                                data: Data) -> AnyPublisher<Run, CisbError> {
        
        switch apiType {
        case .gitHubV3Workflow:
            return GitHubV3Workflow.ResponseDecoder().decode(jobName: jobName, data: data)
        default:
            return GitLabV4Pipeline.ResponseDecoder().decode(jobName: jobName, data: data)
        }
    }
}