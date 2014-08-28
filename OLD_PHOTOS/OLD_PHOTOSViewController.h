//
//  OLD_PHOTOSViewController.h
//  OLD_PHOTOS
//
//  Created by 井島 一貴 on 13/04/10.
//  Copyright (c) 2013年 209crc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLD_PHOTOSAppDelegate.h"

@interface OLD_PHOTOSViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	OLD_PHOTOSAppDelegate * opad;
	
	bool isRequireTakePhoto;
	bool isProcessingTakePhoto;
	void *bitmap;
	
	AVCaptureSession *_session;
	UIImageView *imgView;
	
	UIImageView *oldImgView;
	
	UIButton *shutterBtn;
	UIButton *settingBtn;
	UIButton *infoBtn;
	
	UIImageView *menuView;

	UIButton *camerarollBtn;
	
	UILabel *alphaLbl;
	UIButton *alphaBtn;
	UISlider *alphaSld;
	
	UILabel *rotateLbl;
	UIButton *leftRotate;
	UIButton *rightRotate;
	
	UILabel *explainLbl;
	UIButton *twitterBtn;

}

@property (nonatomic, retain) UIImage *imageBuffer;

-(IBAction) shutterBtnTapped: (UIButton *) sender;
-(IBAction) settingBtnTapped: (UIButton *) sender;
-(IBAction) infoBtnTapped: (UIButton *) sender;
-(void) setting;
-(IBAction) camerarollBtnTapped: (UIButton *) sender;
-(void) camerarollSet;
-(IBAction) alphaBtnTapped:(UIButton *) sender;
-(IBAction) alphaSldChanged: (UISlider *) sender;
-(IBAction) leftRotateTapped: (UISlider *) sender;
-(IBAction) rightRotateTapped: (UISlider *) sender;
-(void) rotateTrans;
-(void) setSettingInfoBtnEnable;
-(IBAction) twitterBtnTapped: (UIButton *) sender;

@end
