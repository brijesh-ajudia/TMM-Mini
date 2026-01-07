//
//  CarouselTVCell.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import UIKit
import SkeletonView

class CarouselTVCell: UITableViewCell {
    
    @IBOutlet weak var clvCarousel: UICollectionView!
    
    var centeredClViewFlowlayout: PagingCollectionViewLayout!
    
    var carouselData : [(String, String, String)] = [("best day this week", "Wednesday · 11,240 steps", "chart.bar.fill"),
                                             ("Compared to last week", "You’re +12% ahead", "arrow.up.right"),
                                             ("7-day average","8,960 steps / day", "figure.walk.circle.fill")]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupCollectionView()        
        setupSkeleton()
    }
    
    private func setupCollectionView() {
        self.clvCarousel.backgroundColor = .clear
        self.clvCarousel.delegate = self
        self.clvCarousel.dataSource = self
        self.clvCarousel.showsHorizontalScrollIndicator = false
        self.clvCarousel.translatesAutoresizingMaskIntoConstraints = false
        
        let carouselWidth: CGFloat = screenWidth() - 40
        let carouselHeight: CGFloat = 94
        
        centeredClViewFlowlayout = clvCarousel.collectionViewLayout as? PagingCollectionViewLayout
        centeredClViewFlowlayout.scrollDirection = .horizontal
        centeredClViewFlowlayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        centeredClViewFlowlayout.itemSize = CGSize(width: carouselWidth, height: carouselHeight)
        centeredClViewFlowlayout.minimumLineSpacing = 10
        centeredClViewFlowlayout.minimumInteritemSpacing = 0
        
        self.clvCarousel.frame = CGRect(x: 0, y: 0, width: screenWidth(), height: carouselHeight)
        self.clvCarousel.register(cellTypes: [CarouselCVCell.self])
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    private func setupSkeleton() {
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        clvCarousel.isSkeletonable = true
        clvCarousel.showsHorizontalScrollIndicator = false
    }
    
    func configure(with data: [(String, String, String)]) {
        self.carouselData = data
        self.clvCarousel.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

// MARK:- CollectionView Delegate and DataSource
extension CarouselTVCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.carouselData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCVCell.className, for: indexPath) as! CarouselCVCell
        
        let carouselObj =  self.carouselData[indexPath.row]
        cell.lblTitle.text = carouselObj.0
        cell.lblData.text = carouselObj.1
        cell.imgIcon.image = UIImage(systemName: carouselObj.2)?.withRenderingMode(.alwaysTemplate)
        cell.imgIcon.tintColor = .stepsRing
        
        return cell
    }
}
