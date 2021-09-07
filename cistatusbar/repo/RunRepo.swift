import Foundation
import Combine

protocol RunRepo {
    func get(job: Job) -> AnyPublisher<Run, CisbError>
    func getAll() -> AnyPublisher<[Run], CisbError>
}
