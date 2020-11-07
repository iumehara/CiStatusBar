import Foundation
import Combine

class JobInfoDaoImpl: JobInfoDao {
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        let stubJobs = [
            JobInfo(name: "test",
                    url: URL(string: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3189591/runs")!,
                    apiType: ApiType.gitHubV3Workflow),
            JobInfo(name: "deploy",
                    url: URL(string: "https://api.github.com/repos/iumehara/OhiruFinder/actions/workflows/3188936/runs")!,
                    apiType: ApiType.gitHubV3Workflow)
        ]
        
        return Just(stubJobs)
            .mapError { error in CisbError()}
            .eraseToAnyPublisher()
    }
}
