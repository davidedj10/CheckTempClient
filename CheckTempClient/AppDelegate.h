//
//  AppDelegate.h
//  CheckTempClient
//
//  Created by Davide Fresilli on 21/06/16.
//  Copyright © 2016 Davide Fresilli. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

{
    
    IBOutlet NSButton *StartLoggingButton;
    IBOutlet NSSlider *LoggingFrequency;
    IBOutlet NSTextField *LoggingFrequencyValue;
    
    IBOutlet NSTextField *TemperatureData;
    IBOutlet NSTextField *CoreVoltageData;
    IBOutlet NSTextField *CoreClockData;
    IBOutlet NSTextField *SystemLoadData;
    
    IBOutlet NSTextField *deviceIPaddr;
    
}


-(IBAction)FrequencyUpdate:(id)sender;
-(IBAction)StartLogging:(id)sender;

@end

