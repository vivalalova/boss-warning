//
//  loLocation.h
//  xp802Push
//
//  Created by Lova on 2014/2/26.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface loLocation : NSObject<CLLocationManagerDelegate>



@property (strong,nonatomic) CLLocationManager*  locationManager;


+ (loLocation *)sharedInstance;


@end
