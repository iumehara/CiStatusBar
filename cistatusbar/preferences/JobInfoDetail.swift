import SwiftUI

struct JobInfoDetail: View {
    @EnvironmentObject private var viewModel: PreferencesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 0) {
                Text("name:")
                    .padding(10.0)
                    .frame(width: 60, alignment: .leading)
                TextField("name", text: $viewModel.currentJobInfo.name)
                    .padding(10.0)
                    .frame(width: 200, alignment: .leading)
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 0) {
                Picker(selection: $viewModel.currentJobInfo.apiType,
                       label: Text("api:").padding(10.0).frame(width: 60, alignment: .leading)) {
                    ForEach(ApiType.allCases) { apiType in
                        Text(apiType.description).tag(apiType)
                    }
                }
                .frame(width: 300)
                Spacer()
            }

            HStack(alignment: .center, spacing: 0) {
                Text("url:")
                    .padding(10.0)
                    .frame(width: 60, alignment: .leading)
                TextField("url", text: $viewModel.currentJobInfo.url)
                    .padding(10.0)
                    .frame(width: 600, alignment: .leading)
                Spacer()
            }

            if viewModel.jobInfos.count > 0 {
                VStack(alignment: .leading) {
                    Button(action: self.testClicked) { Text("Test Connection") }
                        .padding(.leading, 70)
                        .padding(.top, 10)

                    switch viewModel.connectionStatus {
                    case .connecting:
                        Text("connecing...")
                            .padding(.leading, 70)
                    case .valid:
                        Text("valid")
                            .padding(.leading, 70)
                            .foregroundColor(.green)
                    case .invalid:
                        Text("invalid")
                            .padding(.leading, 70)
                            .foregroundColor(.red)
                    default:
                        Text("click to test connection")
                            .padding(.leading, 70)
                    }
                }

                HStack(alignment: .center, spacing: 0) {
                    Button(action: self.cancelClicked) { Text("Cancel") }
                        .padding(10)
                    Button(action: self.saveClicked) { Text("Save") }
                        .padding(10)
                }
                .padding(.leading, 60)
            }
        }
        .frame(width: 700)
    }
    
    private func testClicked() {
        self.viewModel.testConnection()
    }
    
    private func cancelClicked() {
        self.viewModel.reset()
    }
    
    private func saveClicked() {
        self.viewModel.saveJobInfo()
    }
}

struct JobInfoDetail_Previews: PreviewProvider {
    static var previews: some View {
        let jobInfoDao = JobInfoDaoStub()
        let jobHttpClient = JobHttpClientImpl()
        let jobRepo = JobsRepoImpl(jobInfoDao: jobInfoDao, jobHttpClient: jobHttpClient)
        let jobInfoRepo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        let viewModel = PreferencesViewModel(jobInfoRepo: jobInfoRepo,
                                            jobRepo: jobRepo)
        viewModel.onAppear()
        return JobInfoDetail().environmentObject(viewModel)
    }
}
