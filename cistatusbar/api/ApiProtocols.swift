import Foundation
import Combine

protocol ApiDetails {
    var apiType: ApiType { get }
    var description: String { get }
    var format: String { get }
    var apiReference: URL { get }
}

protocol ApiResponse: Codable {
    func toStatus() -> ApiResponseStatus
}

protocol ApiResponseDecoder {
    func decode(jobName: String, data: Data) -> AnyPublisher<Run, CisbError>
}

