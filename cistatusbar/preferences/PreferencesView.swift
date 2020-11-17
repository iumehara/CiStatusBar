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
        let jobInfoDao = JobInfoDaoImpl()
        let jobHttpClient = JobHttpClientImpl()
        let jobRepo = JobsRepoImpl(jobInfoDao: jobInfoDao, jobHttpClient: jobHttpClient)
        let jobInfoRepo = JobInfoRepoImpl(jobInfoDao: jobInfoDao)
        let viewModel = PreferencesViewModel(jobInfoRepo: jobInfoRepo,
                                            jobRepo: jobRepo)
        return PreferencesView()
            .environmentObject(viewModel)
    }
}