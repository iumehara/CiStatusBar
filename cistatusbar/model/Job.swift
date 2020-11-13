import Foundation

struct Job: Hashable, Codable {
    var name: String
    var status: String
}

struct JobInfo: Equatable, Identifiable {
    var id: Int
    var name: String
    var url: String
    var apiType: ApiType
}

enum ApiType {
    case gitHubV3Workflow
}
