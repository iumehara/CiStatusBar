import Foundation
import Combine
@testable import cistatusbar

class RunRepoSpy: RunRepo {
    var get_calledWith: Job?
    func get(job: Job) -> AnyPublisher<Run, CisbError> {
        get_calledWith = job
        return Result.Publisher(Run(name: "First Project Test", status: .success)).eraseToAnyPublisher()
    }
    
    var getAll_called = false
    func getAll() -> AnyPublisher<[Run], CisbError> {
        getAll_called = true
        return Result.Publisher([
                Run(name: "First Project Test", status: .success),
                Run(name: "First Project Build", status: .success)
             ])
            .eraseToAnyPublisher()
    }
}

class JobRepoSpy: JobRepo {
    var getAll_called = false
    func getAll() -> AnyPublisher<[Job], CisbError> {
        getAll_called = true
        return Result.Publisher([
            Job(id: UUID.init(), name: "First Project Test", url: "https://www.example.com", apiType: .gitHubV3Workflow),
            Job(id: UUID.init(), name: "First Project Build", url: "https://www.example.com", apiType: .gitHubV3Workflow)
             ])
            .eraseToAnyPublisher()
    }
    
    var save_calledWith: Job?
    func save(job: Job) -> AnyPublisher<Bool, CisbError> {
        save_calledWith = job
        return Result.Publisher(true)
            .eraseToAnyPublisher()
    }
    
    var delete_calledWith: UUID?
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        delete_calledWith = id
        return Result.Publisher(true)
            .eraseToAnyPublisher()
    }
}
