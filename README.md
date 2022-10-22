
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

- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
    - [🔠 Model](#-Model) 
    - [🎨 UIcollectionViewCell](#-UIcollectionViewCell) 
    - [🏗 ViewModel](#-ViewModel)
    - [🏢 ViewController](#-ViewController)

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



### 🏢 ViewController




