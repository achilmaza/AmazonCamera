//
//  Constants2.m
//  AmazonCamera
//
//  Created by Angie Chilmaza on 10/1/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import "Constants.h"

NSString * const S3BucketName = @"";
NSString * const CognitoIdentityPool = @"";
AWSRegionType const CognitoRegionType = AWSRegionUSEast1;
NSString * const accessKey = @"";
NSString * const secretKey = @"";


@implementation Constants

+(NSString *)uploadBucket
{
    return [[NSString stringWithFormat:@"%@-%@", S3BucketName, accessKey] lowercaseString];
}

@end