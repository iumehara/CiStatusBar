import Foundation
import Combine

protocol JobInfoDao {
    func getAll() -> AnyPublisher<[JobInfo], CisbError>
}

