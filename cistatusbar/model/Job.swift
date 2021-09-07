import Foundation

struct Job: Equatable, Identifiable {
    var id: UUID?
    var name: String
    var url: String
    var apiType: ApiType
    
    static func empty() -> Job {
        return Job(id: nil,
                       name: "",
                       url: "",
                       apiType: .gitHubV3Workflow)
    }
}
