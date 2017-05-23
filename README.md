# ZWTPhotoBrowser
##自定义简易图片浏览器,方便敏捷开发,集成到相应的图片预览组件

'pod 'ZWTPhotoBrowser'

##Demo

`
let photos = self.photoView.imageArray.map { (image) -> WTPhoto in
let photo = WTPhoto(image: image)
return photo
}
let browser = WTPhotoBrowser(photos: photos, currentIndex: view.indexPath(for: cell)?.row ?? 0) { (index) -> (UIImageView) in
return cell.imageV
}
//        let browser = WTPhotoBrowser(photos: photos, currentIndex: view.indexPath(for: cell)?.row ?? 0)
browser.indicatorStyle = .pageControl
self.present(browser, animated: true) { 

}
