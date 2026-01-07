//
//  LogMealVC.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 07/01/26.
//

import UIKit

class LogMealVC: BaseVC {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtFoodName: UITextField!
    @IBOutlet weak var lblErrorFoodName: UILabel!
    
    @IBOutlet weak var txtCalories: UITextField!
    @IBOutlet weak var lblErrorCalories: UILabel!
    
    @IBOutlet weak var txtProtein: UITextField!
    @IBOutlet weak var lblErrorProtein: UILabel!
    
    @IBOutlet weak var txtCarbs: UITextField!
    @IBOutlet weak var lblErrorCarbs: UILabel!
    
    @IBOutlet weak var txtFat: UITextField!
    @IBOutlet weak var lblErrorFat: UILabel!
    
    @IBOutlet weak var btnScan: CustomButton!
    
    @IBOutlet weak var btnLogMeal: CustomButton!
    
    var isFoodNameEnable: Bool = false
    
    // MARK: - Food Entry Repository
    private let foodRepository = FoodEntryRepository()
    
    // MARK: - Edit Mode
    var existingFoodEntry: FoodEntry?
    var isEditMode: Bool = false
    
    var onMealLogged: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.setUpUI()
        
        self.lblTitle.text = isEditMode ? "Update Meal" : "Log Meal"
        
        // Set initial button state
        updateButtonState()
        
