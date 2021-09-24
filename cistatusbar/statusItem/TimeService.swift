import Foundation
import Combine

protocol TimeService {
    func dateNow() -> Date
    func timeZone() -> TimeZone
    func startScheduler(frequency: Int, callback: @escaping () -> Void) -> AnyCancellable?
    func startTimer()
    func timeIntervalSinceStart() -> Int
    func sleep(for seconds: Int)
}
