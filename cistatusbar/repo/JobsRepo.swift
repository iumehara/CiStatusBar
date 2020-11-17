import Foundation
import Combine

protocol JobsRepo {
    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError>
    func getAll() -> AnyPublisher<[Job], CisbError>
}
