//
//  CustomImageController.h
//  Bindo POS
//
//  Created by Sibo Li on 5/16/12.
//  Copyright (c) 2012 BindoLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPhotoChopperViewController.h"
@protocol CustomImagePickerControllerDelegate;

@interface CustomImagePickerController : UIImagePickerController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, CustomPhotoChopperDelegate>
{
    CGSize frameSize;
}

@property (nonatomic, assign) id<CustomImagePickerControllerDelegate> customDelegate;
@property (nonatomic, strong) CustomPhotoChopperViewController *chopperViewController;
@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, assign) float cropBorder;

@end

@protocol CustomImagePickerControllerDelegate <NSObject>
@optional
- (void) customImagePickerController:(CustomImagePickerController *)controller 
                      didSelectImage:(UIImage *)photo;
- (void) customImagePickerControllerDidCancel:(CustomImagePickerController *)controller;
@end
