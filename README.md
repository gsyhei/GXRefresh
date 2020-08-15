# GXRefresh
Swift版的下拉刷新上拉加载，支持Gif、支持自定义刷新动画。
若有建议或增加需求更可直接可以联系QQ：279694479

# 喜欢就给个star哦，QQ：279694479

先上效果图
--

![](/GXRefresh.gif '描述')


Requirements
--
- iOS 9.0 or later
- Xcode 11.0 or later
- Swift 4.2 or later

Usage in you Podfile:
--

```
pod 'GXRefresh'
```

GXRefresh Normal
--

```swift
self.tableView.gx_header = GXRefreshNormalHeader(refreshingAction: { [weak self] in
    self?.refreshDataSource()
})
self.tableView.gx_footer = GXRefreshNormalFooter(refreshingAction: { [weak self] in
    self?.loadMoreData()
})
```

GXRefresh Gif
--

```swift
var imageNames: [String] = []
for i in 0..<31 {
    imageNames.append(String(format: "refresh%d", i))
}
let header = GXRefreshGifHeader(refreshingAction: { [weak self] in
    self?.refreshDataSource()
})
header.setRefreshImages([imageNames.first!], for: .idle)
header.setRefreshImages(imageNames, for: .pulling)
header.setRefreshImages(imageNames, duration: 2.0, for: .did)
header.setRefreshImages([imageNames.last!], for: .end)
self.tableView.gx_header = header
self.tableView.gx_header?.backgroundColor = UIColor(white: 0.95, alpha: 1)

let footer = GXRefreshGifFooter(refreshingAction: { [weak self] in
    self?.loadMoreData()
})
footer.setRefreshImages([imageNames[21]], for: .idle)
footer.setRefreshImages(imageNames, duration: 2.0, for: .did)
footer.setRefreshImages([imageNames.last!], for: .noMore)
self.tableView.gx_footer = footer
```

GXRefresh Custom 
--

```swift
private var headerLoadView: UIImageView = {
    let view = UIImageView(image: UIImage(named: "refresh30"))
    return view
}()
private var footerLoadView: UIImageView = {
    let view = UIImageView(image: UIImage(named: "refresh30"))
    return view
}()

let header = GXRefreshCustomHeader(refreshingAction: { [weak self] in
    self?.refreshDataSource()
})
header.isTextHidden = true
header.updateCustomIndicator(view: self.headerLoadView)
header.progressCallBack = { (view) in
    let angle = self.rotationAngle(progress: view.pullingProgress)
    self.headerLoadView.transform = CGAffineTransform(rotationAngle: angle)
}
header.stateCallBack = { (state) in
    if state == .did {
        self.headerLoadView.layer.add(self.rotationAnimation(), forKey: nil)
    }
    else {
        self.footerLoadView.transform = .identity
        self.headerLoadView.layer.removeAllAnimations()
    }
}
self.tableView.gx_header = header

let footer = GXRefreshCustomFooter(refreshingAction: { [weak self] in
    self?.loadMoreData()
})
footer.updateCustomIndicator(view: self.footerLoadView)
footer.progressCallBack = { (view) in
    let angle = self.rotationAngle(progress: view.pullingProgress)
    self.footerLoadView.transform = CGAffineTransform(rotationAngle: angle)
}
footer.stateCallBack = { (state) in
    if state == .did {
        self.footerLoadView.layer.add(self.rotationAnimation(), forKey: nil)
    }
    else {
        self.footerLoadView.transform = .identity
        self.footerLoadView.layer.removeAllAnimations()
    }
}
self.tableView.gx_footer = footer
```

License
--
MIT


