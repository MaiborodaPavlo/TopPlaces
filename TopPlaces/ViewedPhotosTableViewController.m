//
//  ViewedPhotosTableViewController.m
//  TopPlaces
//
//  Created by Pavel on 27.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "ViewedPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "DataManager.h"
#import "ImageViewController.h"

@interface ViewedPhotosTableViewController ()

@end

@implementation ViewedPhotosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photos = [[DataManager sharedManager] viewedPhotos];
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.photos = [[DataManager sharedManager] viewedPhotos];
    [self.tableView reloadData];
}

- (NSArray *) photos {
    
    if (!_photos) _photos = [NSArray array];
    
    return _photos;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo Cell" forIndexPath:indexPath];
    
    NSString *title = [[self.photos objectAtIndex: indexPath.row] valueForKey: FLICKR_PHOTO_TITLE];
    NSString *subtitle = [[self.photos objectAtIndex: indexPath.row] valueForKeyPath: FLICKR_PHOTO_DESCRIPTION];
    
    if ([title length] != 0) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = subtitle;
    } else if ([subtitle length] != 0) {
        cell.textLabel.text = subtitle;
    } else {
        cell.textLabel.text = @"Unknown";
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the Detail view controller in our UISplitViewController (nil if not in one)
    id detail = self.splitViewController.viewControllers[1];
    // if Detail is a UINavigationController, look at its root view controller to find it
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    // is the Detail is an ImageViewController?
    if ([detail isKindOfClass:[ImageViewController class]]) {
        // yes ... we know how to update that!
        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
    }
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhoto: photo format: FlickrPhotoFormatLarge];
    ivc.title = [photo valueForKeyPath: FLICKR_PHOTO_TITLE];
}

// In a story board-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
        if (indexPath) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                // yes ... is the destination an ImageViewController?
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    // yes ... then we know how to prepare for that segue!
                    [self prepareImageViewController: segue.destinationViewController
                                      toDisplayPhoto: self.photos[indexPath.row]];
                }
            }
        }
    }
}

@end
