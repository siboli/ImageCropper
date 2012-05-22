//
//  CustomImageController.m
//  Bindo POS
//
//  Created by Sibo Li on 5/16/12.
//  Copyright (c) 2012 BindoLabs. All rights reserved.
//

#import "CustomImagePickerController.h"
#import "CustomBarButtonItemFactory.h"

@implementation CustomImagePickerController

@synthesize customDelegate;
@synthesize chopperViewController;
@synthesize nav;
@synthesize cropSize, cropBorder;

- (id) init
{
    self = [super init];
    if(self)
    {
        self.delegate = self;
        self.allowsEditing = NO;
        self.cropSize = CGSizeMake(240, 160);
        self.cropBorder = 15.0f;
    }
    return self;
}

- (CropperViewFrameType) cropperViewFrameType
{        
    if(frameSize.width == 480 && (frameSize.height == 320 || frameSize.height == 320 - self.navigationBar.height))
        return CropperViewFrameTypeSmallLandscape;
    if(frameSize.width == 320 && (frameSize.height == 480 || frameSize.height == 480 - self.navigationBar.height))
        return CropperViewFrameTypeSmallPortrait;
        
    //default
    return CropperViewFrameTypeSmallLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (TTIsPad()) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationBar* bar = self.navigationBar;
    [bar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [back setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    viewController.navigationItem.backBarButtonItem = back;
    
}



#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    frameSize = navigationController.view.frame.size;

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    self.chopperViewController = [[CustomPhotoChopperViewController alloc] 
                                            initWithPhoto:image
                                                 delegate:self
                                                     mode:[self cropperViewFrameType]
                                        cropRectInnerSize:self.cropSize 
                                           cropRectBorder:self.cropBorder];
    nav = [[UINavigationController alloc] initWithRootViewController:chopperViewController];
    nav.view.frame = self.view.frame;
    [self.view addSubview:nav.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - CustomPhotoChopperDelegate

- (void) photoCropper:(CustomPhotoChopperViewController *)photoCropper
         didCropPhoto:(UIImage *)photo
{
    [self.nav.view setHidden:YES];
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(customImagePickerController:didSelectImage:)]) {
        [self.customDelegate customImagePickerController:self didSelectImage:photo];
    }
}

- (void) photoCropperDidCancel:(CustomPhotoChopperViewController *)photoCropper
{
    [self.nav.view setHidden:YES];
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(customImagePickerControllerDidCancel:)]) {
        [self.customDelegate customImagePickerControllerDidCancel:self];
    }    
}


@end
