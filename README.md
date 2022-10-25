
![Group 1](https://user-images.githubusercontent.com/16545509/197299955-08663f6c-ca9b-49ea-bcf2-20a2a12a1bef.png)

<p align="center">
    <a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-Green.svg?style=flat"></a>
</p>

PowerKit is a generic way to implement UICollectionViewCompositionalLayout & UICollectionViewDiffableDataSource with more feature to save you're time, its use some of libraries to keep you'r work More **Power** , and you can using with ```WebService & Static List of data```

<p>
  • <a href="https://github.com/Juanpe/SkeletonView">SkeletonView</a> Used For Download content Style <br>
  • <a href="https://github.com/Moya/Moya">Moya</a> Used as network layer <br>
  • <a href="https://github.com/SnapKit/SnapKit">SnapKit</a> Used For setup UI Constraint <br>
</p>

## Contents

- [🔌 Requirements](#requirements)
- [📱 Communication](#communication)
- [📲 Installation](#installation)
- [⚓️ Usage](#usage)
    - [🔠 Model](#-Model) 
    - [🎨 UIcollectionViewCell](#-UIcollectionViewCell) 
    - [🏗 ViewModel](#-ViewModel)
    - [🏢 ViewController](#-ViewController)
- [⚓️ Author](#Author)
- [🪄 Sponsor](#Sponsor)
- [🥋 License](#License)

## Requirements

- iOS 14.0+ / Mac OS Catalyst M1+ 
- Xcode 13.0+
- Swift 5.0+

## Communication

- If you **found a bug**, open an issue
- If you **have a feature request**, open an issue
- Use adelbios11@gmail.com to send email

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 11+ is required to build PowerKit using Swift Package Manager.

To integrate PowerKit into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/adelbios/PowerKit.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

This **PowerKit** divided into 4 paices of code to dealing with it 

```swift
import PowerKit
```

### 🔠 Model

Create struct or class model that implement   ```Codable``` & ```Hashable``` protocols, Because we mentioned we use ```UICollectionViewDiffableDataSource```

```swift
struct DemoModel: Codable, Hashable {
    let title: String
    let message: String
}
```


### 🎨 UIcollectionViewCell
Create ```UICollectionViewCell``` that inherit from ```PowerCollectionCell``` and implement ```PowerCellDelegate``` to pass data from viewModel into cell

```swift 
import UIKit
import PowerKit

class DemoCell: PowerCollectionCell {
    
    //MARK: - LifeCycle 
    override func setupViews() {
      /*
      Called what did you want here, don't forget add UI Component into contentView** rather than self,
      becuase SekeletonView Layer works only with contentView
      */
      //Call this function to enable SkeletonView animation layer for loading content
      enableSkeletoneFor([self, stackView, titleLabel, messageLabel, ...etc])
    }

}
//MARK: - PowerCellDelegate
extension DemoCell: PowerCellDelegate {
    
    func configure(data: DemoModel) {
        titleLabel.text = data.title
        messageLabel.text = data.message
    }
}

```


### 🏗 ViewModel

Create new ```ViewModel``` that inherit from ```PowerViewModel``` but set data type to it, this new ```viewModel``` can be work with static data and webservice 

#### 1/ work with static data 

```swift 
import UIKit
import PowerKit

class DemoViewModel: PowerViewModel<DemoModel> {
    
    //MARK: - Variables
    private enum Cells {
        typealias main = PowerModel<DemoCell, DemoModel>
    }
    
    //MARK: - Fetch Data from Internal
    override func fetchStaticData() {
        super.fetchStaticData()
         self.addNew(items: [
            Cells.main(item: .init(title: "Title A", message: "Message A")),
            Cells.main(item: .init(title: "Title B", message: "Message B")),
            Cells.main(item: .init(title: "Title C", message: "Message C")),
         ], forSection: 0)
    }
    
    override func configureViewModelSettings() {
        settings()
    }
    
    override func handlePowerCellAction() {
        handleCellsAction()
    }
    
}

//MARK: - Helper
extension DemoViewModel {
    
    func handleCellsAction() {
        action.on(.didSelect) { (model: Cells.main, cell, indexPath) in
            guard let model = model.item as? DemoModel else { return }
            //You can push, present || dismiss using self.viewController, becase each viewMode have viewController
            log(type: .success, model.title)
        }
        
    }
    
    func settings() {
        self.add(settings: [
            .init(
                section: 0,
                layout: .vertical,
                registeredCells: [.init(cell: DemoCell.self, skeletonCount: 10)]
            )
        ])
    }

}

```
#### 2/ work with WebService 

just override these functions and call it in parent ```viewController``` And take a look at the <a href="https://github.com/Moya/Moya">Moya</a> to figure out how you can create target for web service


```swift 
    //If  you want run request in background or not , default value is false
    override var isLoadingInBackground: Bool {
        return true
    }
    
    //MARK: - Make Https request
    override func makeHTTPRequest() {
        super.makeHTTPRequest()
        //network.request(target: TargetType)
    }
    
    //MARK: - Post Request
    override func postRequestAt(_ view: UIView) {
        super.postRequestAt(view)
        //network.request(target: TargetType, at: view, printOutResult: true, withProgress: true)
    }
    
    //MARK: - Fetch Next paging
    override func fetchNextPaging() {
        super.fetchNextPaging()
        //guard let page = increaseCurrentPage(forSection: 0) else { return }
        //network.request(DocumentsTarget.dummyAPI(page: page))
    }
    
    //MARK: - DidFetch Data Success
    override func didFetchModels(_ model: DemoModel) {
        //let cells = model.map({ Cells.main(item: $0) })
        //self.updateLoadMore(forSection: 1 lastPage: 100)
        //self.addNew(items: [cells], forSection: 0)
    }


```

### 🏢 ViewController

The Master of ```PowerKit``` to be working just make yo're ```ViewController``` inherit of PowerViewController and pass the ```Model``` and ```ViewModel``` to it 

```swift 
import UIKit
import PowerKit

class DemoViewController: PowerViewController<DemoModel, DemoViewModel> {
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        settings()
        setupUI()
        viewModel.fetchStaticData()
    }
    
    override func settingConfigure() {
        powerSettings.isPullToRefreshUsed = true
        powerSettings.loadContentType = .skeleton
    }
    
    override func showAlertForNoInternetConnection(title: String, message: String) {
    }
    
}

//MARK: - Settings
extension DemoViewController {
    
    func settings() {
        collectionView.setInsit(.zero)
        setBackground(color: .white)
        collectionView.emptyView.configure(
            viewType: .empty,
            layoutPosition: .middle,
            message: "Empty Data message"
        )
    }
    
    func setupUI() {
        setupCollectionViewConstraint(padding: .zero)
    }
    
}
```

## ⚓️ Author
<a href="adelbios11@gmail.com"> Adel M. Radwan</a>


## 🪄 Sponsor
 
 <a href="https://www.jeddah.gov.sa/english/index.php">Jeddah Municipality</a> 

## 🥋 License

```
MIT License

Copyright (c) 2017 Juanpe Catalán

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


