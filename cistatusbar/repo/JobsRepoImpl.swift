import Foundation
import Combine

class JobsRepoImpl: JobsRepo {
    private var jobInfoDao: JobInfoDao
    private var jobHttpClient: JobHttpClient
    
    init(jobInfoDao: JobInfoDao, jobHttpClient: JobHttpClient) {
        self.jobInfoDao = jobInfoDao
        self.jobHttpClient = jobHttpClient
    }
    
    func getAll() -> AnyPublisher<[Job], CisbError> {
        return self.jobInfoDao.getAll()
            .flatMap { (jobInfos: [JobInfo]) -> AnyPublisher<[Job], CisbError> in
                return self.getBoth(jobInfo1: jobInfos[0], jobInfo2: jobInfos[1])
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