        // If editing, populate fields
        if let foodEntry = existingFoodEntry {
            populateFields(with: foodEntry)
            updateButtonState()
        }
    }
    
    // MARK: - Setup UI
    func setUpUI() {
        self.txtFoodName.tag = 0
        self.txtFoodName.delegate = self
        self.txtFoodName.tintColor = .text
        self.txtFoodName.keyboardType = .default
        self.txtFoodName.autocapitalizationType = .words
        self.txtFoodName.setLeftPaddingPoints(17.0)
        self.txtFoodName.setAttributesPlaceHolder_Color(placeHolderString: "e.g. Grilled chicken sandwich")
        self.txtFoodName.font = AppFont.font(type: .I_Medium, size: 16)
        self.txtFoodName.keyboardAppearance = .light
        self.txtFoodName.addTarget(self, action: #selector(self.foodNameValidate), for: .editingChanged)
        self.lblErrorFoodName.font = AppFont.font(type: .I_Regular, size: 12)
        Utils.sharedInstance.applyLineSpacing(to: self.lblErrorFoodName, lineSpacing: 2, alignment: .left)
        self.lblErrorFoodName.isHidden = true
        
        self.txtCalories.tag = 1
        self.txtCalories.delegate = self
        self.txtCalories.tintColor = .text
        self.txtCalories.keyboardType = .decimalPad
        self.txtCalories.setLeftPaddingPoints(17.0)
        self.txtCalories.setAttributesPlaceHolder_Color(placeHolderString: "Calories (cal)")
        self.txtCalories.font = AppFont.font(type: .I_Medium, size: 16)
        self.txtCalories.keyboardAppearance = .light
        self.txtCalories.addTarget(self, action: #selector(self.fieldsValidate), for: .editingChanged)
        self.lblErrorCalories.font = AppFont.font(type: .I_Regular, size: 12)
        Utils.sharedInstance.applyLineSpacing(to: self.lblErrorCalories, lineSpacing: 2, alignment: .left)
        self.lblErrorCalories.isHidden = true
        
        self.txtProtein.tag = 2
        self.txtProtein.delegate = self
        self.txtProtein.tintColor = .text
        self.txtProtein.keyboardType = .decimalPad
        self.txtProtein.setLeftPaddingPoints(17.0)
        self.txtProtein.setAttributesPlaceHolder_Color(placeHolderString: "Protein (g)")
        self.txtProtein.font = AppFont.font(type: .I_Medium, size: 16)
        self.txtProtein.keyboardAppearance = .light
        self.txtProtein.addTarget(self, action: #selector(self.fieldsValidate), for: .editingChanged)
        self.lblErrorProtein.font = AppFont.font(type: .I_Regular, size: 12)
        Utils.sharedInstance.applyLineSpacing(to: self.lblErrorProtein, lineSpacing: 2, alignment: .left)
        self.lblErrorProtein.isHidden = true
        
        self.txtCarbs.tag = 3
        self.txtCarbs.delegate = self
        self.txtCarbs.tintColor = .text
        self.txtCarbs.keyboardType = .decimalPad
        self.txtCarbs.setLeftPaddingPoints(17.0)
        self.txtCarbs.setAttributesPlaceHolder_Color(placeHolderString: "Carbs (g)")
        self.txtCarbs.font = AppFont.font(type: .I_Medium, size: 16)
        self.txtCarbs.keyboardAppearance = .light
        self.txtCarbs.addTarget(self, action: #selector(self.fieldsValidate), for: .editingChanged)
        self.lblErrorCarbs.font = AppFont.font(type: .I_Regular, size: 12)
        Utils.sharedInstance.applyLineSpacing(to: self.lblErrorCarbs, lineSpacing: 2, alignment: .left)
        self.lblErrorCarbs.isHidden = true
        
        self.txtFat.tag = 4
        self.txtFat.delegate = self
        self.txtFat.tintColor = .text
        self.txtFat.keyboardType = .decimalPad
        self.txtFat.setLeftPaddingPoints(17.0)
        self.txtFat.setAttributesPlaceHolder_Color(placeHolderString: "Fat (g)")
        self.txtFat.font = AppFont.font(type: .I_Medium, size: 16)
        self.txtFat.keyboardAppearance = .light
        self.txtFat.addTarget(self, action: #selector(self.fieldsValidate), for: .editingChanged)
        self.lblErrorFat.font = AppFont.font(type: .I_Regular, size: 12)
        Utils.sharedInstance.applyLineSpacing(to: self.lblErrorFat, lineSpacing: 2, alignment: .left)
        self.lblErrorFat.isHidden = true
        
        addInputAccessoryForTextFields(textFields: [self.txtFoodName, self.txtCalories, self.txtProtein, self.txtCarbs, self.txtFat], dismissable: true, previousNextable: true)
        
        self.btnScan.lblTitle.font = AppFont.font(type: .I_SemiBold, size: 16)
        self.btnScan.onToggle = { [weak self] _  in
            guard let self = self else { return }
            self.showImageSourceActionSheet(sourceView: self.btnScan!)
        }
        
        self.btnLogMeal.lblTitle.text = isEditMode ? "Update Meal" : "Log Meal"
        self.btnLogMeal.lblTitle.font = AppFont.font(type: .I_Bold, size: 16)
        self.btnLogMeal.onToggle = { [weak self] _  in
            guard let self = self else { return }
            if self.checkFields(showErrorsForEmpty: true) && self.isFoodNameEnable {
                self.btnLogMeal.isUserInteractionEnabled = false
                self.saveFoodData()
            }
        }
    }
    
    // MARK: - Populate Fields for Edit Mode
    func populateFields(with foodEntry: FoodEntry) {
        self.txtFoodName.text = foodEntry.foodName
        self.txtCalories.text = String(format: "%.0f", foodEntry.calories)
        self.txtProtein.text = String(format: "%.1f", foodEntry.protein)
        self.txtCarbs.text = String(format: "%.1f", foodEntry.carbs)
        self.txtFat.text = String(format: "%.1f", foodEntry.fat)
        self.isFoodNameEnable = true
    }
    
    // MARK: - Save Food Data
    func saveFoodData() {
        guard let foodName = txtFoodName.text?.trim(), !foodName.isEmpty,
              let calories = Double(txtCalories.text ?? ""),
              let protein = Double(txtProtein.text ?? ""),
              let carbs = Double(txtCarbs.text ?? ""),
              let fat = Double(txtFat.text ?? "") else {
            self.btnLogMeal.isActive = false
            return
        }
        
        if isEditMode, let existingEntry = existingFoodEntry {
            // Update existing entry
            var updatedEntry = existingEntry
            updatedEntry.foodName = foodName
            updatedEntry.calories = calories
            updatedEntry.protein = protein
            updatedEntry.carbs = carbs
            updatedEntry.fat = fat
            
            foodRepository.updateFoodEntry(foodEntry: updatedEntry)
            
            showSuccessAlert(message: "Meal updated successfully!") {
                self.btnLogMeal.isActive = false
                self.btnLogMeal.isUserInteractionEnabled = true
                self.onMealLogged?()
                self.dismiss(animated: true)
            }
        } else {
            // Create new entry
            let foodEntry = FoodEntry(
                foodName: foodName,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                date: Date()
            )
            
            foodRepository.saveFoodEntry(foodEntry: foodEntry)
            
            showSuccessAlert(message: "Meal logged successfully!") {
                self.btnLogMeal.isActive = false
                self.btnLogMeal.isUserInteractionEnabled = true
                self.onMealLogged?()
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Success Alert
    func showSuccessAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
    
    func showImageSourceActionSheet(sourceView: CustomButton) {
        let actionSheet = UIAlertController(title: nil, message: "Select Image Source", preferredStyle: .actionSheet)
        
        // Take a photo option
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { [weak self] _ in
            self?.selectOption(index: 0)
        }
        
        // Photos option
        let photoLibraryAction = UIAlertAction(title: "Photos", style: .default) { [weak self] _ in
            self?.selectOption(index: 1)
        }
        
        // Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad support (action sheets require a source view on iPad)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func selectOption(index: Int) {
        switch index {
        case 0:
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            if self.checkCameraAccess() {
                self.selectImageFrom(.camera)
            }
        case 1:
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            if self.checkStatus() {
                self.selectImageFrom(.photoLibrary)
            }
        default:
            break;
        }
    }
}

// MARK: - Crop Image Delegate
extension LogMealVC: BaseVCDelegate {
    func didCropImage(_ image: UIImage) {
        self.btnScan.isActive = false
        // Use image as per need
    }
}


// MARK: - Button Actions
extension LogMealVC {
    
    @IBAction func backAction(_ sender: UIButton) {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextField Delegates
extension LogMealVC {
    
    @objc func foodNameValidate() {
        let foodName = self.txtFoodName.text?.trim() ?? ""
        
        if foodName.isEmpty {
            self.lblErrorFoodName.text = "Food name cannot be empty"
            self.lblErrorFoodName.isHidden = false
            self.isFoodNameEnable = false
        }
        else {
            self.lblErrorFoodName.isHidden = true
            self.isFoodNameEnable = true
        }
        
        updateButtonState()
    }
    
    @objc func fieldsValidate() {
        _ = checkFields(showErrorsForEmpty: false)
        updateButtonState()
    }
    
    // MARK: - Update Button State
    func updateButtonState() {
        let isFoodNameValid = !(txtFoodName.text?.trim().isEmpty ?? true)
        let areFieldsValid = checkFields(showErrorsForEmpty: false)
        btnLogMeal.isEnabled = isFoodNameValid && areFieldsValid
    }

    func checkFields(showErrorsForEmpty: Bool = true) -> Bool {
        var isValid = true
        
        // Validate Calories (must be > 0)
        if let caloriesText = txtCalories.text?.trimmingCharacters(in: .whitespaces), !caloriesText.isEmpty {
            if let calories = Double(caloriesText), calories > 0 {
                lblErrorCalories.isHidden = true
            } else {
                lblErrorCalories.text = "Calories must be greater than 0"
                lblErrorCalories.isHidden = false
                isValid = false
            }
        } else {
            if showErrorsForEmpty {
                lblErrorCalories.text = "Calories must be greater than 0"
                lblErrorCalories.isHidden = false
            } else {
                lblErrorCalories.isHidden = true
            }
            isValid = false // Empty calories = invalid
        }
        
        // Validate Protein (must be >= 0)
        if let proteinText = txtProtein.text?.trimmingCharacters(in: .whitespaces), !proteinText.isEmpty {
            if let protein = Double(proteinText), protein >= 0 {
                lblErrorProtein.isHidden = true
            } else {
                lblErrorProtein.text = "Protein must be 0 or greater"
                lblErrorProtein.isHidden = false
                isValid = false
            }
        } else {
            if showErrorsForEmpty {
                lblErrorProtein.text = "Protein must be 0 or greater"
                lblErrorProtein.isHidden = false
            } else {
                lblErrorProtein.isHidden = true
            }
            isValid = false // Empty protein = invalid
        }
        
        // Validate Carbs (must be >= 0)
        if let carbsText = txtCarbs.text?.trimmingCharacters(in: .whitespaces), !carbsText.isEmpty {
            if let carbs = Double(carbsText), carbs >= 0 {
                lblErrorCarbs.isHidden = true
            } else {
                lblErrorCarbs.text = "Carbs must be 0 or greater"
                lblErrorCarbs.isHidden = false
                isValid = false
            }
        } else {
            if showErrorsForEmpty {
                lblErrorCarbs.text = "Carbs must be 0 or greater"
                lblErrorCarbs.isHidden = false
            } else {
                lblErrorCarbs.isHidden = true
            }
            isValid = false // Empty carbs = invalid
        }
        
        // Validate Fat (must be >= 0)
        if let fatText = txtFat.text?.trimmingCharacters(in: .whitespaces), !fatText.isEmpty {
            if let fat = Double(fatText), fat >= 0 {
                lblErrorFat.isHidden = true
            } else {
                lblErrorFat.text = "Fat must be 0 or greater"
                lblErrorFat.isHidden = false
                isValid = false
            }
        } else {
            if showErrorsForEmpty {
                lblErrorFat.text = "Fat must be 0 or greater"
                lblErrorFat.isHidden = false
            } else {
                lblErrorFat.isHidden = true
            }
            isValid = false // Empty fat = invalid
        }
        
        return isValid
    }
    
}
