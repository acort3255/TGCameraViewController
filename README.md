<p align="center">
  <img src="http://s23.postimg.org/4psw1dtyj/TGCamera_View_Controller.png" alt="TGCameraViewController" title="TGCameraViewController">
</p>

<p align="center">
  <img src="http://s28.postimg.org/eeli1omct/TGCamera_View_Controller.png" alt="TGCameraViewController" title="TGCameraViewController">
</p>

Custom camera with AVFoundation. Beautiful, light and easy to integrate with iOS projects.

[![Build Status](https://api.travis-ci.org/tdginternet/TGCameraViewController.png)](https://api.travis-ci.org/tdginternet/TGCameraViewController.png)&nbsp;
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/v/TGCameraViewController.svg)](http://cocoapods.org/?q=on%3Aios%20tgcameraviewcontroller)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/p/TGCameraViewController.svg)](http://cocoapods.org/?q=on%3Aios%20tgcameraviewcontroller)&nbsp;
[![Analytics](https://ga-beacon.appspot.com/UA-54929747-1/tdginternet/TGCameraViewController/README.md)](https://github.com/igrigorik/ga-beacon)

* Completely custom camera with AVFoundation, written in Swift 2.2
* Custom view with camera permission denied
* Custom button colors
* Easy way to access album (camera roll)
* Flash/Torch auto, off and on
* Video support
* Focus
* Front and back camera
* Grid view
* Preview photo view with three filters (fast processing)
* Visual effects like Instagram iOS app
* iPhone, iPod and iPad supported

<em>This library can be applied on devices running iOS 8.0+.</em>

---
---

### Who use it

Find out [who uses TGCameraViewController](https://github.com/tdginternet/TGCameraViewController/wiki/WHO-USES) and add your app to the list.

---
---

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TGCameraViewController into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "acort3255/TGCameraViewController"
```

Run `carthage` to build the framework and drag the built `TGCameraViewController.framework` into your Xcode project.

---
---

### Usage

#### Take photo

```obj-c
#import "TGCameraViewController.h"

@interface TGViewController : UIViewController <TGCameraDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

- (IBAction)takePhotoTapped;

@end



@implementation TGViewController

- (IBAction)takePhotoTapped
{
    TGCameraNavigationController *navigationController =
    [TGCameraNavigationController newWithCameraDelegate:self];

    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    _photoView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    _photoView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
```

#### Choose photo

```obj-c
#import "TGCameraViewController.h"
#import "TGCameraViewController-Swift.h"

@interface TGViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

- (IBAction)chooseExistingPhotoTapped;

@end



@implementation TGViewController

- (IBAction)chooseExistingPhotoTapped
{
    UIImagePickerController *pickerController =
    [TGAlbum imagePickerControllerWithDelegate:self];

    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _photoView.image = [TGAlbum imageWithMediaInfo:info];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
```

#### Change colors

```obj-c
@implementation TGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *tintColor = [UIColor greenColor];
    [TGCameraColor setTintColor:tintColor];
}

@end
```

#### Options

|Option|Type|Default|Description|
|:-:|:-:|:-:|:-:|
|TGCamera.toggleButtonHidden|BOOL (true/false)(YES/NO)|(false/NO)|Displays or hides the button that switches between the front and rear camera|
|TGCamera.albumButtonHidden|BOOL (true/false)(YES/NO)|(false/NO)|Displays or hides the button that allows the user to select a photo from his/her album|
|TGCamera.filterButtonHidden|BOOL (true/false)(YES/NO)|(false/NO)|Displays or hides the button that allos the user to filter his/her photo|
|TGCamera.saveMediaToAlbum|BOOL (true/false)(YES/NO)|(false/NO)|Whether or not to save the media to the camera roll|

```obj-c
#import "TGCamera.h"

@implementation UIViewController

- (void)viewDidLoad
{
    //...
    TGCamera.toggleButtonHidden = YES;
    TGCamera.albumButtonHidden = YES;
    TGCamera.filterButtonHidden = YES;
    TGCamera.saveMediaToAlbum = YES;
    TGCamera.stopWatchHidden = NO;
    TGCamera.maxDuration = CMTimeMake(10, 1);
    //...
}

- (IBAction)buttonTapped
{
    //...
    BOOL hiddenToggleButton = TGCamera.toggleButtonHidden;
    BOOL hiddenAlbumButton = TGCamera.albumButtonHidden;
    BOOL hiddenFilterButton = TGCamera.filterButtonHidden;
    BOOL saveToDevice = TGCamera.saveMediaToAlbum;
    BOOL stopWatchHidden = TGCamera.stopWatchHidden;
    //...    
}

@end
```

---
---

### Requirements

TGCameraViewController works on iOS 8.0+ version and is compatible with ARC projects. It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* PHPhotoLibrary.framework
* AVFoundation.framework
* CoreImage.framework
* Foundation.framework
* MobileCoreServices.framework
* UIKit.framework

You will need LLVM 3.0 or later in order to build TGCameraViewController.

---
---

### Todo

* Landscape mode support
* Zoom
* Image size as global parameter
* Fast animations
* Create a custom picker controller
* Zoom does not work with the camera roll pictures

---
---

### License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

---
---

### Change-log

A brief summary of each TGCameraViewController release can be found on the [releases](https://github.com/tdginternet/TGCameraViewController/releases).
