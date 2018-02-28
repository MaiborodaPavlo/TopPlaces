//
//  TopPlacesTableViewController.m
//  TopPlaces
//
//  Created by Pavel on 27.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoAtPlaceTableViewController.h"

@interface TopPlacesTableViewController ()

@end

@implementation TopPlacesTableViewController

@synthesize places = _places;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchTopPlaces];
}

- (NSDictionary *) places {
    
    if (!_places) {
        _places = [[NSDictionary alloc] init];
    }
    
    return _places;
}

- (void) setPlaces:(NSDictionary *)places {
    
    _places = places;
    [self.tableView reloadData];
}

- (IBAction)fetchTopPlaces {
    
    [self.refreshControl beginRefreshing]; // start the spinner
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        // convert it to a Property List (NSArray and NSDictionary)
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        
        // get the NSArray of photo NSDictionarys out of the results
        NSArray *topPlaces = [propertyListResults valueForKeyPath: FLICKR_RESULTS_PLACES];

        NSDictionary *places = [self placesByCountry: (NSArray *) topPlaces];
                
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.places = places;
        });
    });
}

- (NSDictionary *) placesByCountry: (NSArray *) places {
    
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionary];
    
    for (NSDictionary *place in places) {
        NSString *content = [place valueForKey: @"_content"];
        NSArray *temp = [content componentsSeparatedByString: @", "];
        NSString *country = [temp lastObject];
        
        if (![returnDict valueForKey: country]) {
            [returnDict setValue: @[place] forKey: country];
        } else {
            NSMutableArray *temp = [NSMutableArray arrayWithArray: [returnDict valueForKey: country]];
            [temp addObject: place];
            [returnDict setValue: temp forKey: country];
        }
    }
    
    for (NSString *key in [returnDict allKeys]) {
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray: [returnDict objectForKey: key]];
        [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[obj1 valueForKey: @"woe_name"] compare: [obj2 valueForKey: @"woe_name"] options: 1];
        }];
        [returnDict setValue: arr forKey: key];
    }
    
    return returnDict;
}



#pragma mark - UITableViewDataSourse

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.places allKeys] count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[self.places allKeys] objectAtIndex: section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self.places valueForKey: [[self.places allKeys] objectAtIndex: section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSArray *places = [self.places valueForKey: [[self.places allKeys] objectAtIndex: indexPath.section]];
    NSDictionary *place = [places objectAtIndex: indexPath.row];
    
    cell.textLabel.text = [place valueForKey: @"woe_name"];
    cell.detailTextLabel.text = [place valueForKey: @"_content"];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: @"Photo at Place"]) {
        if ([segue.destinationViewController isKindOfClass: [PhotoAtPlaceTableViewController class]]) {
            PhotoAtPlaceTableViewController *photoVC = (PhotoAtPlaceTableViewController *) segue.destinationViewController;
            
            NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
            NSArray *places = [self.places valueForKey: [[self.places allKeys] objectAtIndex: indexPath.section]];
            NSDictionary *place = [places objectAtIndex: indexPath.row];
            
            photoVC.placeId = [place valueForKey: FLICKR_PLACE_ID];
        }
    }
}


@end
