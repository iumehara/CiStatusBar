import Foundation
import Combine

class JobInfoDaoImpl: JobInfoDao {
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        let stubJobs = [
            JobInfo(id: 1,
                    name: "test",
                    url: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3189591/runs",
                    apiType: ApiType.gitHubV3Workflow),
            JobInfo(id: 2,
                    name: "deploy",
                    url: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3188936/runs",
                    apiType: ApiType.gitHubV3Workflow)
        ]
        
        return Just(stubJobs)
            .mapError { error in CisbError()}
            .eraseToAnyPublisher()
    }
}
