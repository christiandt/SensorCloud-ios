//
//  SingleViewController.m
//  SensorCloud
//
//  Created by Christian Brunner on 5/18/13.
//  Copyright (c) 2013 Christian Brunner. All rights reserved.
//

#import "SingleViewController.h"
#import "XivelyAPI.h"

@interface SingleViewController ()
@end

@implementation SingleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // set the API key for Xively
    NSString* apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"XivelyApiKey"];
    if (apiKey == nil)
        apiKey = @"txvM3AzitVGjBZCHJZgRsTHANCYOkDmkWEUTqOCnuGGSdxwe";
    
    self.xivelyApiKey.text = apiKey;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pressedSetApiKey:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.xivelyApiKey.text forKey:@"XivelyApiKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[XivelyAPI defaultAPI] setApiKey:self.xivelyApiKey.text];
}

@end
