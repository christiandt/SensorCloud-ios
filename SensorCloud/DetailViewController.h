//
//  DetailViewController.h
//  SensorCloud
//
//  Created by Christian Brunner on 5/18/13.
//  Copyright (c) 2013 Christian Brunner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITextField *feedID;
@property (weak, nonatomic) IBOutlet UITextField *datastreamID;
@property (weak, nonatomic) IBOutlet UITextField *icon;

@end
