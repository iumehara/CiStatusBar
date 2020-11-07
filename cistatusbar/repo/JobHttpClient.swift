import Foundation
import Combine

protocol JobHttpClient {
    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError>
}
