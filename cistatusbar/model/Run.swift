import Foundation

struct Run: Hashable, Codable {
    var name: String
    var status: ApiResponseStatus
}
