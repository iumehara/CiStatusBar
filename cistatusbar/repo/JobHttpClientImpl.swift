import Foundation
import Combine

class JobHttpClientImpl: JobHttpClient {
    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError> {
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
                                data: Data) -> AnyPublisher<Job, CisbError> {
        
        switch apiType {
        case .gitHubV3Workflow:
            let type = GitHubV3WorkflowResponse.self
            return Just(data)
                .decode(type: type, decoder: JSONDecoder())
                .map { Job(name: jobName, status: $0.toStatus())}
                .mapError { e in CisbError() }
                .eraseToAnyPublisher()
        case .gitLabV4Pipeline:
            let type = [GitLabV4PipelineResponse].self
            return Just(data)
                .decode(type: type, decoder: JSONDecoder())
                .map { Job(name: jobName, status: $0[0].toStatus()) }
                .mapError { e in CisbError()}
                .eraseToAnyPublisher()
        default:
            let type = OtherResponse.self
            return Just(data)
                .decode(type: type, decoder: JSONDecoder())
                .map { Job(name: jobName, status: $0.toStatus()) }
                .mapError { e in CisbError() }
                .eraseToAnyPublisher()
        }
    }
}
