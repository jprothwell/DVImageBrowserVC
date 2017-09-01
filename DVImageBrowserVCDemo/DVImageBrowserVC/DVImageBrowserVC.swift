//
//  DVImageBrowserVC.swift
//  DVImageBrowserVCDemo
//
//  Created by LIHUA LEI on 2017/8/29.
//  Copyright © 2017年 david. All rights reserved.
//

enum DVImageVCTransitionType {
    case modal
    case push
}

import UIKit

class DVImageBrowserVC: UIViewController {
    
    /// 删除按钮
    fileprivate lazy var deleteBtn: UIButton! = {
        let btn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-45, y: 20, width: 30, height: 30))
        btn.setImage(UIImage(named: "DVIBVC_Delete@2x"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(self.deleteImage), for: UIControlEvents.touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    /// 导航栏上的删除按钮
    fileprivate lazy var navDeleteBtn: UIButton! = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btn.setImage(UIImage(named: "DVIBVC_Delete@2x"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(self.deleteImage), for: UIControlEvents.touchUpInside)
        btn.isHidden = true
        return btn
    }()
    /// 导航栏标题
    fileprivate lazy var titleLabel: UILabel! = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        
        return label
    }()
    
    fileprivate lazy var imageCollection: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        /// 竖直方向的间距
        layout.minimumLineSpacing = 0
        /// 水平方向的间距
        layout.minimumInteritemSpacing = 0
        /// 设置为水平滚动
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collection: UICollectionView! = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        collection.backgroundColor = UIColor.black
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.register(DVImageCell.self, forCellWithReuseIdentifier: "DVImageCell")

        collection.delegate = self
        collection.dataSource = self
        
        return collection
    }()
    
    fileprivate lazy var pageControl: UIPageControl! = {
        let page = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-50, width: UIScreen.main.bounds.width, height: 20))
        page.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.2)
        page.currentPageIndicatorTintColor = UIColor.white
        
        return page
    }()
    
    /// 图片集合，可以传入图片数组或者字符串数组，其他无效
    fileprivate var images: [Any]? {
        didSet {
            self.imageCollection.reloadData()
            self.pageControl.numberOfPages = images?.count ?? 0
            if self.index >= images?.count ?? 1 {
                self.index = self.index - 1
            } else if self.index < 0 {
                self.index = 0
            }
            self.imageCollection.setContentOffset(CGPoint(x: (CGFloat)(self.index)*UIScreen.main.bounds.width, y: 0), animated: false)
        }
    }
    /// 当前正在显示的图片的索引
    fileprivate var index: Int! {
        didSet {
            self.pageControl.currentPage = index
            self.titleLabel.text = "\((self.index ?? 0) + 1)/\(self.images?.count ?? 0)"
        }
    }
    /// 删除block
    fileprivate var deleteBlock: ((Int)->Void)?
    /// 转场方式
    fileprivate var transitionType = DVImageVCTransitionType.modal {
        didSet {
            if transitionType == DVImageVCTransitionType.modal && deleteBlock != nil {
                deleteBtn.isHidden = false
            } else {
                deleteBtn.isHidden = true
            }
            
//            if transitionType == DVImageVCTransitionType.push && deleteBlock != nil {
//                navDeleteBtn.isHidden = false
//                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navDeleteBtn)
//                self.navigationItem.titleView = self.titleLabel
//                self.titleLabel.text = "\((self.index ?? 0) + 1)/\(self.images?.count ?? 0)"
//            } else {
//                navDeleteBtn.isHidden = true
//            }
        }
    }
    
    /// 导航栏标题颜色
    var titleColor = UIColor.white {
        didSet {
            self.titleLabel.textColor = titleColor
        }
    }
    /// 导航栏删除按钮的图片
    var navDeleteBtnImage: UIImage? {
        didSet {
            self.navDeleteBtn.setImage(navDeleteBtnImage, for: UIControlState.normal)
        }
    }
    /// 删除按钮的图片
    var deleteBtnImage: UIImage? {
        didSet {
            self.deleteBtn.setImage(deleteBtnImage, for: UIControlState.normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func show(target: UIViewController!, transitionType: DVImageVCTransitionType, images: [Any]?, index: Int, deleteBlock: ((Int)->Void)?) {
        let vc = DVImageBrowserVC()
        vc.index = index < 0 ? 0 : index
        vc.images = images
        vc.pageControl.currentPage = vc.index
        vc.deleteBlock = deleteBlock
        vc.transitionType = transitionType
        
        if transitionType == DVImageVCTransitionType.modal {
            target.present(vc, animated: true, completion: nil)
        } else if transitionType == DVImageVCTransitionType.push {
            target.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //override var prefersStatusBarHidden: Bool {
    //    get {
    //       if transitionType == DVImageVCTransitionType.push {
    //            return false
    //        } else {
    //            return true
    //        }
    //    }
    //}
    
    func setView() {
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(imageCollection)
        self.view.addSubview(deleteBtn)
        self.view.addSubview(pageControl)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navDeleteBtn)
        self.navigationItem.titleView = self.titleLabel
        self.titleLabel.text = "\((self.index ?? 0) + 1)/\(self.images?.count ?? 0)"
    }
    
    /// 删除图片
    func deleteImage() {
        self.deleteBlock?(self.index)
        
        var imgs = self.images
        imgs?.remove(at: self.index)
        if imgs?.count ?? 0 <= 0 {
            if self.transitionType == DVImageVCTransitionType.modal {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.images = imgs
            self.titleLabel.text = "\((self.index ?? 0) + 1)/\(self.images?.count ?? 0)"
        }
    }
}

extension DVImageBrowserVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DVImageCell", for: indexPath)
        
        (cell as? DVImageCell)?.image = self.images?[indexPath.row]
        (cell as? DVImageCell)?.singleTapBolck = {
            self.dismiss(animated: true, completion: nil)
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        self.index = (Int)(offsetX / UIScreen.main.bounds.width)
    }
    
}