import SwiftUI

struct JobList: View {
    @EnvironmentObject var viewModel: PreferencesViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(viewModel.jobs) { job in
                    HStack {
                        Text(viewModel.isCurrent(job) ? viewModel.currentJob.name : job.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .foregroundColor(viewModel.isCurrent(job) ? CIColor.white : CIColor.text)
                    .listRowBackground(viewModel.isCurrent(job) ? CIColor.highlight : CIColor.white)
                    .frame(width: 200, height: 20, alignment: .leading)
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    .onTapGesture(perform: {
                        self.jobClicked(job)
                    })
                    .accessibilityIdentifier(viewModel.isCurrent(job) ? viewModel.currentJob.name : job.name)
                }
            }
            .padding(.horizontal, -8)
            .listStyle(PlainListStyle())

            HStack(alignment: .bottom, spacing: 0) {
                Button(action: self.addClicked) {Text("+")}
                    .frame(width: 30)
                    .disabled(viewModel.isAddButtonDisabled)
                    .accessibilityIdentifier("add job")
                Button(action: self.deleteClicked) { Text("-") }
                    .frame(width: 30)
                    .accessibilityIdentifier("remove job")
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 200)
    }
    
    private func addClicked() {
        viewModel.createJob()
    }

    private func deleteClicked() {
        viewModel.deleteJob()
    }
    
    private func jobClicked(_ job: Job) {
        viewModel.jobSelected(job)
    }
}

struct JobList_Previews: PreviewProvider {
    static var previews: some View {
        let jobDao = JobDaoImpl()
        let runHttpClient = RunHttpClientImpl()
        let runRepo = RunRepoImpl(jobDao: jobDao, runHttpClient: runHttpClient)
        let jobRepo = JobRepoImpl(jobDao: jobDao)
        let viewModel = PreferencesViewModel(jobRepo: jobRepo,
                                            runRepo: runRepo)

        viewModel.onAppear()
        return JobList().environmentObject(viewModel)
    }
}
