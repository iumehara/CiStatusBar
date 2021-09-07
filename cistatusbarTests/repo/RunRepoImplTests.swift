import XCTest
import Combine

class RunRepoImplTests: XCTestCase {
    func test_get_callsHttpClientWithCorrectArgs() throws {
        let jobInfoDao = JobInfoDaoStub()
        let runHttpClient = RunHttpClientSpy()
        
        let repo = RunRepoImpl(jobInfoDao: jobInfoDao,
                                runHttpClient: runHttpClient)
        let jobInfo = JobInfo(id: UUID(),
                            name: "first job",
                            url: "https://api.firstjob.example.com",
                            apiType: .gitHubV3Workflow)
        
        _ = repo.get(jobInfo: jobInfo)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(runHttpClient.get_calledWithJobInfos.count, 1)
                    XCTAssertTrue(runHttpClient.get_calledWithJobInfos.contains(jobInfo))
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { _ in}
            )
    }
    
    func test_get_returnsJobs() throws {
        let jobInfoDao = JobInfoDaoStub()
        let runHttpClient = RunHttpClientSuccessStub()

        let repo = RunRepoImpl(jobInfoDao: jobInfoDao,
                                runHttpClient: runHttpClient)
        let jobInfo = JobInfo(id: UUID(),
                            name: "first job",
                            url: "https://api.firstjob.example.com",
                            apiType: .gitHubV3Workflow)
        
        _ = repo.get(jobInfo: jobInfo)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { value in
                    XCTAssertEqual(value, Run(name: "unit tests 1", status: .success))
                }
            )
    }
    
    func test_getAll_callsHttpClientWithCorrectArgs() throws {
        let jobInfoDao = JobInfoDaoStub()
        let runHttpClient = RunHttpClientSpy()
        
        let repo = RunRepoImpl(jobInfoDao: jobInfoDao,
                                runHttpClient: runHttpClient)
        
        _ = repo.getAll()
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(runHttpClient.get_calledWithJobInfos.count, 2)
                    XCTAssertTrue(runHttpClient.get_calledWithJobInfos.contains(jobInfoDao.getAll_stubResponse[0]))
                    XCTAssertTrue(runHttpClient.get_calledWithJobInfos.contains(jobInfoDao.getAll_stubResponse[1]))
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { _ in}
            )
    }
    
    func test_getAll_returnsJobs() throws {
        let jobInfoDao = JobInfoDaoStub()
        let runHttpClient = RunHttpClientSuccessStub()

        let repo = RunRepoImpl(jobInfoDao: jobInfoDao,
                                runHttpClient: runHttpClient)

        _ = repo.getAll()
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { value in
                    XCTAssertEqual(value, [
                        Run(name: "unit tests 1", status: .success),
                        Run(name: "unit tests 2", status: .success)
                    ])
                }
            )
    }
}
