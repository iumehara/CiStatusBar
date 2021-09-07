import Foundation
import Combine
@testable import cistatusbar

class JobDaoStub: JobDao {
    var getAll_stubResponse = [
        Job(id: UUID(),
                name: "first job",
                url: "https://api.firstjob.example.com",
                apiType: .gitHubV3Workflow),
        Job(id: UUID(),
                name: "second job",
                url: "https://api.secondjob.example.com",
                apiType: .gitHubV3Workflow),
    ]
    func getAll() -> AnyPublisher<[Job], CisbError> {
        let response = Just(getAll_stubResponse)
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
        return response
    }
    
    func create(job: Job) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
    }
    
    func update(job: Job) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
    }
}

class JobDaoSpy: JobDao {
    var getAll_called = false
    var create_calledWith: Job? = nil
    var update_calledWith: Job? = nil
    var delete_calledWith: UUID? = nil

    func getAll() -> AnyPublisher<[Job], CisbError> {
        self.getAll_called = true
        return Just([]).mapError { error in CisbError()}.eraseToAnyPublisher()
    }
    
    func create(job: Job) -> AnyPublisher<Bool, CisbError> {
        self.create_calledWith = job
        return Just(true).mapError { error in CisbError() }.eraseToAnyPublisher()
    }
    
    func update(job: Job) -> AnyPublisher<Bool, CisbError> {
        self.update_calledWith = job
        return Just(true).mapError { error in CisbError() }.eraseToAnyPublisher()
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        self.delete_calledWith = id
        return Just(true).mapError { error in CisbError() }.eraseToAnyPublisher()
    }
}
