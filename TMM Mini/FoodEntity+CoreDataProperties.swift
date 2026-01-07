//
//  FoodEntity+CoreDataProperties.swift
//  
//
//  Created by Brijesh Ajudia on 07/01/26.
//
//

import Foundation
import CoreData


extension FoodEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodEntity> {
        return NSFetchRequest<FoodEntity>(entityName: "FoodEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var foodName: String?
    @NSManaged public var calories: Double
    @NSManaged public var protein: Double
    @NSManaged public var carbs: Double
    @NSManaged public var fat: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}
