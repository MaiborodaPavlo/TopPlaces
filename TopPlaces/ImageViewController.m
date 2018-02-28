//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.scrollView addSubview: self.imageView];
}

#pragma mark - Help Methods

- (void) resizeImage: (UIImage *) image {
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = self.scrollView.bounds.size.height;
    float maxWidth = self.scrollView.bounds.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else if(imgRatio > maxRatio)
        {
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    self.imageView.frame = CGRectMake(0, 0, actualWidth, actualHeight);
}


#pragma mark - Properties

// lazy instantiation

- (UIImageView *)imageView {
    
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image {
    
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    
    self.imageView.image = image;
    
    self.scrollView.zoomScale = 1.0;
    [self resizeImage: image];
    
    self.scrollView.contentSize = self.imageView ? self.imageView.frame.size : CGSizeZero;
    
    [self.spinner stopAnimating];
}

- (void)setScrollView:(UIScrollView *)scrollView {
    
    _scrollView = scrollView;
    
    // next three lines are necessary for zooming
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;

    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

#pragma mark - UIScrollViewDelegate


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
    self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
}


#pragma mark - Setting the Image from the Image's URL

- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    [self startDownloadingImage];
}

- (void)startDownloadingImage {
    
    self.image = nil;

    if (self.imageURL) {
        
        [self.spinner startAnimating];

        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {

                if (!error) {
                    if ([request.URL isEqual:self.imageURL]) {

                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            self.image = image;
                        });
                    }
                }
        }];
        
        [task resume];
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
    willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    
    
    self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
}

@end
