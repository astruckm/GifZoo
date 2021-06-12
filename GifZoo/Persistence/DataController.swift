//
//  DataController.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/19/21.
//

import Foundation
import CoreData

class DataController {
    var gifRefs: [NSManagedObject] = []
    var persistentContainer: NSPersistentContainer
    
    init(completion: @escaping () -> Void) {
        persistentContainer = NSPersistentContainer(name: "SavedGifsModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: ", error)
            }
            completion()
        }
    }
    
    func saveGifRef(withTitle title: String, url: URL, dateAdded: Date) {
        guard let entity = NSEntityDescription.entity(forEntityName: "GifRef", in: persistentContainer.viewContext) else { return }
        let context = persistentContainer.viewContext
        let gifRef = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
        gifRef.setValue(title, forKey: "title")
        gifRef.setValue(url, forKey: "url")
        gifRef.setValue(dateAdded as NSDate, forKey: "dateAdded")
        do {
            try context.save()
            gifRefs.append(gifRef)
        } catch let error as NSError {
            print("Enable to save to managed object context: \(error.localizedDescription)\n\(error.userInfo)")
        }
    }
    
    func loadGifRef() -> [NSManagedObject]? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GifRef")
        do {
            let gifRefs = try context.fetch(fetchRequest)
            return gifRefs
        } catch let error as NSError {
            print("Enable to fetch gif refs: \(error.localizedDescription)\n\(error.userInfo)")
            return nil
        }
    }
}
