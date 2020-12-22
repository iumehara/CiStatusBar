import Foundation
import Combine

class JobHttpClientSpy: JobHttpClient {
    var get_calledWithJobInfos: [JobInfo] = []
    
    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError> {
        self.get_calledWithJobInfos.append(jobInfo)
        
        let response = Just(Job(name: "", status: .unknown))
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()
        
        return response
    }
}

class JobHttpClientSuccessStub: JobHttpClient {
    var id = 0

    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError> {
        id += 1
        
        let response = Just(Job(name: "unit tests \(id)", status: .success))
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()

        return response
    }
}

class AnoptherJobHttpClientSuccessStub {
    var id = 0

    func get(jobInfo: JobInfo) -> AnyPublisher<Job, CisbError> {
        id += 1
        
        let response = Just(Job(name: "unit tests \(id)", status: .success))
            .setFailureType(to: CisbError.self)
            .eraseToAnyPublisher()

        return response
    }
}
