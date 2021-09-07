import Foundation

struct JobInfo: Equatable, Identifiable {
    var id: UUID?
    var name: String
    var url: String
    var apiType: ApiType
    
    static func empty() -> JobInfo {
        return JobInfo(id: nil,
                       name: "",
                       url: "",
                       apiType: .gitHubV3Workflow)
    }
}
