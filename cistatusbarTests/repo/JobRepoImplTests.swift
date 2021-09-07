import XCTest
import Combine

class JobRepoImplTests: XCTestCase {

    func test_getAll_returnsJobs() throws {
        let jobDao = JobDaoStub()
        let repo = JobRepoImpl(jobDao: jobDao)

        _ = repo.getAll()
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                },
                receiveValue: { value in
                    XCTAssertEqual(value.count, 2)
                    XCTAssertEqual(value[0].name, "first job")
                    XCTAssertEqual(value[1].name, "second job")
                }
            )
    }

    func test_save_withUuidCallsUpdateOnDaoWithCorrectArgs() throws {
        let jobDao = JobDaoSpy()
        let repo = JobRepoImpl(jobDao: jobDao)
        
        let job = Job(id: UUID(), name: "repo 1", url: "http://www.example.com", apiType: .gitHubV3Workflow)
        _ = repo.save(job: job)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                    XCTAssertEqual(jobDao.update_calledWith, job)
                },
                receiveValue: { _ in}
            )
    }

    func test_save_withoutUuidCallsCreateOnDaoWithCorrectArgs() throws {
        let jobDao = JobDaoSpy()
        let repo = JobRepoImpl(jobDao: jobDao)
        
        let job = Job(id: nil, name: "repo 1", url: "http://www.example.com", apiType: .gitHubV3Workflow)
        _ = repo.save(job: job)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                    XCTAssertEqual(jobDao.create_calledWith, job)
                },
                receiveValue: { _ in}
            )
    }

    func test_delete_callsDeleteOnDaoWithCorrectArgs() throws {
        let jobDao = JobDaoSpy()
        let repo = JobRepoImpl(jobDao: jobDao)
        
        let uuid = UUID()
        _ = repo.delete(id: uuid)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                    XCTAssertEqual(jobDao.delete_calledWith, uuid)
                },
                receiveValue: { _ in}
            )
    }
}
