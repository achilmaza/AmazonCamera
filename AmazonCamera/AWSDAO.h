//
//  DAO.h
//  AmazonCamera
//
//  Created by Angie Chilmaza on 10/1/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AWSDAODelegate <NSObject>

-(void)reloadData;
-(void)dataDownloaded:(NSURL*)filePath;

@end

@interface AWSDAO : NSObject

@property (nonatomic, strong) NSMutableArray * data;
@property (nonatomic, weak) id <AWSDAODelegate> delegate;

+(instancetype)sharedDAOInstance;
-(void)loadData;
-(void)downloadData:(NSString*)filename;
-(void)uploadData:(NSData*)data filename:(NSString*)filename;
-(void)deleteData:(NSUInteger)index completionHandler:(void (^)(NSError*error))completionHandler;

@end
