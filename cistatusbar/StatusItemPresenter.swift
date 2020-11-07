import SwiftUI
import Combine

class StatusItemPresenter: NSObject {
    private var repo: JobsRepo
    private var button: NSStatusBarButton!
    private var disposables = Set<AnyCancellable>()
    private var jobCount: Int = 0
    private var jobs: [Job] = []
    
    init(repo: JobsRepo,
         button: NSStatusBarButton) {
        self.repo = repo
        self.button = button
    }
    
    func present() {
        button.target = self
        button.action = #selector(self.displaySomething)
        
        self.repo.getAll()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { value in
                    switch value {
                    case .failure:
                        self.button.displayUnavailable()
                    case .finished:
                        break
                    }
                },
                receiveValue:  { jobs in
                    self.jobCount = jobs.count
                    self.jobs = jobs
                    self.updateButton(jobs: jobs)
                })
            .store(in: &disposables)
    }
    
    @objc func displaySomething() {
        print("yoooooo!")
    }
    
    private func updateButton(jobs: [Job]) {
        let successfulJobs = jobs.filter { job in
            job.status == "success"
        }
        
        if (successfulJobs.count == self.jobCount) {
            self.button.displaySuccessful()
        } else {
            self.button.displayFailed()
        }
    }
}

extension NSStatusBarButton {
    func displaySuccessful() {
        self.title = "🟢"
        self.isBordered = false
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
    }

    func displayFailed() {
        self.title = "🔴"
        self.isBordered = false
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
    }
    
    func displayUnavailable() {
        self.title = "⁉️"
        self.isBordered = false
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
    }
}
