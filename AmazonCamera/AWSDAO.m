//
//  DAO.m
//  AmazonCamera
//
//  Created by Angie Chilmaza on 10/1/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import "AWSDAO.h"
#import "Constants.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

@interface AWSDAO ()

@end


@implementation AWSDAO

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [[NSMutableArray alloc]init];
    }
    return self;
}


//Singleton
+(instancetype)sharedDAOInstance {
    
    static id _sharedDAOInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedDAOInstance = [[self alloc] init];
    });
    
    return _sharedDAOInstance;
}


-(void)loadData{
    
    AWSS3* s3 = [AWSS3 defaultS3];
    
    AWSS3ListObjectsRequest * listObjectsRequest = [[AWSS3ListObjectsRequest alloc] init];
    listObjectsRequest.bucket = S3BucketName;
    
    [[s3 listObjects:listObjectsRequest] continueWithBlock:^id(AWSTask *task) {
       
        if(task.error){
            NSLog(@"listObjects failed: %@ \n", task.error);
        }
        else{
            
            AWSS3ListObjectsOutput * listObjectsOutput = task.result;
            
            if(self.data){
                if([self.data count]){
                    [self.data removeAllObjects];
                }
            }
            
            for(AWSS3Object * s3Object in listObjectsOutput.contents){
               // NSLog(@"s3Object = %@ \n", s3Object);
                [self.data addObject:s3Object.key];
            }
        }
        
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.f * NSEC_PER_SEC), dispatch_get_main_queue(),
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate reloadData];
        });
        
        
        return nil;
    }];
    
}

-(void)downloadData:(NSString*)filename{
    
    AWSS3TransferManager * transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    NSString* downloadFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"downloaded-%@",filename]];
    NSURL * downloadingFileURL = [NSURL fileURLWithPath:downloadFilePath];
    
    AWSS3TransferManagerDownloadRequest * downloadRequest = [[AWSS3TransferManagerDownloadRequest alloc] init];
    downloadRequest.bucket = S3BucketName;
    downloadRequest.key = filename;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    [[transferManager download:downloadRequest] continueWithBlock:^id(AWSTask *task) {
        
        if(task.error){
            
            if([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]){
                switch(task.error.code){
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                    default:
                        NSLog(@"Error %@\n", task.error);
                        break;
                }
            }
            else{
                NSLog(@"Error: %@ \n", task.error);
            }
        }
        
        if(task.result){
            NSLog(@"task.result.body = %@ \n", [task.result body]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.delegate dataDownloaded:[task.result body]];
            });
        }
        
        return nil;
    }];
    
}

-(void)uploadData:(NSData*)data filename:(NSString*)filename{
    
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"upload-%@", filename]];
    [data writeToFile:filePath atomically:YES];
    
    AWSS3TransferManagerUploadRequest * uploadRequest = [[AWSS3TransferManagerUploadRequest alloc]init];
    uploadRequest.body = [NSURL fileURLWithPath:filePath];
    uploadRequest.key  = filename;
    uploadRequest.bucket = S3BucketName;
    
    AWSS3TransferManager * transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        
        if(task.error){
            
            NSLog(@"upload failed: %@ \n", task.error);
            
        }else{
    
            if(task.result){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.data addObject:filename];
                    [self.delegate reloadData];
                    
                });
            
            }
        }
        
        return nil;
        
    }];
    
    
}


-(void)deleteData:(NSUInteger)index completionHandler:(void (^)(NSError*error))completionHandler{
    
    AWSS3 *s3 = [AWSS3 defaultS3];
    //AWSS3Object * s3Object = [self.data objectAtIndex:index];
    NSString * key = [self.data objectAtIndex:index];
    
    AWSS3DeleteObjectRequest *deleteObjectRequest = [[AWSS3DeleteObjectRequest alloc]init];
    deleteObjectRequest.bucket = S3BucketName;
    deleteObjectRequest.key = key;
    
    [[s3 deleteObject:deleteObjectRequest] continueWithBlock:^id(AWSTask *task) {
        
        if(!task.error){
            [self.data removeObjectAtIndex:index];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(task.error);
        });
        
        return nil;

    }];
    
}

@end
