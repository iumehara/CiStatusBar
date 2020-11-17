import Foundation
import Combine

protocol JobInfoDao {
    func getAll() -> AnyPublisher<[JobInfo], CisbError>
    func create(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError>
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError>
}

