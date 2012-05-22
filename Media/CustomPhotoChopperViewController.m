//
//  CustomPhotoChopperViewController.m
//  Bindo POS
//
//  Created by Sibo Li on 5/16/12.
//  Copyright (c) 2012 BindoLabs. All rights reserved.
//

#import "CustomPhotoChopperViewController.h"
static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation CustomPhotoChopperViewController

@synthesize scrollView, photo, imageView, cropRectangleButton, delegate,
minZoomScale, maxZoomScale, photoCropperTitle, mode;
@synthesize selectCroppedImageButton, selectOrignalImageButton;
@synthesize cropSize, cropBorder;

- (id) initWithPhoto:(UIImage *)originalPhoto
            delegate:(id<CustomPhotoChopperDelegate>)chopperDelegate
                mode:(CropperViewFrameType) controllerMode
{
    return [self initWithPhoto:originalPhoto
                      delegate:chopperDelegate
                          mode:controllerMode
             cropRectInnerSize:CGSizeMake(150, 100)
                cropRectBorder:15.0f];
}


- (id) initWithPhoto:(UIImage *)originalPhoto
            delegate:(id<CustomPhotoChopperDelegate>)chopperDelegate
                mode:(CropperViewFrameType) controllerMode
   cropRectInnerSize:(CGSize)size
      cropRectBorder:(float)border
{
    self.mode = controllerMode;
    switch (self.mode) {
        case CropperViewFrameTypeSmallLandscape:
            self = [super initWithNibName:@"CustomPhotoChopperViewControllerSmallLandscape" bundle:nil];
            break;
        case CropperViewFrameTypeSmallPortrait:
            self = [super initWithNibName:@"CustomPhotoChopperViewControllerSmallPortrait" bundle:nil];
            break;            
        default:
            break;
    }
    
    
    if (!self) {
        return self;
    }
        
    self.photo = originalPhoto;

    self.delegate = chopperDelegate;
    
    self.minZoomScale = 0.5f;
    self.maxZoomScale = 10.0f;
    self.cropSize = size;
    self.cropBorder = border;
    
    self.photoCropperTitle = @"Crop Photo";
    
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.photo = nil;
        self.delegate = nil;        
    }
    return self;
}

- (void) viewDidUnload
{
    [self setScrollView:nil];
    [self setPhoto:nil];
    [self setImageView:nil];
    [self setCropRectangleButton:nil];
    [self setPhotoCropperTitle:nil];
    [super viewDidUnload];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (TTIsPad()) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // setup view ui
    
    self.cropRectangleButton.size = CGSizeMake(cropSize.width + cropBorder * 2, cropSize.height + cropBorder * 2);
    UIImage *im = [TTIMAGE(@"bundle://photo_cropper_rect_on.png") stretchableImageWithLeftCapWidth:cropBorder + 5 topCapHeight:cropBorder + 5];    
    [self.cropRectangleButton setBackgroundImage:im forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(pressedCancel:)];
    self.title = self.photoCropperTitle;
    
    // photo cropper ui stuff
    [self setScrollViewBackground];
    [self.scrollView setMinimumZoomScale:self.minZoomScale];
    [self.scrollView setMaximumZoomScale:self.maxZoomScale];
    
    [self.cropRectangleButton addTarget:self
                                 action:@selector(imageTouch:withEvent:)
                       forControlEvents:UIControlEventTouchDown];
    [self.cropRectangleButton addTarget:self
                                 action:@selector(imageMoved:withEvent:)
                       forControlEvents:UIControlEventTouchDragInside];
    
    if (self.photo != nil) {
        [self loadPhoto];
    }
}



#pragma - UIScrollViewDelegate Methods

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


#pragma - Private Methods

