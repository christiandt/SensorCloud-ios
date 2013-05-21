//
//  DetailViewController.m
//  SensorCloud
//
//  Created by Christian Brunner on 5/18/13.
//  Copyright (c) 2013 Christian Brunner. All rights reserved.
//

#import "DetailViewController.h"
#import "Port.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem)
    {
        Port* port = self.detailItem;
        
        self.feedID.text = [[port feedID] stringValue];
        self.datastreamID.text = [port datastreamID];
        self.icon.text = [[port icon] stringValue];
    }
}

- (void)save:(id)sender
{
    if (self.detailItem)
    {
        Port* port = self.detailItem;
        [port setFeedIDWithNumber:[NSNumber numberWithInt:[self.feedID.text integerValue]]];
        [port setDatastreamIDWithString:self.datastreamID.text];
        [port setIconWithNumber:[NSNumber numberWithInt:[self.icon.text integerValue]]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;

    [self configureView];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
