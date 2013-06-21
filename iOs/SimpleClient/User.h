//
//  User.h
//  SimpleClient
//
//  Created by Olivier GOSSE-GARDET on 05/06/13.
//  Copyright (c) 2013 Hubiquitus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    NSMutableArray *locationBuffer;
    
    int slidingWindowStartPos;
    CLLocationSpeed accumulatedSpeed;
    CLLocationSpeed slidingAverageSpeed;
    
    int tickCount;
    CLLocation *prevTickLocation;
    
    CLLocationSpeed currentInstantaneousSpeed;
    
    int state;
    CLLocation *stopLocation;
    
    
}
@property (retain,atomic) CLLocationManager *locationManager;
@property (retain,atomic) CLLocation *currentLocationData;
@property (atomic) CLLocationSpeed currentInstantaneousSpeed;
@property (atomic) CLLocationSpeed slidingAverageSpeed;


- (void)startStandardUpdates;


@end
