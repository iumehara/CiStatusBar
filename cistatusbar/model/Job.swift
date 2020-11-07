import Foundation

struct Job: Hashable, Codable {
    var name: String
    var status: String
}

struct JobInfo: Equatable {
    var name: String
    var url: URL
    var apiType: ApiType
}

enum ApiType {
    case gitHubV3Workflow
}
