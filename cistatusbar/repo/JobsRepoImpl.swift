import Foundation
import Combine

class JobsRepoImpl: JobsRepo {
    private var jobInfoDao: JobInfoDao
    private var jobHttpClient: JobHttpClient
    
    init(jobInfoDao: JobInfoDao, jobHttpClient: JobHttpClient) {
        self.jobInfoDao = jobInfoDao
        self.jobHttpClient = jobHttpClient
    }
    
    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError> {
        return self.jobHttpClient.get(jobInfo: jobInfo)
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }

    func getAll() -> AnyPublisher<[Job], CisbError> {
        return self.jobInfoDao.getAll()
            .flatMap { (jobInfos: [JobInfo]) -> AnyPublisher<[Job], CisbError> in
                if jobInfos.count == 0 {
                    return self.empty()
                }
                
                return self.zipMany(jobInfos: jobInfos)
            }
            .eraseToAnyPublisher()
    }

    private func empty()  -> AnyPublisher<[Job], CisbError> {
        return Just([])
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }
    
    private func zipMany(jobInfos: [JobInfo]) -> AnyPublisher<[Job], CisbError> {
        let requests = jobInfos.map { self.jobHttpClient.get(jobInfo: $0) }
        return requests
            .dropFirst()
            .reduce(into: AnyPublisher(requests[0].map{[$0]})) { zippedRequests, nextRequest in
                zippedRequests = zippedRequests.zip(nextRequest) { zippedRequestsResult, nextRequestResult -> [Job] in
                    return zippedRequestsResult + [nextRequestResult]
                    
                }
                .eraseToAnyPublisher()
            }
    }
}
