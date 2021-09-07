import Foundation
import Combine

class RunRepoImpl: RunRepo {
    private var jobInfoDao: JobInfoDao
    private var runHttpClient: RunHttpClient
    
    init(jobInfoDao: JobInfoDao, runHttpClient: RunHttpClient) {
        self.jobInfoDao = jobInfoDao
        self.runHttpClient = runHttpClient
    }
    
    func get(jobInfo: JobInfo) -> AnyPublisher<Run, CisbError> {
        return self.runHttpClient.get(jobInfo: jobInfo)
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }

    func getAll() -> AnyPublisher<[Run], CisbError> {
        return self.jobInfoDao.getAll()
            .flatMap { (jobInfos: [JobInfo]) -> AnyPublisher<[Run], CisbError> in
                if jobInfos.count == 0 {
                    return self.empty()
                }
                
                return self.zipMany(jobInfos: jobInfos)
            }
            .eraseToAnyPublisher()
    }

    private func empty()  -> AnyPublisher<[Run], CisbError> {
        return Just([])
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }
    
    private func zipMany(jobInfos: [JobInfo]) -> AnyPublisher<[Run], CisbError> {
        let requests = jobInfos.map { self.runHttpClient.get(jobInfo: $0) }
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
