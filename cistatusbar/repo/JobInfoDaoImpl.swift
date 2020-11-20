import Cocoa
import CoreData
import Foundation
import Combine

class JobInfoDaoImpl: JobInfoDao {
    private let appDelegate: AppDelegate
    private let managedContext: NSManagedObjectContext
    
    init() {
        self.appDelegate = NSApplication.shared.delegate as! AppDelegate
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func getAll() -> AnyPublisher<[JobInfo], CisbError> {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDJobInfo")
        
        do {
            guard let cdJobInfos: [CDJobInfo] = try managedContext.fetch(fetchRequest) as? [CDJobInfo] else {
                return Just([])
                    .mapError { error in CisbError() }
                    .eraseToAnyPublisher()
            }

            let jobs = cdJobInfos.compactMap { cdJobInfo in
                return domainFrom(cdJobInfo)
            }
            
            return Just(jobs)
                .mapError { error in CisbError() }
                .eraseToAnyPublisher()
            
        } catch _ as NSError {
            return Just([])
                .mapError { error in CisbError() }
                .eraseToAnyPublisher()
        }
    }
    
    func create(jobInfo: JobInfo) -> AnyPublisher<Bool, CisbError> {
        guard let url = URL(string: jobInfo.url) else {
            return Fail(error: CisbError()).eraseToAnyPublisher()
        }

        let entity = NSEntityDescription.entity(forEntityName: "CDJobInfo", in: managedContext)!
        let cdJobInfo = NSManagedObject(entity: entity, insertInto: managedContext)
        let id = UUID(uuidString: jobInfo.id)
        let apiType = jobInfo.apiType.rawValue
        cdJobInfo.setValue(id, forKey: "id")
        cdJobInfo.setValue(url, forKey: "url")
        cdJobInfo.setValue(jobInfo.name, forKey: "name")
        cdJobInfo.setValue(apiType, forKey: "api_type")
    
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
    

    private func domainFrom(_ cdJobInfo: CDJobInfo) -> JobInfo? {
        guard
            let id = cdJobInfo.id?.uuidString as? String,
            let name = cdJobInfo.name as? String,
            let url = cdJobInfo.url?.absoluteString as? String,
            let apiTypeString = cdJobInfo.api_type as? String,
            let apiType = ApiType(rawValue: apiTypeString) else {
                return nil
            }
        
        return JobInfo(id: id,
                       name: name,
                       url: url,
                       apiType: apiType)
    }
}
