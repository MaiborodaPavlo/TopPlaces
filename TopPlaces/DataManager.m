//
//  DataManager.m
//  TopPlaces
//
//  Created by Pavel on 27.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@property (strong, nonatomic) NSMutableArray *array;

@end

static NSString *kViewedPhoto = @"ViewedPhoto";

@implementation DataManager

+ (DataManager *) sharedManager {

    static DataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    
    return manager;
}

- (NSMutableArray *) array {
    
    if (!_array) _array = [NSMutableArray array];
    return _array;
}

- (void) addViewedPhoto: (NSDictionary *) photo {
    
    self.array = [NSMutableArray arrayWithArray: [self viewedPhotos]];
    
    if ([self.array count] != 0) {
        if (![self.array containsObject: photo]) {
            [self.array insertObject: photo atIndex: 0];
        } else {
            [self.array removeObject: photo];
            [self.array insertObject: photo atIndex: 0];
        }
        
        if ([self.array count] > 20) {
            [self.array removeLastObject];
        }
    } else {
        [self.array addObject: photo];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject: self.array forKey: kViewedPhoto];
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *) viewedPhotos {
    
    return [[NSUserDefaults standardUserDefaults] arrayForKey: kViewedPhoto];
}

@end
