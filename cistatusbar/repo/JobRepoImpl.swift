import Foundation
import Combine

class JobRepoImpl: JobRepo {
    private var jobDao: JobDao
    
    init(jobDao: JobDao) {
        self.jobDao = jobDao
    }
    
    func getAll() -> AnyPublisher<[Job], CisbError> {
        return self.jobDao.getAll()
    }

    func save(job: Job) -> AnyPublisher<Bool, CisbError> {
        if job.id == nil {
            return self.jobDao.create(job: job)
        }
        return self.jobDao.update(job: job)
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        return self.jobDao.delete(id: id)
    }
}
