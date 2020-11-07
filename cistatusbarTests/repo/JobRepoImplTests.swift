import XCTest
@testable import cistatusbar
import Combine

class JobRepoImplTests: XCTestCase {
    func test_getAll_callsHttpClientWithCorrectArgs() throws {
        let jobInfoDao = JobInfoDaoStub()
        let jobHttpClient = JobHttpClientSpy()
        
        let repo = JobsRepoImpl(jobInfoDao: jobInfoDao,
                                jobHttpClient: jobHttpClient)
        
        _ = repo.getAll()
            .sink(
                receiveCompletion: { completion in
                    let stub1 = JobInfo(name: "first job",
                            url: URL(string: "https://api.firstjob.example.com")!,
                            apiType: ApiType.gitHubV3Workflow)
                    let stub2 = JobInfo(name: "second job",
                            url: URL(string: "https://api.secondjob.example.com")!,
                            apiType: ApiType.gitHubV3Workflow)
                    XCTAssertEqual(jobHttpClient.get_calledWithJobInfos.count, 2)
                    XCTAssertTrue(jobHttpClient.get_calledWithJobInfos.contains(stub1))
                    XCTAssertTrue(jobHttpClient.get_calledWithJobInfos.contains(stub2))
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { _ in}
            )
    }
    
    func test_getAll_returnsJobs() throws {
        let jobInfoDao = JobInfoDaoStub()
        let jobHttpClient = JobHttpClientSuccessStub()

        let repo = JobsRepoImpl(jobInfoDao: jobInfoDao,
                                jobHttpClient: jobHttpClient)

        _ = repo.getAll()
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { value in
                    XCTAssertEqual(value, [
                        Job(name: "unit tests 1", status: "success"),
                        Job(name: "unit tests 2", status: "success")
                    ])
                }
            )
    }
}
