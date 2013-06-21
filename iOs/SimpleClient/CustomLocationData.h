//
//  CustomLocationData.h
//  SimpleClient
//
//  Created by Olivier GOSSE-GARDET on 11/06/13.
//  Copyright (c) 2013 Hubiquitus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface CustomLocationData : NSObject{

}
@property(readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property(readonly, nonatomic) CLLocationDistance altitude;
@property(readonly, nonatomic) CLLocationAccuracy horizontalAccuracy;
@property(readonly, nonatomic) CLLocationAccuracy verticalAccuracy;

@property(readonly, nonatomic) NSDate *timestamp;
@property(readonly, nonatomic) CLLocationSpeed measuredSpeed;
@property( nonatomic) CLLocationSpeed calculatedSpeed;
@property( nonatomic) float distanceFormLastLocation;



-(id)initWithCLLocation:(CLLocation *)loc;

@end
