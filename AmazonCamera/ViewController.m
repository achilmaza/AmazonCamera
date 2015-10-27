//
//  ViewController.m
//  AmazonCamera
//
//  Created by Angie Chilmaza on 9/30/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import "ViewController.h"
#import "AWSDAO.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AWSDAO * awsdao;
@property (nonatomic, strong) UIImagePickerController * imagePicker;
//@property (nonatomic, strong) UIPopoverController * popover;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.awsdao = [AWSDAO sharedDAOInstance];
    self.awsdao.delegate = self;
    
    [self.awsdao loadData];
    
}


#pragma mark Lazy Loading

-(UIImagePickerController*)imagePicker{
    
    if(!_imagePicker){
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    
    return _imagePicker;
}


#pragma mark AWSDAODelegate

-(void)reloadData{
    
    [self.tableView reloadData];
}

-(void)dataDownloaded:(NSURL*)filePath{
    
    if(filePath){
        NSLog(@"filePath = %@ \n", filePath);
        NSData * data = [NSData dataWithContentsOfURL:filePath];
        self.imageView.image = [UIImage imageWithData:data];
    }
    
}

#pragma mark IBAction

- (IBAction)selectPhoto:(id)sender {
    
   [self presentViewController:self.imagePicker animated:YES completion:NULL];
   //upload image
    
}

- (IBAction)editPhoto:(id)sender {
    
    //delete code
}

-(IBAction)edit:(id)sender{
    if([self.tableView isEditing]){
        [sender setTitle:@"Edit"];
    }
    else{
        [sender setTitle:@"Done"];
    }
    
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
}



#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSLog(@"[self.awsdao data] count] = %lu \n", [[self.awsdao data] count]);
    
    return [[self.awsdao data] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"UITableViewCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[self.awsdao data] objectAtIndex:[indexPath row]];
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
       
        [self.awsdao deleteData:[indexPath row] completionHandler:^(NSError*error){
            
            if(error){
                
                [self alertView:@"Delete error" withMsg:[error.userInfo objectForKey:@"error"]];
            }
            else{
            
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }];
        
        
    }
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* filename = [NSString stringWithFormat:@"%@", [[self.awsdao data] objectAtIndex:[indexPath row]]];
   [self.awsdao downloadData:filename];
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.imageView setImage:image];
    
    NSData * imageData = UIImageJPEGRepresentation(image,1.0);
    NSString * filename = [[NSString alloc] initWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970]];
    
    [self.awsdao uploadData:imageData filename:filename];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Alert

-(void)alertView:(NSString*)title withMsg:(NSString*)msg{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:^{}];
    
}

@end
