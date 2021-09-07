import Foundation
import Combine

protocol RunRepo {
    func get(jobInfo: JobInfo) -> AnyPublisher<Run, CisbError>
    func getAll() -> AnyPublisher<[Run], CisbError>
}
