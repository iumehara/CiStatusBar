import Foundation
import Combine

class JobInfoDaoStub: JobInfoDao {
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        let jobInfos = [
            JobInfo(id: UUID().uuidString,
                    name: "test",
                    url: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3189591/runs",
                    apiType: .gitHubV3Workflow),
            JobInfo(id: UUID().uuidString,
                    name: "deploy",
                    url: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3188936/runs",
                    apiType: .gitHubV3Workflow)
        ]
        
        return Just(jobInfos)
            .mapError { error in CisbError()}
            .eraseToAnyPublisher()
    }
    
    func create(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .mapError { error in CisbError()}
            .eraseToAnyPublisher()
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        return Just(true)
            .mapError { error in CisbError()}
            .eraseToAnyPublisher()
    }
}
