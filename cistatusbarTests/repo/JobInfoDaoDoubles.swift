import Foundation
import Combine

class JobInfoDaoStub: JobInfoDao {
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        let stubJobs = [
            JobInfo(name: "first job",
                    url: URL(string: "https://api.firstjob.example.com")!,
                    apiType: ApiType.gitHubV3Workflow),
            JobInfo(name: "second job",
                    url: URL(string: "https://api.secondjob.example.com")!,
                    apiType: ApiType.gitHubV3Workflow),
        ]
        
        return Just(stubJobs)
            .mapError { error in CisbError()}
            .eraseToAnyPublisher()
    }
}
