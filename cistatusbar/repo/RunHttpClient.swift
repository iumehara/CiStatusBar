import Foundation
import Combine

protocol RunHttpClient {
    func get(jobInfo: JobInfo) -> AnyPublisher<Run, CisbError>
}
