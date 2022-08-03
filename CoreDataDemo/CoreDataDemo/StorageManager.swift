//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Владимир Макаров on 10.04.2022.
//

import CoreData


class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
//    инициализация базы данных
    private let persistentContainer: NSPersistentContainer = {
//        инициализация экземпляра класса NSPersistentContainer. При помощи параметра name в значение параметра передаем название имени файла, который отвечает за модели данных для работы с CoreData
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
//    создаем экземпляр класса NSManagedObjectContext. Объектное пространство для управления и отслеживания изменений в управляемых объектах.
    private let viewContext: NSManagedObjectContext
    
//    Инициализация свойства viewContext с помощью синглтона
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - Public Methods
//    В случае, если хотим, что бы данные возвращались при положительном стечении обстоятельств, необходимо воспользоваться типом Result. Это перечесление, которое позволяет вовращать данные асинхронно. Т е можно вернуть сами данные и ошибку.
    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        
// NSFetchRequest запрос на выборку данных. Описание критериев поиска, используемых для извлечения данных из постоянного хранилища.
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
//         fetch - Возвращает массив элементов указанного типа, соответствующих критериям запроса на выборку. Этот метод извлекает объекты из контекста и постоянных хранилищ, которые вы связываете с координатором постоянного хранилища контекста. Метод регистрирует любые объекты, которые он извлекает из хранилища, с контекстом.
            let tasks = try viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // Save data
    
    func save(_ taskName: String, completion: (Task) -> Void) {
        let task = Task(context: viewContext)
        task.name = taskName
        
        completion(task)
        saveContext()
    }
    
    func edit(_ task: Task, newName: String) {
        task.name = newName
        saveContext()
    }
    
    func delete(_ task: Task) {
        viewContext.delete(task)
        saveContext()
    }

    // MARK: - Core Data Saving support
//    Этот метод сохраняет изменения контекста в PersistentContainer т е в постоянную память
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
