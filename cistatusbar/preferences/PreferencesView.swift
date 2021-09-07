import SwiftUI

struct PreferencesView: View {
    internal let inspection = Inspection<Self>()
    @EnvironmentObject var viewModel: PreferencesViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            JobList()
            JobDetail()
        }
        .frame(alignment: .trailing)
        .onAppear {
            viewModel.onAppear()
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let jobDao = JobDaoImpl()
        let run = RunHttpClientImpl()
        let runRepo = RunRepoImpl(jobDao: jobDao, runHttpClient: run)
        let jobRepo = JobRepoImpl(jobDao: jobDao)
        let viewModel = PreferencesViewModel(jobRepo: jobRepo,
                                            runRepo: runRepo)
        return PreferencesView().environmentObject(viewModel)
    }
}
