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
        return successResponse(of: self.getAll_stubResponse)
    }
    
    func create(job: Job) -> AnyPublisher<Bool, CisbError> {
        return successResponse(of: true)
    }
    
    func update(job: Job) -> AnyPublisher<Bool, CisbError> {
        return successResponse(of: true)
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        return successResponse(of: true)
    }
    
    private func successResponse<T>(of response: T) -> AnyPublisher<T, CisbError> {
        return Just(response)
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
        return successResponse(of: [])
    }
    
    func create(job: Job) -> AnyPublisher<Bool, CisbError> {
        self.create_calledWith = job
        return successResponse(of: true)
    }
    
    func update(job: Job) -> AnyPublisher<Bool, CisbError> {
        self.update_calledWith = job
        return successResponse(of: true)
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        self.delete_calledWith = id
        return successResponse(of: true)
    }
    
    private func successResponse<T>(of response: T) -> AnyPublisher<T, CisbError> {
        return Just(response)
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
    }
}
