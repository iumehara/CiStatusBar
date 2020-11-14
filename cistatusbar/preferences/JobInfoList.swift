import SwiftUI

struct JobInfoList: View {
    @EnvironmentObject private var viewModel: PreferencesViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            List {
                ForEach(viewModel.jobInfos) { jobInfo in
                    Button(action: { self.jobClicked(jobInfo) }) {
                        Text(jobInfo.name)
                    }
                    .buttonStyle(ListButtonStyle(isSelected: viewModel.currentJobInfo.id == jobInfo.id))
                }
            }
            .frame(width: 120)

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
        self.viewModel.saveJobInfo()
    }

    private func deleteClicked() {
        print("delete clicked")
    }
    
    private func jobClicked(_ jobInfo: JobInfo) {
        self.viewModel.jobInfoSelected(jobInfo)
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
                .foregroundColor(Color.black)
                .listRowBackground(isSelected ? Color.gray : Color.white)
        }
    }
}


struct JobInfoList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PreferencesViewModel(jobInfoRepo: JobInfoRepoImpl(jobInfoDao: JobInfoDaoImpl()))
        viewModel.onAppear()
        return JobInfoList().environmentObject(viewModel)
    }
}
