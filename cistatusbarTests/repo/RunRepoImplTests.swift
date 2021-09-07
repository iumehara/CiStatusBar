import XCTest
import Combine

class RunRepoImplTests: XCTestCase {
    func test_get_callsHttpClientWithCorrectArgs() throws {
        let jobDao = JobDaoStub()
        let runHttpClient = RunHttpClientSpy()
        
        let repo = RunRepoImpl(jobDao: jobDao,
                                runHttpClient: runHttpClient)
        let job = Job(id: UUID(),
                            name: "first job",
                            url: "https://api.firstjob.example.com",
                            apiType: .gitHubV3Workflow)
        
        _ = repo.get(job: job)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(runHttpClient.get_calledWithJobs.count, 1)
                    XCTAssertTrue(runHttpClient.get_calledWithJobs.contains(job))
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { _ in}
            )
    }
    
    func test_get_returnsJobs() throws {
        let jobDao = JobDaoStub()
        let runHttpClient = RunHttpClientSuccessStub()

        let repo = RunRepoImpl(jobDao: jobDao,
                                runHttpClient: runHttpClient)
        let job = Job(id: UUID(),
                            name: "first job",
                            url: "https://api.firstjob.example.com",
                            apiType: .gitHubV3Workflow)
        
        _ = repo.get(job: job)
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
        let jobDao = JobDaoStub()
        let runHttpClient = RunHttpClientSpy()
        
        let repo = RunRepoImpl(jobDao: jobDao,
                                runHttpClient: runHttpClient)
        
        _ = repo.getAll()
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(runHttpClient.get_calledWithJobs.count, 2)
                    XCTAssertTrue(runHttpClient.get_calledWithJobs.contains(jobDao.getAll_stubResponse[0]))
                    XCTAssertTrue(runHttpClient.get_calledWithJobs.contains(jobDao.getAll_stubResponse[1]))
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { _ in}
            )
    }
    
    func test_getAll_returnsJobs() throws {
        let jobDao = JobDaoStub()
        let runHttpClient = RunHttpClientSuccessStub()

        let repo = RunRepoImpl(jobDao: jobDao,
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
