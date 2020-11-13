import Foundation
import Combine

final class PreferencesViewModel: ObservableObject {
    @Published var jobInfos: [JobInfo] = []
    @Published var currentJobInfo: JobInfo = JobInfo(id: 0,
                                                     name: "",
                                                     url: "",
                                                     apiType: .gitHubV3Workflow)
    
    private var jobInfoRepo: JobInfoRepo
    private var disposables = Set<AnyCancellable>()
    
    init(jobInfoRepo: JobInfoRepo) {
        self.jobInfoRepo = jobInfoRepo
    }

    func onAppear() {
        self.jobInfoRepo.getAll()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {value in
                if value == .failure(CisbError()) {
                    self.jobInfos = []
                }
            }, receiveValue: { value in
                self.jobInfos = value
                if (value.count > 0) {
                    self.currentJobInfo = value[0]
                }
            })
            .store(in: &disposables)
    }
    
    func jobInfoSelected(_ jobInfo: JobInfo) {
        self.currentJobInfo = jobInfo
    }
        
    func testConnection() {
        print("testing connection for: ", currentJobInfo.name)
    }
    
    func saveJobInfo() {
        print("--save info", currentJobInfo.name)
    }
}
