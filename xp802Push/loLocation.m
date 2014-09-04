//
//  loLocation.m
//  xp802Push
//
//  Created by Lova on 2014/2/26.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loLocation.h"
#import "loConnectPHP.h"

loLocation* location;
CLLocation* currentLocation;
@implementation loLocation

-(id)init
{
    self=[super init];
    if (self) {
        if (_locationManager==nil) {
            _locationManager=[CLLocationManager new];                               //
            _locationManager.delegate=self;                                         //沒指定的話會不work  like IB delegate
            _locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;            //期待的精確度
            _locationManager.distanceFilter=20;
            _locationManager.activityType=CLActivityTypeOtherNavigation;            //這次的導航屬於什麼樣的活動  例如車輛導航
            [_locationManager startUpdatingLocation];
          //  [_locationManager startUpdatingHeading];                                // startUpdatingHeading(這是電子羅盤)
        }
    }

    
    
    return self;
}

+ (loLocation *)sharedInstance
{
    if (location==nil) {
        location=[[loLocation alloc]init];
    }
    
    return location;
}


#pragma mark - core location delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"radarHeading" object:newHeading];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation=[locations lastObject];
    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`users` SET  `latitude` =  '%f',`longitude` =  '%f' WHERE  `users`.`token_id` =  '%@';",
                                               currentLocation.coordinate.latitude,
                                               currentLocation.coordinate.longitude,
                                               [loConnectPHP shareInstance].plistDict[@"token_id"]]
                                    afterSYNC:-1 Completion:^{
                                        [self getAnnos];
                                    }];
}

-(void)getAnnos
{
    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"SELECT latitude , longitude FROM `users` where group_id='%@'",
                                               [loConnectPHP shareInstance].plistDict[@"group_id"]]
                                                               afterSYNC:loAfterASYNC_DO_getUsersLocation
                                                              Completion:^{
        //set annos on view
                                                                  [loConnectPHP shareInstance].usersPoint=nil;
                                                                  
                                                                  [self coordinate_to_point];
                                                                  
                                                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"setAnnos" object:nil];
                                                                  
    }];
}

-(void)coordinate_to_point
{
    NSMutableArray* arrayForUsersLocation=[[NSMutableArray alloc]init];
    NSMutableArray* arrayForUsersDistance=[[NSMutableArray alloc]init];
    NSMutableArray* arrayForUsersDirection=[[NSMutableArray alloc]init];
    NSMutableArray* arrayForUsersPoint=     [[NSMutableArray alloc]init];
    
    
    
    for (NSDictionary* dict in [loConnectPHP shareInstance].UsersLocation) {
    
        CLLocation* user=[[CLLocation alloc]initWithLatitude:[dict[@"latitude" ] doubleValue]
                                                   longitude:[dict[@"longitude"] doubleValue]];
        
        [arrayForUsersLocation addObject:user];

        [arrayForUsersDistance addObject:[NSNumber numberWithDouble:[currentLocation distanceFromLocation:user]] ];
  
        [currentLocation distanceFromLocation:user];
    }
    
    
    //抓出max distance 放到arrayForUsersDistance[0]   然後arrayForUsersLocation跟隨一樣順序
    for (int i =0; i<[arrayForUsersDistance count]; i++) {
        
        if ([arrayForUsersDistance[i] doubleValue]>[arrayForUsersDistance[0] doubleValue]) {
            id temp=arrayForUsersDistance[i];
            arrayForUsersDistance[i]=arrayForUsersDistance[0];
            arrayForUsersDistance[0]=temp;
            
            temp=arrayForUsersLocation[i];
            arrayForUsersLocation[i]=arrayForUsersLocation[0];
            arrayForUsersLocation[0]=temp;
        }
        
    }
    
    for (CLLocation* location in arrayForUsersLocation) {
        [self calculateTheDirectionAndDistanceAboutLocation:location
                                                fromLocaion:currentLocation];
//        NSLog(@"location = %@",location);
        [arrayForUsersDirection addObject:[NSNumber numberWithDouble:[self calculateTheDirectionAndDistanceAboutLocation:location
                                                                                                             fromLocaion:currentLocation]]];
    }
    
    NSLog(@"arrayForUsersLocation %@ ",arrayForUsersLocation);
    NSLog(@"arrayForUsersDistance %@",arrayForUsersDistance);
    NSLog(@"arrayForUserDirection %@",arrayForUsersDirection);
    
    
    [loConnectPHP shareInstance].usersDirection=arrayForUsersDirection;
    
    double maxDistance=[arrayForUsersDistance[0] doubleValue];
    
    double multiple= maxDistance /140;
    
    
    for (int i = 0; i< [arrayForUsersDirection count]; i++) {
       
        double angle=[arrayForUsersDirection[i] doubleValue] ;
        
        double x = [arrayForUsersDistance[i] doubleValue] / multiple * cos( angle );
        
        double y = [arrayForUsersDistance[i] doubleValue] / multiple * sin( angle );
        
        
        
        
        CGPoint point =CGPointMake( (float) x , (float)y);
        
        [arrayForUsersPoint addObject:[NSValue valueWithCGPoint:point]];
        

    }
    NSLog(@"%@",arrayForUsersPoint);
    [loConnectPHP shareInstance].usersPoint = arrayForUsersPoint;
}

-(double)calculateTheDirectionAndDistanceAboutLocation:(CLLocation *)aLocation fromLocaion:(CLLocation *)regionLocation
{
//低緯度適用
    double x1 = regionLocation.coordinate.latitude;
    double y1 = regionLocation.coordinate.longitude;
    double x2 = aLocation.coordinate.latitude;
    double y2 = aLocation.coordinate.longitude;
    
    double aRad = atan2(y2-y1, x2-x1);
    
    return aRad;
}







@end
