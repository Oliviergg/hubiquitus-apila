//
//  CustomLocationData.m
//  SimpleClient
//
//  Created by Olivier GOSSE-GARDET on 11/06/13.
//  Copyright (c) 2013 Hubiquitus. All rights reserved.
//

#import "CustomLocationData.h"

@implementation CustomLocationData
@synthesize verticalAccuracy;
@synthesize horizontalAccuracy;
@synthesize coordinate;
@synthesize timestamp;

@synthesize calculatedSpeed;
@synthesize measuredSpeed;
@synthesize distanceFormLastLocation;

-(id)initWithCLLocation:(CLLocation *)loc{
    if(self = [super init]){
        coordinate = loc.coordinate;
        timestamp = loc.timestamp;
        calculatedSpeed = loc.speed;
        measuredSpeed = 0.0;
        timestamp = loc.timestamp;
    }
    return self;
}

@end
