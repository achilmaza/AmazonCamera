//
//  Constants2.h
//  AmazonCamera
//
//  Created by Angie Chilmaza on 10/1/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>

FOUNDATION_EXPORT NSString * const S3BucketName;
FOUNDATION_EXPORT NSString * const CognitoIdentityPool;
FOUNDATION_EXPORT AWSRegionType const CognitoRegionType;
FOUNDATION_EXPORT NSString * const accessKey;
FOUNDATION_EXPORT NSString * const secretKey;

@interface Constants: NSObject

+(NSString *)uploadBucket;

@end