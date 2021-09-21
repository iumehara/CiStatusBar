import Foundation
import Combine

protocol TimeService {
    func dateNow() -> Date
    func timeZone() -> TimeZone
    func startTimer(frequency: Int, callback: @escaping () -> Void) -> AnyCancellable?
}
