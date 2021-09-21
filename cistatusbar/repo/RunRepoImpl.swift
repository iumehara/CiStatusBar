import Foundation
import Combine

class RunRepoImpl: RunRepo {
    private var jobDao: JobDao
    private var runHttpClient: RunHttpClient
    
    init(jobDao: JobDao, runHttpClient: RunHttpClient) {
        self.jobDao = jobDao
        self.runHttpClient = runHttpClient
    }
    
    func get(job: Job) -> AnyPublisher<Run, CisbError> {
        return self.runHttpClient.get(job: job)
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }

    func getAll() -> AnyPublisher<[Run], CisbError> {
        return self.jobDao.getAll()
            .flatMap { (jobs: [Job]) -> AnyPublisher<[Run], CisbError> in
                if jobs.count == 0 {
                    return self.empty()
                }
                
                return self.zipMany(jobs: jobs)
            }
            .eraseToAnyPublisher()
    }

    private func empty()  -> AnyPublisher<[Run], CisbError> {
        return Just([])
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
    }
    
    private func zipMany(jobs: [Job]) -> AnyPublisher<[Run], CisbError> {
        let requests = jobs.map { self.runHttpClient.get(job: $0) }
        return requests
            .dropFirst()
            .reduce(into: AnyPublisher(requests[0].map{[$0]})) { zippedRequests, nextRequest in
                zippedRequests = zippedRequests.zip(nextRequest) { zippedRequestsResult, nextRequestResult -> [Run] in
                    return zippedRequestsResult + [nextRequestResult]
                    
                }
                .eraseToAnyPublisher()
            }
    }
}
