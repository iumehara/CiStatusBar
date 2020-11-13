import Foundation
import Combine

protocol JobInfoRepo {
    func getAll() -> AnyPublisher<[JobInfo], CisbError>
}
