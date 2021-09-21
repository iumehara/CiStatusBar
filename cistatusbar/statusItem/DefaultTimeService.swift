import Foundation
import Combine

class DefaultTimeService: TimeService {
    func dateNow() -> Date {
        Date()
    }
    
    func timeZone() -> TimeZone {
        TimeZone.current
    }
    
    func startTimer(frequency: Int, callback: @escaping () -> Void) -> AnyCancellable? {
        let frequencySeconds = Double(frequency) * 60.0
        return Timer.publish(every: frequencySeconds, on: .main, in: .common)
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    callback()
                }
    }
}
