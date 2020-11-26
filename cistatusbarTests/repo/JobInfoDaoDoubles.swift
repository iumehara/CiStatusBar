import Foundation
import Combine

class JobInfoDaoStub: JobInfoDao {
    var getAll_stubResponse = [
        JobInfo(id: UUID(),
                name: "first job",
                url: "https://api.firstjob.example.com",
                apiType: ApiType.gitHubV3Workflow),
        JobInfo(id: UUID(),
                name: "second job",
                url: "https://api.secondjob.example.com",
                apiType: ApiType.gitHubV3Workflow),
    ]
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        return Just(getAll_stubResponse)
            .mapError { error in CisbError()}
            .eraseToAnyPublisher()
    }
    
    func create(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }
    
    func update(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .mapError { error in CisbError() }
            .eraseToAnyPublisher()
    }
}

class JobInfoDaoSpy: JobInfoDao {
    var getAll_called = false
    var create_calledWith: JobInfo? = nil
    var update_calledWith: JobInfo? = nil
    var delete_calledWith: UUID? = nil

    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        self.getAll_called = true
        return Just([]).mapError { error in CisbError()}.eraseToAnyPublisher()
    }
    
    func create(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        self.create_calledWith = jobInfo
        return Just(true).mapError { error in CisbError() }.eraseToAnyPublisher()
    }
    
    func update(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        self.update_calledWith = jobInfo
        return Just(true).mapError { error in CisbError() }.eraseToAnyPublisher()
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        self.delete_calledWith = id
        return Just(true).mapError { error in CisbError() }.eraseToAnyPublisher()
    }
}
