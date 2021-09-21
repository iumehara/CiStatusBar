import Foundation
import Combine

enum ConnectionStatus {
    case none
    case connecting
    case valid
    case invalid
}

final class PreferencesViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var currentJob: Job = Job.empty()
    @Published var connectionStatus = ConnectionStatus.none
    @Published var isAddButtonDisabled = false
    
    private var jobRepo: JobRepo
    private var runRepo: RunRepo
    private var disposables = Set<AnyCancellable>()
    
    init(jobRepo: JobRepo,
         runRepo: RunRepo) {
        self.jobRepo = jobRepo
        self.runRepo = runRepo
    }
    
    func onAppear() {
        fetchData()
    }
    
    func jobSelected(_ job: Job) {
        self.currentJob = job
        self.connectionStatus = .none
    }
    
    func testConnection() {
        self.connectionStatus = .connecting
        self.runRepo.get(job: currentJob)
                .receive(on: DispatchQueue.main)
                .sink(
                        receiveCompletion: { [weak self] value in
                            if value == .finished {
                                self?.connectionStatus = .valid
                            } else {
                                self?.connectionStatus = .invalid
                            }
                        },
                        receiveValue: { _ in }
                )
                .store(in: &disposables)
    }
    
    func createJob() {
        let count = jobs.count + 1
        let newJob = Job(id: nil,
                         name: "job \(count)",
                         url: "",
                         apiType: .gitHubV3Workflow)
        self.jobs.append(newJob)
        self.isAddButtonDisabled = true
        self.currentJob = newJob
    }
    
    func deleteJob() {
        guard let jobId = currentJob.id else {
            self.isAddButtonDisabled = false
            jobs.removeAll(where: { job in
                job.id == nil
            })
            return
        }
        self.jobRepo.delete(id: jobId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] value in self?.reset() },
                      receiveValue: { _ in })
                .store(in: &disposables)
    }
    
    func reset() {
        fetchData()
    }
    
    func saveJob() {
        if currentJob.id == nil {
            self.isAddButtonDisabled = false
        }
        
        self.jobRepo.save(job: currentJob)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] value in self?.reset() },
                      receiveValue: { _ in })
                .store(in: &disposables)
    }
    
    func isCurrent(_ job: Job) -> Bool {
        return self.currentJob.id == job.id
    }
    
    private func fetchData() {
        self.jobRepo.getAll()
                .receive(on: DispatchQueue.main)
                .sink(
                        receiveCompletion: { [weak self] value in
                            self?.connectionStatus = .none
                            if value == .failure(CisbError()) {
                                self?.jobs = []
                            }
                        },
                        receiveValue: { [weak self] value in
                            self?.jobs = value
                            if (value.count == 0) {
                                self?.createJob()
                            } else {
                                self?.currentJob = value[0]
                            }
                        }
                )
                .store(in: &disposables)
    }
}
