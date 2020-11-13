import Foundation
import Combine

class JobHttpClientImpl: JobHttpClient {
    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError> {
        var request = URLRequest(url: URL(string: jobInfo.url)!)
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
        let decoderType = GitHubV3WorkflowResponse.self
        
        return Just(data)
            .decode(type: decoderType, decoder: JSONDecoder())
            .map { response in
                return Job(name: jobName, status: response.toStatus())
            }
            .mapError { error in
                CisbError()
            }
            .eraseToAnyPublisher()
    }
}
