//
//  FoodEntry.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 07/01/26.
//

import Foundation

struct FoodEntry {
    let id: UUID
    var foodName: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date
    
    init(id: UUID = UUID(), foodName: String, calories: Double, protein: Double, carbs: Double, fat: Double, date: Date = Date()) {
        self.id = id
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
    }
}
