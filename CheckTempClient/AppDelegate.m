//
//  AppDelegate.m
//  CheckTempClient
//
//  Created by Davide Fresilli on 21/06/16.
//  Copyright © 2016 Davide Fresilli. All rights reserved.
//

#import "AppDelegate.h"


NSTimer *t;
int presses = 0, FrequencyValueSlider = 2;
NSString *ipForConnection, *correctedPath;


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

-(IBAction)SelectDirectoryLog:(id)sender{
    
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"CheckTempLog.csv"];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) {
            NSFileManager *manager = [NSFileManager defaultManager];
            NSURL *SavingDirectory = [panel URL];
            correctedPath = [[SavingDirectory absoluteString] substringFromIndex:7];
        }
    }];
    
}

-(void)onTick:(NSTimer *)timer {
    
    NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat: @"http://%@", ipForConnection]];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSMutableArray *dataArray = [[dataString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];

    
    //Updating the value of the datasets
    
    //parsing raw data to corrected values
    
    int clkValue = [[dataArray objectAtIndex:2] intValue];
    NSString *clkCorrectedValuetoDisplay = [NSString stringWithFormat: @"%i", clkValue/1000000]; //hz to mhz
    float tempValue = [[dataArray objectAtIndex:0] floatValue];
    NSString *tempCorrectedValue = [[NSString stringWithFormat:@"%f", tempValue/1000]substringToIndex:5];
    
    [TemperatureData setStringValue:tempCorrectedValue];
    [CoreVoltageData setStringValue:[dataArray objectAtIndex:1]];
    [CoreClockData setStringValue:clkCorrectedValuetoDisplay];
    [SystemLoadData setStringValue:[dataArray objectAtIndex:3]];

    if([exportToCsv state] == 1){
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"hh:mm:ss"];
    
    NSString *content = [NSString stringWithFormat:@"%@, %@, %@, %@, %@\n",[DateFormatter stringFromDate:[NSDate date]], tempCorrectedValue, [dataArray objectAtIndex:1], clkCorrectedValuetoDisplay, [dataArray objectAtIndex:3]];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:correctedPath];
    if (fileHandle){
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else{
        [content writeToFile:correctedPath
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
    }else{
        
        //do nothing
    }
   // NSLog(@"Data : %@",correctedPath);

}

@end
