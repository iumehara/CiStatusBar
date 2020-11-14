import SwiftUI

struct JobInfoDetail: View {
    @EnvironmentObject private var viewModel: PreferencesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 0) {
                Text("name:")
                    .padding(10.0)
                    .frame(width: 100, alignment: .leading)
                TextField("name", text: $viewModel.currentJobInfo.name)
                    .padding(10.0)
                    .frame(width: 600, alignment: .leading)
            }
            
            HStack(alignment: .center, spacing: 0) {
                Text("url:")
                    .padding(10.0)
                    .frame(width: 100, alignment: .leading)
                TextField("url", text: $viewModel.currentJobInfo.url)
                    .padding(10.0)
                    .frame(width: 600, alignment: .leading)
            }
            
            Button(action: self.testClicked) { Text("Test Connection") }
                .padding(10)
                .padding(.leading, 100)
                
                
            Button(action: self.saveClicked) { Text("Save") }
                .padding(10)
                .padding(.leading, 100)
        }
        .frame(width: 700)
    }
    
    private func testClicked() {
        self.viewModel.testConnection()
    }
    
    private func saveClicked() {
        print("add clicked")
    }

}

struct JobInfoDetail_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PreferencesViewModel(jobInfoRepo: JobInfoRepoImpl(jobInfoDao: JobInfoDaoImpl()))
        viewModel.onAppear()
        return JobInfoDetail().environmentObject(viewModel)
    }
}
