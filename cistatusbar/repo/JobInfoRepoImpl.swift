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

    func create(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        return self.jobInfoDao.create(jobInfo: jobInfo)
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        return self.jobInfoDao.delete(id: id)
    }
}
