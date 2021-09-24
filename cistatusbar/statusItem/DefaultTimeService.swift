import Foundation
import Combine

class DefaultTimeService: TimeService {
    private var startTime: Date?
    
    func dateNow() -> Date {
        Date()
    }
    
    func timeZone() -> TimeZone {
        TimeZone.current
    }
    
    func startScheduler(frequency: Int, callback: @escaping () -> Void) -> AnyCancellable? {
        let frequencySeconds = Double(frequency) * 60.0
        return Timer.publish(every: frequencySeconds, on: .main, in: .common)
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    callback()
                }
    }
    
    func startTimer() {
        startTime = Date()
    }
    
    func timeIntervalSinceStart() -> Int {
        guard let startTime = startTime else { return 0 }
        return Int(Date().timeIntervalSince(startTime))
    }
    
    func sleep(for seconds: Int) {
        Darwin.sleep(UInt32(seconds))
    }
}
