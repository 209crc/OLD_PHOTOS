//
//  OLD_PHOTOSAppDelegate.h
//  OLD_PHOTOS
//
//  Created by 井島 一貴 on 13/04/10.
//  Copyright (c) 2013年 209crc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define FONT_NAME @"Arial-ItalicMT"

@class OLD_PHOTOSViewController;

@interface OLD_PHOTOSAppDelegate : UIResponder <UIApplicationDelegate> {
	NSInteger displayWidth;
	NSInteger displayHeight;
	NSInteger statusbarHeight;
	
	NSInteger numWidth;
	NSInteger fontSize;
	UIColor *fontColor;
	
	CGAffineTransform scaleTrans;
	CGAffineTransform leftRotateTrans;
	CGAffineTransform rightRotateTrans;
	CGAffineTransform reverseTrans;
	CGAffineTransform idleTrans;
	
	CGAffineTransform upTrans;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OLD_PHOTOSViewController *viewController;
@property (nonatomic) NSInteger displayWidth;
@property (nonatomic) NSInteger displayHeight;
@property (nonatomic) NSInteger statusbarHeight;
@property (nonatomic) NSInteger numWidth;
@property (nonatomic) NSInteger fontSize;
@property (nonatomic) UIColor *fontColor;

@property (nonatomic) CGAffineTransform scaleTrans;
@property (nonatomic) CGAffineTransform leftRotateTrans;
@property (nonatomic) CGAffineTransform rightRotateTrans;
@property (nonatomic) CGAffineTransform reverseTrans;
@property (nonatomic) CGAffineTransform idleTrans;
@property (nonatomic) CGAffineTransform upTrans;

@end
