import Foundation
import Combine

protocol JobsRepo {
    func getAll() -> AnyPublisher<[Job], CisbError>
}
