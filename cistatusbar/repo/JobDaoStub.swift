import Foundation
import Combine

class JobDaoStub: JobDao {
    func getAll() -> AnyPublisher<[Job], CisbError> {
        let jobs = [
            Job(id: UUID(),
                    name: "test",
                    url: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3189591/runs",
                    apiType: .gitHubV3Workflow),
            Job(id: UUID(),
                    name: "deploy",
                    url: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3188936/runs",
                    apiType: .gitHubV3Workflow)
        ]
        
        return Just(jobs)
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
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
