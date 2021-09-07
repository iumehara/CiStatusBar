import Foundation
import Combine

protocol RunHttpClient {
    func get(job: Job) -> AnyPublisher<Run, CisbError>
}
