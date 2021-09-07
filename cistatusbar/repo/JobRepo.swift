import Foundation
import Combine

protocol JobRepo {
    func getAll() -> AnyPublisher<[Job], CisbError>
    func save(job: Job) -> AnyPublisher<Bool, CisbError>
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError>
}
