//
//  PhotoBrowser.swift
//  PhotoBrowser-swift
//
//  Created by zhangwentong on 2017/5/30.
//  Copyright © 2017年 YiXue. All rights reserved.
//

import UIKit

public enum WTPhotoBrowserIndicatorStyle {
    
    case label
    case pageControl
    
}

public enum WTPhotoBrowserIndicatorPosition {
    
    case top
    case bottom
}
public protocol WTPhotoBrowserDelegate {
    func photoViewHasBeenLongPressed(_ longPress:UILongPressGestureRecognizer,_ photoBrowser:WTPhotoBrowser)
}
public class WTPhotoBrowser: UIViewController {
    public  var photoBrowserDelegate:WTPhotoBrowserDelegate?
    //提示 label
    public var hud = UILabel()
    fileprivate var originWindowLevel:UIWindowLevel!
    
    
    public var photos: [WTPhoto]?
    
    public var currentIndex: Int! {
        didSet{
            
            pageLabel.text = "\(currentIndex + 1) / \(photos?.count ?? 0)"
            pageControl.currentPage = currentIndex
        }
    }
    
    public var indicatorStyle = WTPhotoBrowserIndicatorStyle.label
    public var indicatorPosition = WTPhotoBrowserIndicatorPosition.bottom
    
    public var defaultPlaceholderImage: UIImage? {
        didSet{
            
            guard let defaultPlaceholderImage = defaultPlaceholderImage else {
                return
            }
            
            photos?.forEach { (p) in
                p.placeholderImage = defaultPlaceholderImage
            }
            
        }
    }
    
    public init(photos: [WTPhoto], currentIndex: Int, sourceImageViewClosure: ((Int)->(UIImageView))? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.photos = photos
        self.sourceImageViewClosure = sourceImageViewClosure
        self.currentIndex = currentIndex
        
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        
        sourceImageViewClosure = nil
    }
    
    var sourceImageView: UIImageView? {
        return sourceImageViewClosure?(currentIndex)
    }
    
    var displayImageView: UIImageView? {
        
        let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? WTPhotoCell
        return cell?.imageView
    }
    
    fileprivate var sourceImageViewClosure: ((Int)->(UIImageView))?
    
    fileprivate let presentPhotoTransition = WTPhotoTransition(style: .present)
    fileprivate let dismissPhotoTransition = WTPhotoTransition(style: .dismiss)
    
    fileprivate var isOriginalStatusBarHidden = true
    
    /*
    lazy var actionBtn: UIButton = {
        let actionBtn = UIButton()
        actionBtn.setImage(UIImage(named: "icon_action"), for: .normal)
        actionBtn.addTarget(self, action: #selector(WTPhotoBrowser.actionBtnClick), for: .touchUpInside)
        return actionBtn
    }()
 */
    
    lazy var pageLabel: UILabel = {
        let pageLabel = UILabel()
        pageLabel.textColor = UIColor.white
        
        pageLabel.font = UIFont.boldSystemFont(ofSize: 16)
        pageLabel.textAlignment = .center
        pageLabel.text = "\(self.currentIndex + 1) / \(self.photos?.count ?? 0)"

        return pageLabel
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.hidesForSinglePage = true
        pageControl.isEnabled = false
        return pageControl
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = self.view.bounds.size
        layout.sectionInset.right = layout.minimumLineSpacing
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.layout.itemSize.width + self.layout.minimumLineSpacing, height: self.layout.itemSize.height), collectionViewLayout: self.layout)
        
        collectionView.register(WTPhotoCell.self, forCellWithReuseIdentifier: String(describing: WTPhotoCell.self))
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black
        return backgroundView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        setupUI()
        setupLayout()
        setupGesture()
        
    }

    /// 遮盖状态栏。以改变windowLevel的方式遮盖
    fileprivate func coverStatusBar(_ cover: Bool) {
        let win = view.window ?? UIApplication.shared.keyWindow
        guard let window = win else {
            return
        }
        
        if originWindowLevel == nil {
            originWindowLevel = window.windowLevel
        }
        if cover {
            if window.windowLevel == UIWindowLevelStatusBar + 1 {
                return
            }
            window.windowLevel = UIWindowLevelStatusBar + 1
        }
        else {
            if window.windowLevel == originWindowLevel {
                return
            }
            window.windowLevel = originWindowLevel
        }
    }

    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.isHidden = sourceImageView != nil
        
        isOriginalStatusBarHidden = UIApplication.shared.isStatusBarHidden
    
        self.coverStatusBar(true)
//        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coverStatusBar(false)
        
//        UIApplication.shared.setStatusBarHidden(isOriginalStatusBarHidden, with: .fade)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sourceImageView?.isHidden = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.isHidden = false
        sourceImageView?.isHidden = true
    }
    
    
//    override public var prefersStatusBarHidden: Bool {
//        return true
//    }
    
}

extension WTPhotoBrowser: UIViewControllerTransitioningDelegate {
    
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return dismissPhotoTransition
        
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return presentPhotoTransition
        
    }
    
}



