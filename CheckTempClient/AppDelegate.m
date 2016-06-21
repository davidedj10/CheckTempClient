//
//  AppDelegate.m
//  CheckTempClient
//
//  Created by Davide Fresilli on 21/06/16.
//  Copyright © 2016 Davide Fresilli. All rights reserved.
//

#import "AppDelegate.h"


NSTimer *t;
int presses = 0, FrequencyValueSlider = 0;
NSString *ipForConnection;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   
    NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(onTick:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sgn];
    [inv setTarget: self];
    [inv setSelector:@selector(onTick:)];
    
    t = [NSTimer timerWithTimeInterval:FrequencyValueSlider
                                     invocation:inv
                                        repeats:YES];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)FrequencyUpdate:(id)sender{
    
    FrequencyValueSlider = LoggingFrequency.intValue;
    [LoggingFrequencyValue setStringValue:[NSString stringWithFormat: @"%i", FrequencyValueSlider]];
    
}

-(IBAction)StartLogging:(id)sender{
    
    if(presses == 0){
     NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: t forMode: NSDefaultRunLoopMode];
    }else{
        
        [t invalidate];
    }
    
    NSString *ipAddress = deviceIPaddr.stringValue;
    
    ipForConnection =[ipAddress stringByAppendingString:@":8080"];
    
    [StartLoggingButton setTitle:@"Stop"];
    presses++;
}


-(void)onTick:(NSTimer *)timer {
    
    NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat: @"http://%@", ipForConnection]];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSMutableArray *dataArray = [[dataString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];

    
    //Updating the value of the datasets
    
    [TemperatureData setStringValue:[dataArray objectAtIndex:0]];
    [CoreVoltageData setStringValue:[dataArray objectAtIndex:1]];
    [CoreClockData setStringValue:[dataArray objectAtIndex:2]];
    [SystemLoadData setStringValue:[dataArray objectAtIndex:3]];
    
    NSLog(@"Data : %i",FrequencyValueSlider);

}

@end
