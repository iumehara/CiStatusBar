import Foundation

struct DefaultIconProvider: IconProvider {
    let success = "🟢"
    let fail = "🔴"
    let loading = "⌚️"
    let unknown = "⁉️"
}

protocol IconProvider {
    var success: String { get }
    var fail: String { get }
    var loading: String { get }
    var unknown: String { get }
}

extension IconProvider {
    func iconFor(status: ApiResponseStatus) -> String {
        switch status {
        case .success:
            return success
        case .fail:
            return fail
        case .running:
            return loading
        default:
            return unknown
        }
    }
}
