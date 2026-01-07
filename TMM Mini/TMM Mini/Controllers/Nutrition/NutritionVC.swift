//
//  NutritionVC.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 07/01/26.
//

import UIKit

class NutritionVC: UIViewController {
    
    @IBOutlet weak var btnNutrition: CustomButton!
    
    @IBOutlet weak var tblMeals: UITableView!
    @IBOutlet weak var emptyView: CustomEmptyView!
    
    // MARK: - Data
    private let foodRepository = FoodEntryRepository()
    private var groupedData: [String: [FoodEntry]] = [:]
    private var sectionTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()

        self.btnNutrition.lblTitle.font = AppFont.font(type: .I_Bold, size: 16)
        self.btnNutrition.onToggle = { [weak self] _ in
            self?.btnNutrition.isActive = false
            let logMealVC = Utils.loadVC(strStoryboardId: StoryBoard.SB_Nutrition, strVCId: ViewControllerID.VC_LogMeal) as! LogMealVC
            logMealVC.isEditMode = false
            
            // Present as bottom sheet modal
            if let sheet = logMealVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()] // Half and full screen options
                sheet.prefersGrabberVisible = true // Show the handle at top
                sheet.preferredCornerRadius = 20 // Rounded corners
            }
            
            self?.present(logMealVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    
    func setupUI() {
        self.btnNutrition.lblTitle.font = AppFont.font(type: .I_Bold, size: 16)
        self.btnNutrition.onToggle = { [weak self] _ in
            self?.btnNutrition.isActive = false
            let logMealVC = Utils.loadVC(strStoryboardId: StoryBoard.SB_Nutrition, strVCId: ViewControllerID.VC_LogMeal) as! LogMealVC
            logMealVC.isEditMode = false
            self?.navigationController?.pushViewController(logMealVC, animated: true)
        }
        
        // No data label
        emptyView.lblTitle.text = "No meals logged yet"
        emptyView.lblSubTitle.text = "Log your meals to track calories and macros."
    }
    
    func setupTableView() {
        self.tblMeals.register(cellTypes: [NutritionTVCell.self])
        
        self.tblMeals.backgroundColor = UIColor.BG
        self.tblMeals.separatorStyle = .none
        self.tblMeals.showsVerticalScrollIndicator = false
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        self.tblMeals.tableHeaderView = UIView(frame: frame)
        self.tblMeals.tableFooterView = UIView(frame: .zero)
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tblMeals.contentInset = insets
        self.tblMeals.estimatedRowHeight = 120
        self.tblMeals.contentInsetAdjustmentBehavior = .never
        self.tblMeals.isUserInteractionEnabled = true
        
        self.tblMeals.delegate = self
        self.tblMeals.dataSource = self
    }
    
    // MARK: - Load Data
    func loadData() {
        groupedData = foodRepository.fetchGroupedFoodEntries()
        
        // Sort section titles
        sectionTitles = groupedData.keys.sorted { title1, title2 in
            if title1 == "Today" { return true }
            if title2 == "Today" { return false }
            if title1 == "Yesterday" { return true }
            if title2 == "Yesterday" { return false }
            
            // Parse dates for other sections
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            
            if let date1 = dateFormatter.date(from: title1),
               let date2 = dateFormatter.date(from: title2) {
                return date1 > date2
            }
            return title1 > title2
        }
        
        // Show/hide no data label
        self.emptyView.isHidden = !groupedData.isEmpty
        tblMeals.isHidden = groupedData.isEmpty
        
        tblMeals.reloadData()
    }

}


// MARK: - Button Actions
extension NutritionVC {
    
    @IBAction func backAction(_ sneder: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension NutritionVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        return groupedData[sectionTitle]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NutritionTVCell.className, for: indexPath) as? NutritionTVCell else {
            return UITableViewCell()
        }
        
        let sectionTitle = sectionTitles[indexPath.section]
        if let foodEntries = groupedData[sectionTitle] {
            let foodEntry = foodEntries[indexPath.row]
            cell.configure(with: foodEntry)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.text = sectionTitles[section]
        label.font = AppFont.font(type: .I_Bold, size: 18)
        label.textColor = .text
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = sectionTitles[indexPath.section]
        guard let foodEntries = groupedData[sectionTitle] else { return }
        
        let foodEntry = foodEntries[indexPath.row]
        
        let logMealVC = Utils.loadVC(strStoryboardId: StoryBoard.SB_Nutrition, strVCId: ViewControllerID.VC_LogMeal) as! LogMealVC
        logMealVC.isEditMode = true
        logMealVC.existingFoodEntry = foodEntry
        
        if let sheet = logMealVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(logMealVC, animated: true)
    }
}
