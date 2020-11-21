import Foundation
import Combine

protocol JobInfoRepo {
    func getAll() -> AnyPublisher<[JobInfo], CisbError>
    func save(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError>
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError>
}
