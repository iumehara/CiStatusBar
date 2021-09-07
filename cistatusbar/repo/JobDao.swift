import Foundation
import Combine

protocol JobDao {
    func getAll() -> AnyPublisher<[Job], CisbError>
    func create(job: Job) -> AnyPublisher<Bool, CisbError>
    func update(job: Job) -> AnyPublisher<Bool, CisbError>
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError>
}
