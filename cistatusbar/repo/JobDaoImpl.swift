import Cocoa
import CoreData
import Foundation
import Combine

class JobDaoImpl: JobDao {
    private let appDelegate: AppDelegate
    private let managedContext: NSManagedObjectContext
    
    init() {
        self.appDelegate = NSApplication.shared.delegate as! AppDelegate
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func getAll() -> AnyPublisher<[Job], CisbError> {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDJobInfo")
        
        do {
            guard let cdJobs: [CDJobInfo] = try managedContext.fetch(fetchRequest) as? [CDJobInfo] else {
                return Just([])
                    .mapError { error in CisbError() }
                    .eraseToAnyPublisher()
            }

            let jobs = cdJobs.compactMap { domainFrom($0) }
            
            return Just(jobs)
                .mapError { error in CisbError() }
                .eraseToAnyPublisher()
            
        } catch _ as NSError {
            return Just([])
                .mapError { error in CisbError() }
                .eraseToAnyPublisher()
        }
    }
    
    func create(job: Job) -> AnyPublisher<Bool, CisbError> {
        guard let url = URL(string: job.url) else {
            return Fail(error: CisbError()).eraseToAnyPublisher()
        }

        let entity = NSEntityDescription.entity(forEntityName: "CDJobInfo", in: managedContext)!
        let cdJob = NSManagedObject(entity: entity, insertInto: managedContext)
        let id = UUID()
        let apiType = job.apiType.rawValue
        cdJob.setValue(id, forKey: "id")
        cdJob.setValue(url, forKey: "url")
        cdJob.setValue(job.name, forKey: "name")
        cdJob.setValue(apiType, forKey: "api_type")
    
        do {
            try managedContext.save()
            return Just(true)
                .mapError { error in CisbError()}
                .eraseToAnyPublisher()
        } catch {
            return Just(false)
                .mapError { error in CisbError()}
                .eraseToAnyPublisher()
        }
    }
    
    func update(job: Job) -> AnyPublisher<Bool, CisbError> {
        guard let id = job.id,
              let url = URL(string: job.url) else {
            return Fail(error: CisbError()).eraseToAnyPublisher()
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDJobInfo")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let cdJobs: [CDJobInfo] = try managedContext.fetch(fetchRequest) as? [CDJobInfo],
                  cdJobs.count > 0 else {
                return Fail(error: CisbError()).eraseToAnyPublisher()
            }

            let cdJob = cdJobs[0]
        
            cdJob.setValue(id, forKey: "id")
            cdJob.setValue(url, forKey: "url")
            cdJob.setValue(job.name, forKey: "name")
            cdJob.setValue(job.apiType.rawValue, forKey: "api_type")
        
            try managedContext.save()
            
            return Just(true)
                .mapError { error in CisbError()}
                .eraseToAnyPublisher()
        } catch _ as NSError {
            return Fail(error: CisbError()).eraseToAnyPublisher()
        }
    }
    
    func delete(id: UUID) -> AnyPublisher<Bool, CisbError> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDJobInfo")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.managedContext.execute(deleteRequest)
            try self.managedContext.save()
            return Just(true)
                .mapError { error in CisbError()}
                .eraseToAnyPublisher()
        } catch {
            return Just(false)
                .mapError { error in CisbError()}
                .eraseToAnyPublisher()
        }
    }
    

    private func domainFrom(_ cdJob: CDJobInfo) -> Job? {
        guard
            let id = cdJob.id,
            let name = cdJob.name,
            let url = cdJob.url?.absoluteString,
            let apiTypeString = cdJob.api_type,
            let apiType = ApiType(rawValue: apiTypeString) else {
                return nil
            }
        
        return Job(id: id,
                       name: name,
                       url: url,
                       apiType: apiType)
    }
}
