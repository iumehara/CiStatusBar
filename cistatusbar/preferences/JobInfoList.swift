import SwiftUI
import Combine

struct JobInfoList: View {
    @EnvironmentObject var viewModel: PreferencesViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(viewModel.jobInfos) { jobInfo in
                    HStack {
                        Text(viewModel.isCurrent(jobInfo) ? viewModel.currentJobInfo.name : jobInfo.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .foregroundColor(viewModel.isCurrent(jobInfo) ? .white : .black)
                    .listRowBackground(viewModel.isCurrent(jobInfo) ? Color.blue : Color.white)
                    .frame(width: 200, height: 20, alignment: .leading)
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    .onTapGesture(perform: {
                        self.jobClicked(jobInfo)
                    })
                }
            }
            .padding(.horizontal, -8)
            .listStyle(PlainListStyle())

            HStack(alignment: .bottom, spacing: 0) {
                Button(action: self.addClicked) {Text("+")}
                    .frame(width: 30)
                    .disabled(viewModel.isAddButtonDisabled)
                Button(action: self.deleteClicked) { Text("-") }
                    .frame(width: 30)
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 200)
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
}

struct JobInfoList_Previews: PreviewProvider {
    static var previews: some View {
        let jobInfoDao = JobInfoDaoImpl()
        let jobHttpClient = JobHttpClientImpl()
        let jobRepo = JobsRepoImpl(jobInfoDao: jobInfoDao, jobHttpClient: jobHttpClient)
        let jobInfoRepo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        let viewModel = PreferencesViewModel(jobInfoRepo: jobInfoRepo,
                                            jobRepo: jobRepo)

        viewModel.onAppear()
        return JobInfoList().environmentObject(viewModel)
    }
}
