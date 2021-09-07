import Foundation
import Combine
@testable import cistatusbar

class RunRepoSpy: RunRepo {
    var get_calledWith: JobInfo?
    func get(jobInfo: JobInfo) -> AnyPublisher<Run, CisbError> {
        get_calledWith = jobInfo
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

class JobInfoRepoSpy: JobInfoRepo {
    var getAll_called = false
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        getAll_called = true
        return Result.Publisher([
            JobInfo(id: UUID.init(), name: "First Project Test", url: "https://www.example.com", apiType: .gitHubV3Workflow),
            JobInfo(id: UUID.init(), name: "First Project Build", url: "https://www.example.com", apiType: .gitHubV3Workflow)
             ])
            .eraseToAnyPublisher()
    }
    
    var save_calledWith: JobInfo?
    func save(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        save_calledWith = jobInfo
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