//
//  CoreDataManager.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import Foundation
import CoreData

// MARK: - Core Data Entity Definition
/*
 
 Entity Name: HealthDataEntity
 
 Attributes:
 - id: UUID (Optional: NO)
 - date: Date (Optional: NO)
 - stepCount: Double (Optional: NO, Default: 0)
 - activeEnergy: Double (Optional: NO, Default: 0)
 - createdAt: Date (Optional: NO)
 - updatedAt: Date (Optional: NO)
 
 Indexes:
 - Create compound index on "date" for faster queries
 
 Constraints:
 - date should be unique
 
 
 ===================================
 NEW ENTITY: FoodEntity
 ===================================
 
 Entity Name: FoodEntity
 
 Attributes:
 - id: UUID (Optional: NO)
 - foodName: String (Optional: NO)
 - calories: Double (Optional: NO)
 - protein: Double (Optional: NO)
 - carbs: Double (Optional: NO)
 - fat: Double (Optional: NO)
 - date: Date (Optional: NO)
 - createdAt: Date (Optional: NO)
 - updatedAt: Date (Optional: NO)
 
 Indexes:
 - Create compound index on "date" for faster queries
 */

// MARK: - Core Data Stack Manager
class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TMM_Mini")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            print("CoreData: Persistent store loaded")
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData: Context saved successfully")
            } catch {
                print("CoreData: Error saving context: \(error)")
            }
        }
    }
}

// MARK: - HealthData Repository Protocol
protocol HealthDataRepositoryProtocol {
    func saveHealthData(date: Date, stepCount: Double, activeEnergy: Double)
    func fetchHealthData(for date: Date) -> HealthData?
    func fetchHealthDataRange(from startDate: Date, to endDate: Date) -> [HealthData]
    func fetchLast30Days() -> [HealthData]
    func deleteOldData(olderThan days: Int)
}

// MARK: - HealthData Repository Implementation
class HealthDataRepository: HealthDataRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - Save Health Data
    func saveHealthData(date: Date, stepCount: Double, activeEnergy: Double) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Fetch or create entity
        let entity = fetchOrCreateEntity(for: startOfDay)
        
        // Update values
        entity.stepCount = stepCount
        entity.activeEnergy = activeEnergy
        entity.updatedAt = Date()
        
        // Save
        CoreDataManager.shared.saveContext()
        
        print("CoreData: Saved data for \(startOfDay.toString(format: "MMM d")) - Steps: \(stepCount), Calories: \(activeEnergy)")
    }
    
    // MARK: - Fetch Health Data for Specific Date
    func fetchHealthData(for date: Date) -> HealthData? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let fetchRequest: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", startOfDay as NSDate)
        fetchRequest.fetchLimit = 1
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                return entity.toHealthData()
            }
        } catch {
            print("CoreData: Fetch error for date \(startOfDay): \(error)")
        }
        
        return nil
    }
    
    // MARK: - Fetch Health Data Range
    func fetchHealthDataRange(from startDate: Date, to endDate: Date) -> [HealthData] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        
        let fetchRequest: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toHealthData() }
        } catch {
            print("CoreData: Fetch range error: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Last 30 Days
    func fetchLast30Days() -> [HealthData] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -29, to: endDate) else {
            return []
        }
        
        return fetchHealthDataRange(from: startDate, to: endDate)
    }
    
    // MARK: - Delete Old Data
    func deleteOldData(olderThan days: Int) {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HealthDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date < %@", cutoffDate as NSDate)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            CoreDataManager.shared.saveContext()
            print("CoreData: Deleted data older than \(days) days")
        } catch {
            print("CoreData: Delete error: \(error)")
        }
    }
    
    // MARK: - Private Helper: Fetch or Create Entity
    private func fetchOrCreateEntity(for date: Date) -> HealthDataEntity {
        let fetchRequest: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", date as NSDate)
        fetchRequest.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(fetchRequest).first {
                return existing
            }
        } catch {
            print("CoreData: Fetch error: \(error)")
        }
        
        // Create new entity
        let entity = HealthDataEntity(context: context)
        entity.id = UUID()
        entity.date = date
        entity.stepCount = 0
        entity.activeEnergy = 0
        entity.createdAt = Date()
        entity.updatedAt = Date()
        
        return entity
    }
}

