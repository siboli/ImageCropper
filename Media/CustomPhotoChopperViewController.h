//
//  CustomPhotoChopperViewController.h
//  Bindo POS
//
//  Created by Sibo Li on 5/16/12.
//  Copyright (c) 2012 BindoLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPGreenButton.h"
#import "BPBlueButton.h"

typedef enum 
{
    CropperViewFrameTypeSmallLandscape,     // 480 x 320
    CropperViewFrameTypeSmallPortrait       // 320 x 480
}CropperViewFrameType;

@protocol CustomPhotoChopperDelegate;

@interface CustomPhotoChopperViewController : UIViewController <UIScrollViewDelegate>
{
    CGPoint _lastTouchDownPoint;
    float _imageRatio;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) CropperViewFrameType mode;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *cropRectangleButton;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, assign) float cropBorder;
@property (nonatomic, retain) IBOutlet BPBlueButton *selectCroppedImageButton;
@property (nonatomic, retain) IBOutlet BPBlueButton *selectOrignalImageButton;
@property (nonatomic, assign) id<CustomPhotoChopperDelegate> delegate;
@property (nonatomic, assign) CGFloat minZoomScale;
@property (nonatomic, assign) CGFloat maxZoomScale;
@property (nonatomic, retain) NSString *photoCropperTitle;

- (id) initWithPhoto:(UIImage *)originalPhoto
            delegate:(id<CustomPhotoChopperDelegate>)chopperDelegate
                mode:(CropperViewFrameType)controllerMode;
- (id) initWithPhoto:(UIImage *)originalPhoto
            delegate:(id<CustomPhotoChopperDelegate>)chopperDelegate
                mode:(CropperViewFrameType) controllerMode
   cropRectInnerSize:(CGSize)size
      cropRectBorder:(float)border;

- (IBAction) pressSelectCropped:(id)sender;
- (IBAction) pressSelectOriginal:(id)sender;

@end


@protocol CustomPhotoChopperDelegate <NSObject>
@optional
- (void) photoCropper:(CustomPhotoChopperViewController *)photoCropper
         didCropPhoto:(UIImage *)photo;
- (void) photoCropperDidCancel:(CustomPhotoChopperViewController *)photoCropper;
@end
