//
//  ViewController.h
//  AmazonCamera
//
//  Created by Angie Chilmaza on 9/30/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWSDAO.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AWSDAODelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>


@end

