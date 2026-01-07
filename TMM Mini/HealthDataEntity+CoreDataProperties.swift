//
//  HealthDataEntity+CoreDataProperties.swift
//  
//
//  Created by Brijesh Ajudia on 06/01/26.
//
//

import Foundation
import CoreData


extension HealthDataEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HealthDataEntity> {
        return NSFetchRequest<HealthDataEntity>(entityName: "HealthDataEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var stepCount: Double
    @NSManaged public var activeEnergy: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}
