//
//  User.m
//  SimpleClient
//
//  Created by Olivier GOSSE-GARDET on 05/06/13.
//  Copyright (c) 2013 Hubiquitus. All rights reserved.
//

#import "User.h"
#import "DDLog.h"
#import <CoreLocation/CoreLocation.h>
#import "CustomLocationData.h"

#define MAX_BUFFER_SIZE 20000
#define SLIDING_WINDOW_SIZE 60

#define TICK_DURATION 1
#define TICK_COUNT_LOCATION 2


#define STARTING 1
#define DRIVING 10
#define STOPPED 20
#define PHASE0  30
#define PHASE1  40
#define PHASE2  50

@implementation User
@synthesize locationManager;
@synthesize currentLocationData;
@synthesize currentInstantaneousSpeed;
@synthesize slidingAverageSpeed;

- (void)startStandardUpdates
{
    DDLogInfo(@"Démarrage");
    slidingAverageSpeed = 0;
    slidingWindowStartPos = 0;
    tickCount = 0;

    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager){
        locationManager = [[CLLocationManager alloc] init];    
    }
    if (CLLocationManager.locationServicesEnabled == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    // Set a movement threshold for new events.
    locationManager.distanceFilter = 5;
    
    [locationManager startUpdatingLocation];
    locationBuffer= [[NSMutableArray alloc] initWithCapacity:1200];
    
    [NSTimer scheduledTimerWithTimeInterval:TICK_DURATION target:self selector:@selector(locationTick) userInfo:NULL repeats:true];
}
// Calculate instantaneous speed each tick.
// Catch location every tick_count tick
-(void)locationTick{
    tickCount+=1;
    if(prevTickLocation == NULL ){
        // First position, waiting for next one
        prevTickLocation = currentLocationData;
    }else if(prevTickLocation == currentLocationData ){
        DDLogInfo(@"NoChange");
        // DO Nothing
    }else{
        CLLocationDistance dist = [currentLocationData distanceFromLocation:prevTickLocation];
        NSTimeInterval interval =[currentLocationData.timestamp timeIntervalSince1970] - [prevTickLocation.timestamp timeIntervalSince1970] ;
    
        currentInstantaneousSpeed = dist/interval;
        DDLogInfo(@"%f,%f",dist,interval);
        DDLogInfo(@"latitude %+.6f, longitude %+.6f, dist%+.2f, speed%+.2f",
              currentLocationData.coordinate.latitude,
              currentLocationData.coordinate.longitude,
              dist,
                currentInstantaneousSpeed
              );
        prevTickLocation = currentLocationData;
    }
    if((tickCount % TICK_COUNT_LOCATION )== 0){
        CustomLocationData *data= [[CustomLocationData alloc] initWithCLLocation:currentLocationData];
        [self getLocation:data];
    }
}

-(void)getLocation:(CustomLocationData *)data{
    data.calculatedSpeed = currentInstantaneousSpeed;

    DDLogInfo(@">> latitude %+.6f, longitude %+.6f, speed%+.2f",
              data.coordinate.latitude,
              data.coordinate.longitude,
              data.calculatedSpeed
              );
    
    [locationBuffer addObject:data];
    // Manage the global buffers
    if(locationBuffer.count > MAX_BUFFER_SIZE){
        [locationBuffer removeObjectAtIndex:0];
    }
    // Manage the sliding windows buffer
    slidingWindowStartPos = locationBuffer.count - SLIDING_WINDOW_SIZE;
    
    if(slidingWindowStartPos > 0){
        CustomLocationData *outsideWindowLocation = (CustomLocationData *)[locationBuffer objectAtIndex:slidingWindowStartPos];
        accumulatedSpeed -= outsideWindowLocation.calculatedSpeed;
    }
    accumulatedSpeed += data.calculatedSpeed;
    slidingAverageSpeed = accumulatedSpeed / SLIDING_WINDOW_SIZE;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationSucceed" object:nil userInfo:
    NULL];

}

-(void)detectState{
    if(state == STARTING){
        if(currentInstantaneousSpeed > 2*INSTANTANEOUS_SPEED_THRESOLD){
            state = DRIVING;
        }
    }else if (state == DRIVING){
        if(currentInstantaneousSpeed == 0.0){
            state = STOPPED;
            stopLocation = currentLocationData;
        }
    }else if (state == STOPPED){
        // Check if the user started driving
        if(currentInstantaneousSpeed > 2*INSTANTANEOUS_SPEED_THRESOLD){
            state = DRIVING;
            return;
        }
    
        if(slidingAverageSpeed < SLIDING_AVERAGE_SPEED_THRESOLD){
            if(stopLocation != NULL && [stopLocation distanceFromLocation:currentLocationData] < DISTANCE_THRESOLD){
                state = PHASE0;
            }else{
                state = PHASE1;
            }
        }
    }else if(state == PHASE0){
        if([stopLocation distanceFromLocation:currentLocationData] > DISTANCE_THRESOLD){
            state = PHASE1;
        }
        
    }else if (state == PHASE1){
        if([stopLocation distanceFromLocation:currentLocationData] < DISTANCE_THRESOLD){
            state = PHASE2;
        }else{
            if(slidingAverageSpeed > SLIDING_AVERAGE_SPEED_THRESOLD){
                state = DRIVING;
                stopLocation == null;
            }else{
                // Nothing to do
            }
        }
        
    }else if (state == PHASE2){
        if([stopLocation distanceFromLocation:currentLocationData] > DISTANCE_THRESOLD){
            state = STARTING;
            stopLocation = NULL;
        }
    }
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    DDLogInfo(@"didUpdateLocations");
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        self.currentLocationData = location;
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    DDLogVerbose(@"ERROR1");
    if ([error code] != kCLErrorLocationUnknown) {
        DDLogInfo(@"ERROR");
//        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}


@end