// MARK: - HealthDataEntity Extension
extension HealthDataEntity {
    
    func toHealthData() -> HealthData {
        return HealthData(
            stepCount: self.stepCount,
            activeEnergy: self.activeEnergy,
            date: self.date ?? Date()
        )
    }
}


// MARK: - ============== FOOD ENTRY REPOSITORY ==============

// MARK: - Food Entry Repository Protocol
protocol FoodEntryRepositoryProtocol {
    func saveFoodEntry(foodEntry: FoodEntry)
    func updateFoodEntry(foodEntry: FoodEntry)
    func fetchAllFoodEntries() -> [FoodEntry]
    func fetchFoodEntries(for date: Date) -> [FoodEntry]
    func deleteFoodEntry(id: UUID)
    func fetchGroupedFoodEntries() -> [String: [FoodEntry]]
}

// MARK: - Food Entry Repository Implementation
class FoodEntryRepository: FoodEntryRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - Save Food Entry
    func saveFoodEntry(foodEntry: FoodEntry) {
        let entity = FoodEntity(context: context)
        entity.id = foodEntry.id
        entity.foodName = foodEntry.foodName
        entity.calories = foodEntry.calories
        entity.protein = foodEntry.protein
        entity.carbs = foodEntry.carbs
        entity.fat = foodEntry.fat
        entity.date = foodEntry.date
        entity.createdAt = Date()
        entity.updatedAt = Date()
        
        CoreDataManager.shared.saveContext()
        print("CoreData: Saved food entry - \(foodEntry.foodName)")
    }
    
    // MARK: - Update Food Entry
    func updateFoodEntry(foodEntry: FoodEntry) {
        let fetchRequest: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", foodEntry.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                entity.foodName = foodEntry.foodName
                entity.calories = foodEntry.calories
                entity.protein = foodEntry.protein
                entity.carbs = foodEntry.carbs
                entity.fat = foodEntry.fat
                entity.date = foodEntry.date
                entity.updatedAt = Date()
                
                CoreDataManager.shared.saveContext()
                print("CoreData: Updated food entry - \(foodEntry.foodName)")
            }
        } catch {
            print("CoreData: Update error: \(error)")
        }
    }
    
    // MARK: - Fetch All Food Entries
    func fetchAllFoodEntries() -> [FoodEntry] {
        let fetchRequest: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toFoodEntry() }
        } catch {
            print("CoreData: Fetch all error: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Food Entries for Specific Date
    func fetchFoodEntries(for date: Date) -> [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let fetchRequest: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toFoodEntry() }
        } catch {
            print("CoreData: Fetch for date error: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Food Entry
    func deleteFoodEntry(id: UUID) {
        let fetchRequest: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                context.delete(entity)
                CoreDataManager.shared.saveContext()
                print("CoreData: Deleted food entry")
            }
        } catch {
            print("CoreData: Delete error: \(error)")
        }
    }
    
    // MARK: - Fetch Grouped Food Entries (by Date)
    func fetchGroupedFoodEntries() -> [String: [FoodEntry]] {
        let allEntries = fetchAllFoodEntries()
        var grouped: [String: [FoodEntry]] = [:]
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        for entry in allEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            
            var sectionTitle: String
            if calendar.isDate(entryDate, inSameDayAs: today) {
                sectionTitle = "Today"
            } else if calendar.isDate(entryDate, inSameDayAs: yesterday) {
                sectionTitle = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM"
                sectionTitle = formatter.string(from: entryDate)
            }
            
            if grouped[sectionTitle] == nil {
                grouped[sectionTitle] = []
            }
            grouped[sectionTitle]?.append(entry)
        }
        
        return grouped
    }
}

// MARK: - FoodEntity Extension
extension FoodEntity {
    
    func toFoodEntry() -> FoodEntry {
        return FoodEntry(
            id: self.id ?? UUID(),
            foodName: self.foodName ?? "",
            calories: self.calories,
            protein: self.protein,
            carbs: self.carbs,
            fat: self.fat,
            date: self.date ?? Date()
        )
    }
}

// MARK: - Date Extension Helper
extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
