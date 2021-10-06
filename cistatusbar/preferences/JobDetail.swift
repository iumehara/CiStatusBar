import SwiftUI

struct JobDetail: View {
    @EnvironmentObject var viewModel: PreferencesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 0) {
                Text("name:")
                    .padding(10.0)
                    .frame(width: 60, alignment: .leading)
                TextField("name", text: $viewModel.currentJob.name)
                    .padding(10.0)
                    .frame(width: 200, alignment: .leading)
                    .accessibilityIdentifier("name")
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 0) {
                Picker(selection: $viewModel.currentJob.apiType,
                       label: Text("api:").padding(.leading, 10).frame(width: 60, alignment: .leading)) {
                    ForEach(ApiType.allCases) { apiType in
                        Text(apiType.details().description).tag(apiType)
                    }
                }
                .frame(width: 300)
                .foregroundColor(CIColor.text)
                Spacer()
            }

            VStack(alignment: .leading) {
                Text("format: \(viewModel.currentJob.apiType.details().format)")
                HStack() {
                    Text("docs:  ")
                    Button(action: {
                        NSWorkspace.shared.open(viewModel.currentJob.apiType.details().apiReference)
                    }) {
                        Text(viewModel.currentJob.apiType.details().apiReference.absoluteString)
                            .underline()
                            .foregroundColor(CIColor.link)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
            }.padding(.leading, 70)
            
            HStack(alignment: .center, spacing: 0) {
                Text("url:")
                    .padding(10.0)
                    .frame(width: 60, alignment: .leading)
                TextField("url", text: $viewModel.currentJob.url)
                    .padding(10.0)
                    .frame(width: 600, alignment: .leading)
                    .accessibilityIdentifier("url")
                Spacer()
            }

            
            if viewModel.jobs.count > 0 {
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
                            .foregroundColor(CIColor.ok)
                    case .invalid:
                        Text("invalid")
                            .padding(.leading, 70)
                            .foregroundColor(CIColor.warning)
                    default:
                        Text("click to test connection")
                            .padding(.leading, 70)
                    }
                }

                HStack(alignment: .center, spacing: 0) {
                    Button(action: self.cancelClicked) { Text("Cancel") }
                        .padding(10)
                    Button(action: self.saveClicked) { Text("Save") }
                        .accessibilityIdentifier("save")
                        .padding(10)
                }
                .padding(.leading, 60)
            }
        }
        .frame(width: 700)
        .background(CIColor.background)
    }
    
    private func testClicked() {
        self.viewModel.testConnection()
    }
    
    private func cancelClicked() {
        self.viewModel.reset()
    }
    
    private func saveClicked() {
        self.viewModel.saveJob()
    }
}

struct JobDetail_Previews: PreviewProvider {
    static var previews: some View {
        let jobDao = JobDaoStub()
        let runHttpClient = RunHttpClientImpl()
        let runRepo = RunRepoImpl(jobDao: jobDao, runHttpClient: runHttpClient)
        let jobRepo = JobRepoImpl(jobDao: jobDao)
        let viewModel = PreferencesViewModel(jobRepo: jobRepo,
                                            runRepo: runRepo)
        viewModel.onAppear()
        return JobDetail().environmentObject(viewModel)
    }
}