- (void) loadPhoto
{
    if (self.photo == nil) {
        return;
    }
    
    CGFloat w = self.photo.size.width;
    CGFloat h = self.photo.size.height;
    
    CGSize size = self.scrollView.frame.size;
    _imageRatio = w/size.width <= h/size.height? w/size.width: h/size.height;
    
    NSLog(@"view frame size: %@", NSStringFromCGSize(size));
    
    CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, roundf(w / _imageRatio), roundf(h / _imageRatio));
    self.scrollView.contentSize = imageViewFrame.size;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:imageViewFrame];
    iv.image = self.photo;
    iv.frame = imageViewFrame;
    [self.scrollView addSubview:iv];
    self.imageView = iv;
}

- (void) setScrollViewBackground
{
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

- (UIImage *) croppedPhoto
{
    //self.photo = [self rotate:self.photo withOrientation:self.photo.imageOrientation];
    CGFloat zoomScale = self.scrollView.zoomScale;   
    
    CGFloat ox = self.scrollView.contentOffset.x;
    CGFloat oy = self.scrollView.contentOffset.y;
    
    CGFloat cx = (ox + self.cropRectangleButton.frame.origin.x + cropBorder) * _imageRatio / zoomScale;
    CGFloat cy = (oy + self.cropRectangleButton.frame.origin.y + cropBorder) * _imageRatio / zoomScale;
    CGFloat cw = cropSize.width * _imageRatio / zoomScale;
    CGFloat ch = cropSize.height * _imageRatio / zoomScale;
    CGRect cropRect;
    if(UIInterfaceOrientationIsLandscape([self interfaceOrientation]) == NO)
    {
        cropRect = CGRectMake(cx, cy, ch, cw);
    }
    else {
        cropRect = CGRectMake(cx, cy, cw, ch);
    }
    
    self.photo = [self rotate:self.photo withOrientation:self.photo.imageOrientation];
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.photo CGImage], cropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return result;
}

- (IBAction) pressSelectCropped:(id)sender
{    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropper:didCropPhoto:)]) {
        [self.delegate photoCropper:self didCropPhoto:[self croppedPhoto]];
    }
}

- (IBAction) pressSelectOriginal:(id)sender
{
    self.photo = [self rotate:self.photo withOrientation:self.photo.imageOrientation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropper:didCropPhoto:)]) {
        [self.delegate photoCropper:self didCropPhoto:self.photo];
    }
}

- (void) pressedCancel:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropperDidCancel:)]) {
        [self.delegate photoCropperDidCancel:self];
    }
}

- (BOOL) isRectanglePositionValid:(CGPoint)pos
{
    CGRect innerRect = CGRectMake((pos.x + cropBorder), (pos.y + cropBorder), cropSize.width, cropSize.height);
    return CGRectContainsRect(self.scrollView.frame, innerRect);
}

- (IBAction) imageMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    
    CGPoint prev = _lastTouchDownPoint;
    _lastTouchDownPoint = point;
    CGFloat diffX = point.x - prev.x;
    CGFloat diffY = point.y - prev.y;
    
    UIControl *button = sender;
    CGRect newFrame = button.frame;
    newFrame.origin.x += diffX;
    newFrame.origin.y += diffY;
    if ([self isRectanglePositionValid:newFrame.origin]) {
        button.frame = newFrame;
    }
}

- (IBAction) imageTouch:(id)sender withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    _lastTouchDownPoint = point;
}

- (UIImage*) rotate:(UIImage*)initImage withOrientation:(UIImageOrientation)orientation
{
    UIImage* sourceImage = initImage; 
    if (sourceImage.imageOrientation == UIImageOrientationUp)
    {
        return sourceImage;        
    }
    
    CGFloat targetWidth, targetHeight;
    if(UIInterfaceOrientationIsLandscape([self interfaceOrientation]) == NO)
    {
        targetWidth = initImage.size.width > initImage.size.height? initImage.size.width: initImage.size.height;
        targetHeight = initImage.size.width > initImage.size.height? initImage.size.height: initImage.size.width;
    }
    else {
        targetWidth = initImage.size.width > initImage.size.height? initImage.size.height: initImage.size.width;
        targetHeight = initImage.size.width > initImage.size.height? initImage.size.width: initImage.size.height;
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }       
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);

    return newImage; 
}

@end
