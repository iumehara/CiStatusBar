import SwiftUI

struct JobInfoList: View {
    @EnvironmentObject private var viewModel: PreferencesViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            List {
                ForEach(viewModel.jobInfos) { jobInfo in
                    Button(action: { self.jobClicked(jobInfo) }) {
                        Text(viewModel.currentJobInfo.id == jobInfo.id ? viewModel.currentJobInfo.name : jobInfo.name)
                    }
                    .buttonStyle(ListButtonStyle(isSelected: viewModel.currentJobInfo.id == jobInfo.id))
                }
            }

            HStack(alignment: .bottom, spacing: 0) {
                Button(action: self.addClicked) { Text("+") }
                    .frame(width: 30)
                Button(action: self.deleteClicked) { Text("-") }
                    .frame(width: 30)
                Spacer()
                    .frame(width: 60)
            }
        }
        .frame(width: 120)
    }
    
    private func addClicked() {
        viewModel.createJobInfo()
    }

    private func deleteClicked() {
        viewModel.deleteJobInfo()
    }
    
    private func jobClicked(_ jobInfo: JobInfo) {
        viewModel.jobInfoSelected(jobInfo)
    }

    struct ListButtonStyle: ButtonStyle {
        private var isSelected: Bool
        
        init(isSelected: Bool) {
            self.isSelected = isSelected
        }
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .font(.headline)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .contentShape(Rectangle())
                .foregroundColor(isSelected ? Color.white : Color.black)
                .listRowBackground(isSelected ? Color.blue : Color.white)
        }
    }
}

struct JobInfoList_Previews: PreviewProvider {
    static var previews: some View {
        let jobInfoDao = JobInfoDaoStub()
        let jobHttpClient = JobHttpClientImpl()
        let jobRepo = JobsRepoImpl(jobInfoDao: jobInfoDao, jobHttpClient: jobHttpClient)
        let jobInfoRepo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        let viewModel = PreferencesViewModel(jobInfoRepo: jobInfoRepo,
                                             jobRepo: jobRepo)
        viewModel.onAppear()
        return JobInfoList().environmentObject(viewModel)
    }
}
