import Foundation
import Combine

enum ConnectionStatus {
    case none
    case connecting
    case valid
    case invalid
}

final class PreferencesViewModel: ObservableObject {
    @Published var jobInfos: [JobInfo] = []
    @Published var currentJobInfo: JobInfo = JobInfo.empty()
    @Published var connectionStatus = ConnectionStatus.none
    @Published var isAddButtonDisabled = false

    private var jobInfoRepo: JobInfoRepo
    private var jobRepo: JobsRepo
    private var disposables = Set<AnyCancellable>()
    
    init(jobInfoRepo: JobInfoRepo,
         jobRepo: JobsRepo) {
        self.jobInfoRepo = jobInfoRepo
        self.jobRepo = jobRepo
    }

    func onAppear() {
        fetchData()
    }
    
    func jobInfoSelected(_ jobInfo: JobInfo) {
        self.currentJobInfo = jobInfo
        self.connectionStatus = .none
    }
        
    func testConnection() {
        self.connectionStatus = .connecting
        self.jobRepo.get(jobInfo: currentJobInfo)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { value in
                    if value == .finished {
                        self.connectionStatus = .valid
                    } else {
                        self.connectionStatus = .invalid
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &disposables)
    }

    func createJobInfo() {
        let count = jobInfos.count + 1
        let newJobInfo = JobInfo(id: nil,
                                 name: "job \(count)",
                                 url: "",
                                 apiType: .gitHubV3Workflow)
        self.jobInfos.append(newJobInfo)
        self.isAddButtonDisabled = true
        self.currentJobInfo = newJobInfo
    }
    
    func deleteJobInfo() {
        guard let jobInfoId = currentJobInfo.id else {
            self.isAddButtonDisabled = false
            jobInfos.removeAll(where: {jobInfo in
                jobInfo.id == nil
            })
            return
        }
        self.jobInfoRepo.delete(id: jobInfoId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in self.reset() },
                  receiveValue: { _ in })
            .store(in: &disposables)
    }
    
    func reset() {
        fetchData()
    }
    
    func saveJobInfo() {
        if currentJobInfo.id == nil {
            self.isAddButtonDisabled = false
        }

        self.jobInfoRepo.save(jobInfo: currentJobInfo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                    self.reset() },
                  receiveValue: { _ in })
            .store(in: &disposables)
    }
    
    func isCurrent(_ jobInfo: JobInfo) -> Bool {
        return self.currentJobInfo.id == jobInfo.id
    }
    
    private func fetchData() {
        self.jobInfoRepo.getAll()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { value in
                    self.connectionStatus = .none
                    if value == .failure(CisbError()) {
                        self.jobInfos = []
                    }
                },
                receiveValue: { value in
                    self.jobInfos = value
                    if (value.count == 0) {
                        self.createJobInfo()
                    } else {
                        self.currentJobInfo = value[0]
                    }
                }
            )
            .store(in: &disposables)
    }
}
