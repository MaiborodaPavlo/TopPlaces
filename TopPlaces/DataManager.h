//
//  DataManager.h
//  TopPlaces
//
//  Created by Pavel on 27.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject


+ (DataManager *) sharedManager;

- (void) addViewedPhoto: (NSDictionary *) photo;
- (NSArray *) viewedPhotos;

@end
