import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var viewModel: PreferencesViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            JobInfoList()
            JobInfoDetail()
        }
        .frame(alignment: .trailing)
        .onAppear(perform: viewModel.onAppear)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let preferencesViewModel = PreferencesViewModel(jobInfoRepo: JobInfoRepoImpl(jobInfoDao: JobInfoDaoImpl()))
        return PreferencesView()
            .environmentObject(preferencesViewModel)
    }
}
