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
                
                if (jobInfos.count == 1) {
                    return self.getOne(jobInfo: jobInfos[0])
                }
                
                return self.getBoth(jobInfo1: jobInfos[0], jobInfo2: jobInfos[1])
            }
            .eraseToAnyPublisher()
    }

    private func empty()  -> AnyPublisher<[Job], CisbError> {
        return Just([])
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }

    private func getOne(jobInfo: JobInfo)  -> AnyPublisher<[Job], CisbError> {
        return self.jobHttpClient.get(jobInfo: jobInfo)
            .mapError { error in CisbError() }
            .map { response -> [Job] in
                return [response]
            }
            .eraseToAnyPublisher()
    }
    
    private func getBoth(jobInfo1: JobInfo, jobInfo2: JobInfo) -> AnyPublisher<[Job], CisbError> {
        let getFirst = self.jobHttpClient.get(jobInfo: jobInfo1)
        let getSecond = self.jobHttpClient.get(jobInfo: jobInfo2)
        
        return Publishers.Zip(getFirst, getSecond)
            .mapError { error in CisbError()}
            .map { (response1, response2) -> [Job] in
                return [response1, response2]
            }
            .eraseToAnyPublisher()
    }
}
