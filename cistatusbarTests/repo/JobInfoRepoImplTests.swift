import XCTest
import Combine

class JobInfoRepoImplTests: XCTestCase {

    func test_getAll_returnsJobInfos() throws {
        let jobInfoDao = JobInfoDaoStub()
        let repo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)

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
        let jobInfoDao = JobInfoDaoSpy()
        let repo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        
        let jobInfo = JobInfo(id: UUID(), name: "repo 1", url: "http://www.example.com", apiType: .gitHubV3Workflow)
        _ = repo.save(jobInfo: jobInfo)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                    XCTAssertEqual(jobInfoDao.update_calledWith, jobInfo)
                },
                receiveValue: { _ in}
            )
    }

    func test_save_withoutUuidCallsCreateOnDaoWithCorrectArgs() throws {
        let jobInfoDao = JobInfoDaoSpy()
        let repo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        
        let jobInfo = JobInfo(id: nil, name: "repo 1", url: "http://www.example.com", apiType: .gitHubV3Workflow)
        _ = repo.save(jobInfo: jobInfo)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                    XCTAssertEqual(jobInfoDao.create_calledWith, jobInfo)
                },
                receiveValue: { _ in}
            )
    }

    func test_delete_callsDeleteOnDaoWithCorrectArgs() throws {
        let jobInfoDao = JobInfoDaoSpy()
        let repo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        
        let uuid = UUID()
        _ = repo.delete(id: uuid)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertEqual(completion, Subscribers.Completion<CisbError>.finished)
                    XCTAssertEqual(jobInfoDao.delete_calledWith, uuid)
                },
                receiveValue: { _ in}
            )
    }
}
