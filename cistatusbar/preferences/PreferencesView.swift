import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var viewModel: PreferencesViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                List(viewModel.jobInfos) { jobInfo in
                    Button(action: { self.jobClicked(jobInfo) }) {
                        Text(jobInfo.name)
                    }
                    .frame(width: 80, height: 30)
                    .contentShape(Rectangle())
                    .border(Color.gray)
                }
                .frame(width: 100)
                .environment(\.defaultMinListRowHeight, 50)

                HStack(alignment: .center, spacing: 0) {
                    Button(action: self.addClicked) { Text("+") }
                        .frame(width: 30)
                    Button(action: self.deleteClicked) { Text("-") }
                        .frame(width: 30)
                    Spacer()
                        .frame(width: 40)
                }
                .frame(width: 100)
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    Text("name:")
                        .padding(10.0)
                        .frame(width: 100, alignment: .leading)
                    TextField("name", text: $viewModel.currentJobInfo.name)
                        .padding(10.0)
                        .frame(width: 500, alignment: .leading)
                }
                HStack(alignment: .center, spacing: 0) {
                    Text("url:")
                        .padding(10.0)
                        .frame(width: 100, alignment: .leading)
                    TextField("url", text: $viewModel.currentJobInfo.url)
                        .padding(10.0)
                        .frame(width: 500, alignment: .leading)
                }
                Button(action: self.testClicked) { Text("Test Connection") }
                    .frame(width: 30)
                
                Button(action: self.saveClicked) { Text("Save") }
                    .frame(width: 30)
            }
            .frame(width: 600)
        }
        .frame(alignment: .trailing)
        .onAppear(perform: viewModel.onAppear)
    }
    
    private func addClicked() {
        print("add clicked")
    }
    
    private func deleteClicked() {
        print("delete clicked")
    }
    
    private func jobClicked(_ jobInfo: JobInfo) {
        self.viewModel.jobInfoSelected(jobInfo)
    }
    
    private func testClicked() {
        self.viewModel.testConnection()
    }
    
    private func saveClicked() {
        self.viewModel.saveJobInfo()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let preferencesViewModel = PreferencesViewModel(jobInfoRepo: JobInfoRepoImpl(jobInfoDao: JobInfoDaoImpl()))
        return PreferencesView()
            .environmentObject(preferencesViewModel)
    }
}
