import Foundation
import Combine

class RunHttpClientSpy: RunHttpClient {
    var get_calledWithJobs: [Job] = []
    
    func get(job: Job) -> AnyPublisher<Run, CisbError> {
        self.get_calledWithJobs.append(job)
        
        return Just(Run(name: "", status: .unknown))
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
    }
}

class RunHttpClientSuccessStub: RunHttpClient {
    var id = 0

    func get(job: Job) -> AnyPublisher<Run, CisbError> {
        id += 1

        return Just(Run(name: "unit tests \(id)", status: .success))
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
    }
}

