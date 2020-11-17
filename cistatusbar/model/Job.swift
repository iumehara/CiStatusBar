import Foundation

struct Job: Hashable, Codable {
    var name: String
    var status: String
}

struct JobInfo: Equatable, Identifiable {
    var id: String
    var name: String
    var url: String
    var apiType: ApiType
    
    static func empty() -> JobInfo {
        return JobInfo(id: "",
                       name: "",
                       url: "",
                       apiType: .gitHubV3Workflow)
    }
}

enum ApiType {
    case gitHubV3Workflow
}
