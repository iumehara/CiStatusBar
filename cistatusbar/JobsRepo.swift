import Foundation
import Combine

struct Job: Hashable, Codable {
    var name: String
    var status: String
}

struct CisbError: Error {}

enum ApiType {
    case gitHubV3Workflow
}

struct JobInfo {
    var name: String
    var url: URL
    var apiType: ApiType
}

struct GitHubV3WorkflowResponse: Codable {
    var workflow_runs: [GitHubV3WorkflowResponse.WorkflowRun]
    
    struct WorkflowRun: Codable {
        var conclusion: String
    }
    
    func toStatus() -> String {
        return self.workflow_runs[0].conclusion
    }
}

protocol JobsRepo {
    func getAll() -> AnyPublisher<[Job], CisbError>
}

class GithubJobsRepo : JobsRepo {
    func getAll() -> AnyPublisher<[Job], CisbError> {
        let jobInfo = JobInfo(name: "test",
                              url: URL(string: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3189591/runs")!,
                              apiType: ApiType.gitHubV3Workflow)
        let getFirst = get(jobInfo: jobInfo)
                
        let response = Publishers.Zip(getFirst, getEmpty())
            .mapError { error in CisbError()}
            .map { (response1, response2) -> [Job] in
                let responseList = [response1, response2]
                return responseList
            }
            .eraseToAnyPublisher()
        
        return response
    }
    
    func getEmpty() -> AnyPublisher<Job, CisbError> {
        return Just(Job(name: "", status: "success"))
            .mapError { error in CisbError()}
            .map { response in
                return response
            }
            .eraseToAnyPublisher()
    }
    

    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError> {
        var request = URLRequest(url: jobInfo.url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                CisbError()
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                return self.decodeResponse(apiType: jobInfo.apiType, jobName: jobInfo.name, data: pair.data)
            }
        .eraseToAnyPublisher()
    }

    private func decodeResponse(apiType: ApiType, jobName: String, data: Data) -> AnyPublisher<Job, CisbError> {
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

class StubJobsRepo: JobsRepo {
    func getAll() -> AnyPublisher<[Job], CisbError> {
        let jobs = [
            Job(name: "unit tests", status: "success"),
            Job(name: "deployment", status: "success")
        ]
        
        let response = Just(jobs)
            .mapError { error in
                CisbError()
            }
            .eraseToAnyPublisher()
        
         return response
    }
}