extension WTPhotoBrowser: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WTPhotoCell.self), for: indexPath) as? WTPhotoCell else{
            return WTPhotoCell()
        }
        
        cell.photo = photos?[indexPath.item]
        
        
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        sourceImageView?.isHidden = false
        
        currentIndex = indexPath.item
        
        
        sourceImageView?.isHidden = true
    }
}

extension WTPhotoBrowser {
    
    func setupUI() {
        
        view.backgroundColor = UIColor.clear
        view.addSubview(backgroundView)
        view.addSubview(collectionView)
        view.addSubview(pageLabel)
        view.addSubview(pageControl)
//        view.addSubview(actionBtn)
        
        pageControl.numberOfPages = photos?.count ?? 0
        switch indicatorStyle {
        case .label:
            pageControl.isHidden = true
            pageLabel.isHidden = false
        case .pageControl:
            
            pageControl.isHidden = false
            pageLabel.isHidden = true
        }
        
        collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .left, animated: false)
        
    }
    
    func setupGesture() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(WTPhotoBrowser.doubleTap))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(WTPhotoBrowser.singleTap))
        
        view.addGestureRecognizer(singleTap)
        
        singleTap.require(toFail: doubleTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(WTPhotoBrowser.longPress(_:)))
        view.addGestureRecognizer(longPress)
        
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(WTPhotoBrowser.pan(_:)))
        view.addGestureRecognizer(pan)
    }
    
    func setupLayout() {
        
        backgroundView.frame = view.bounds
        
//        actionBtn.frame.size = CGSize(width: 44, height: 44)
//        actionBtn.frame.origin.x = view.bounds.width - actionBtn.frame.width
//        actionBtn.frame.origin.y = view.bounds.height - actionBtn.frame.height
        
        switch indicatorPosition {
        case .bottom:
            
            pageLabel.frame.size.height = 44
            pageLabel.frame.size.width = view.bounds.width
            pageLabel.frame.origin.y = view.bounds.height - pageLabel.frame.height
        default:
            
            pageLabel.frame.size.height = 44
            pageLabel.frame.size.width = view.bounds.width
//            pageLabel.frame.origin.y = view.bounds.height - pageLabel.frame.height
        }
        
        
        pageControl.frame = pageLabel.frame
    }
    
}

extension WTPhotoBrowser {
    
    func pan(_ pan: UIPanGestureRecognizer) {
        
        let transition = pan.translation(in: view)
        
        let cell = collectionView.visibleCells.last
        
        switch pan.state {
        case .began:
            break
        case .ended, .cancelled, .failed, .possible:
            
            if transition.y > 30 {
                
                dismiss(animated: true, completion: nil)
                
            }else {
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.backgroundView.alpha = 1
                    cell?.transform = CGAffineTransform.identity
                })
                
            }
            
        case .changed:
            
            let scale = 1 - transition.y / UIScreen.main.bounds.height
            
            var transform = CGAffineTransform(translationX: transition.x, y: transition.y)
                
            if transition.y > 0 {
                transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
            }
            
            backgroundView.alpha = scale
            
            cell?.transform = transform

            
        }
        
        
    }
    
    func doubleTap() {
        
        let cell = collectionView.visibleCells.last as? WTPhotoCell
        
        cell?.didZoom()
        
    }
    
    func singleTap() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func longPress(_ longPress: UILongPressGestureRecognizer) {
        photoBrowserDelegate?.photoViewHasBeenLongPressed(longPress, self)
        
//        if longPress.state == .began {
//            
//            actionBtnClick()
//        }
    }
    /*
    func actionBtnClick() {
        
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alertC.addAction(UIAlertAction(title: "保存图片", style: .default, handler: { (_) in
            
            if let cell = self.collectionView.visibleCells.last as? WTPhotoCell, let image = cell.imageView.image {
                
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(WTPhotoBrowser.image(image:didFinishSavingWithError:contextInfo:)), nil)
                
            }
            
        }))
        
        present(alertC, animated: true, completion: nil)
        
    }
    
    func image(image: UIImage, didFinishSavingWithError: Error?, contextInfo: Any?) {
    
        
        hud.layer.cornerRadius = 5
        hud.textAlignment = .center
        hud.textColor = UIColor.white
        hud.font = UIFont.systemFont(ofSize: 14)
        hud.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        hud.clipsToBounds = true
        
        if didFinishSavingWithError == nil {
            
            hud.text = "保存成功"
        }else {
            hud.text = "保存失败"
        }
        
        hud.sizeToFit()
        hud.frame.size.width += 30
        hud.frame.size.height += 20
        
        hud.center = view.center
        hud.alpha = 0
        if hud.isDescendant(of: view){
            
        }else{
            
            view.addSubview(hud)
        }
        
        
        UIView.animate(withDuration: 0.25, animations: { 
            self.hud.alpha = 1
        }) { (_) in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: { 
                
                UIView.animate(withDuration: 0.25, animations: { 
                    self.hud.alpha = 0
                }, completion: { (_) in
                    if self.hud.isDescendant(of: self.view){
                        self.hud.removeFromSuperview()
                    }else{
                        
                       
                    }
                })
                
            })
            
        }
        
    }
 */
    
}


