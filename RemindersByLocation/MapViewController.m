//
//  MapViewController.m
//  RemindersByLocation
//
//  Created by Stephen on 2/8/15.
//  Copyright (c) 2015 Sherwood. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) MKPointAnnotation *selectedAnnotation;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup map view
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    
    // setup location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        NSLog(@"current status is %d", [CLLocationManager authorizationStatus]);
        
        if ([CLLocationManager authorizationStatus] == 0) {
            [self.locationManager requestAlwaysAuthorization];
            
        } else {
            self.mapView.showsUserLocation = true;
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    } else {
        //warn the user that location services are not currently enabled
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    circleRenderer.fillColor = [UIColor blueColor];
    circleRenderer.strokeColor = [UIColor redColor];
    circleRenderer.alpha = 0.5;
    return circleRenderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1800, 1800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

//MARK: LOCATION MANAGER

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@" the new status is %d", status);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = locations.firstObject;
    NSLog(@"latitide: %f and longitude: %f",location.coordinate.latitude, location.coordinate.longitude);
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    NSLog(@"did enter region");
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"region entered!";
    localNotification.alertAction = @"region action";
    //localNotification.fireDate = //some Date
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

//MARK: ANNOTATIONS

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
   
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationView"];
    annotationView.animatesDrop = true;
    annotationView.pinColor = MKPinAnnotationColorPurple;
    annotationView.canShowCallout = true;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    self.selectedAnnotation = view.annotation;
    [self performSegueWithIdentifier:@"SHOW_DETAIL" sender:self];
    NSLog(@"button tapped");
}

@end
