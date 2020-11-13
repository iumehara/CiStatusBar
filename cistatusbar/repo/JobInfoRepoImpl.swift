import Foundation
import Combine

class JobInfoRepoImpl: JobInfoRepo {
    private var jobInfoDao: JobInfoDao
    
    init(jobInfoDao: JobInfoDao) {
        self.jobInfoDao = jobInfoDao
    }
    
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        return self.jobInfoDao.getAll()
    }
}
