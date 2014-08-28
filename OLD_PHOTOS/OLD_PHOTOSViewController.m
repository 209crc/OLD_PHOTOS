//
//  OLD_PHOTOSViewController.m
//  OLD_PHOTOS
//
//  Created by 井島 一貴 on 13/04/10.
//  Copyright (c) 2013年 209crc. All rights reserved.
//

#import "OLD_PHOTOSViewController.h"

@interface OLD_PHOTOSViewController ()

@end

bool camerarollHasSet;
bool isSetting;
bool isInfo;
int alphaValue;
int rotateState;
NSURL *furl;
SystemSoundID idBell;

@implementation OLD_PHOTOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	opad = (OLD_PHOTOSAppDelegate *)[UIApplication sharedApplication].delegate;
	
#ifdef debug
	NSLog(@"camerarollHasSet");
#endif
	camerarollHasSet = false;
//	camerarollHasSet = true;
	
	isSetting = false;
	isInfo = false;
	alphaValue = 50;
	rotateState = 0;
		
	if (!imgView) {
		imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, opad.statusbarHeight, opad.displayWidth, opad.displayHeight)];
		[imgView setAlpha:1];
		[self.view addSubview:imgView];
	}
	if (!oldImgView) {
		oldImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, opad.statusbarHeight, opad.displayWidth, opad.displayHeight)];
		[oldImgView setAlpha:0];
		[self.view addSubview:oldImgView];
	}
	
	if (!shutterBtn) {
		shutterBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[shutterBtn setFrame:CGRectMake((opad.displayWidth - opad.numWidth * 2) / 2, opad.displayHeight - (opad.numWidth + opad.numWidth / 6), opad.numWidth * 2, opad.numWidth)];
//		[shutterBtn.titleLabel setFont:[UIFont fontWithName:@"Apple Symbols" size:opad.fontSize]];
//		[shutterBtn setTitle:@"◎" forState:UIControlStateNormal];
		[shutterBtn setBackgroundImage:[UIImage imageNamed:@"shutterBtn.PNG"] forState:UIControlStateNormal];
		[shutterBtn addTarget:self action:@selector(shutterBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:shutterBtn];
	}
	
	if (!settingBtn) {
		settingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[settingBtn setFrame:CGRectMake(opad.numWidth, opad.displayHeight - (opad.numWidth + opad.numWidth / 6), opad.numWidth, opad.numWidth)];
//		[settingBtn.titleLabel setFont:[UIFont fontWithName:@"Apple Symbols" size:opad.fontSize]];
//		[settingBtn setTitle:@"⚙" forState:UIControlStateNormal];
		[settingBtn setBackgroundImage:[UIImage imageNamed:@"settingBtn.PNG"] forState:UIControlStateNormal];
		[settingBtn addTarget:self action:@selector(settingBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:settingBtn];
	}
	
	if (!infoBtn) {
		infoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[infoBtn setFrame:CGRectMake(opad.displayWidth - opad.numWidth * 2, opad.displayHeight - (opad.numWidth + opad.numWidth / 6), opad.numWidth, opad.numWidth)];
		//		[settingBtn.titleLabel setFont:[UIFont fontWithName:@"Apple Symbols" size:opad.fontSize]];
		//		[settingBtn setTitle:@"⚙" forState:UIControlStateNormal];
		[infoBtn setBackgroundImage:[UIImage imageNamed:@"infoBtn.PNG"] forState:UIControlStateNormal];
		[infoBtn addTarget:self action:@selector(infoBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:infoBtn];
	}
	
    AVCaptureDevice *device;
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
    AVCaptureDeviceInput *deviceInput;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
	
    NSMutableDictionary *settings;
    AVCaptureVideoDataOutput *dataOutput;
    settings = [NSMutableDictionary dictionary];
    [settings setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
				 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.videoSettings = settings;
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
    _session = [[AVCaptureSession alloc] init];
    [_session addInput:deviceInput];
    [_session addOutput:dataOutput];
	
    [_session startRunning];
	

	furl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"se-033" ofType:@"mp3"]];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)furl, &idBell);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) shutterBtnTapped: (UIButton *) sender {
	if (!isProcessingTakePhoto) {
        isRequireTakePhoto = YES;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	// イメージバッファの取得
    CVImageBufferRef    buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	
    // イメージバッファのロック
    CVPixelBufferLockBaseAddress(buffer, 0);
	
    // イメージバッファ情報の取得
    uint8_t*    base;
    size_t      width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
	
    // ビットマップコンテキストの作成
    CGColorSpaceRef colorSpace;
    CGContextRef    cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
	
    // 画像の作成
    CGImageRef  cgImage;
    UIImage*    image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationRight];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);

    // イメージバッファのアンロック
    CVPixelBufferUnlockBaseAddress(buffer, 0);

    // 画像の表示
	//    _imageView.image = image;
    imgView.image = image;

	if (isRequireTakePhoto) {
		AudioServicesPlaySystemSound(idBell);
		
		ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
		[library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL* assetURL, NSError* error) {
			//アルバムにALAssetを追加する任意のメソッド
//			[self addAssetURL:assetURL AlbumURL:groupURL];
		}];
		isRequireTakePhoto = NO;
	}
	
	if (camerarollHasSet == false) {
		[self camerarollSet];
	}
}

-(IBAction) settingBtnTapped: (UIButton *) sender {
	[self setting];
}

-(void) setting {
	if (!isSetting) {
		if (!menuView) {
			menuView = [[UIImageView alloc] init];
			[menuView setImage:[UIImage imageNamed:@"menuView.PNG"]];
			[menuView setFrame:CGRectMake(opad.numWidth / 2, opad.numWidth * 2, opad.displayWidth - opad.numWidth, opad.displayHeight - opad.numWidth * 4)];
			[self.view addSubview:menuView];
		}
		[menuView setAlpha:0];
		
		if (!camerarollBtn) {
			camerarollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[camerarollBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize]];
			[camerarollBtn setTitleColor:opad.fontColor forState:UIControlStateNormal];
			[camerarollBtn setTitle:@"Set Photo" forState:UIControlStateNormal];
			[camerarollBtn setTitle:@"" forState:UIControlStateHighlighted];
			[camerarollBtn setBackgroundImage:[UIImage imageNamed:@"redLine.PNG"] forState:UIControlStateNormal];
			[camerarollBtn setBackgroundImage:[UIImage imageNamed:@"redLine.PNG"] forState:UIControlStateHighlighted];
			[camerarollBtn addTarget:self action:@selector(camerarollBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
			[camerarollBtn setFrame:CGRectMake((opad.displayWidth - opad.numWidth * 3) / 2, opad.numWidth * 2 + opad.numWidth, opad.numWidth * 3, opad.numWidth)];
			[self.view addSubview:camerarollBtn];
		}
		[camerarollBtn setAlpha:0];
		
		if (!alphaLbl) {
			alphaLbl = [[UILabel alloc] init];
			[alphaLbl setText:@"Permeation"];
			[alphaLbl setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize * 0.8]];
			[alphaLbl setTextColor:opad.fontColor];
			[alphaLbl setBackgroundColor:[UIColor clearColor]];
			[alphaLbl setFrame:CGRectMake((opad.displayWidth - opad.numWidth * 5) / 2, camerarollBtn.frame.origin.y + camerarollBtn.frame.size.height + opad.numWidth / 2, opad.numWidth * 2, opad.numWidth)];
			[self.view addSubview:alphaLbl];
		}
		[alphaLbl setAlpha:0];

		if (!alphaBtn) {
//			alphaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//			[alphaBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize]];
//			[alphaBtn setTitleColor:opad.fontColor forState:UIControlStateNormal];
//			[alphaBtn setTitle:@"alpha" forState:UIControlStateNormal];
//			[alphaBtn addTarget:self action:@selector(alphaBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//			[alphaBtn setFrame:CGRectMake((opad.displayWidth + opad.numWidth * 3 - opad.numWidth * 3) / 2, menuView.frame.origin.y + opad.numWidth, opad.numWidth * 3, opad.numWidth)];
//			[self.view addSubview:alphaBtn];
		}
		[alphaBtn setAlpha:0];
		
		if(!alphaSld) {
			alphaSld = [[UISlider alloc] initWithFrame:CGRectZero];
			[alphaSld setBackgroundColor:[UIColor clearColor]];
			[alphaSld setContinuous:YES];
			[alphaSld setMinimumValue:0];
			[alphaSld setMaximumValue:100];
			[alphaSld setValue:alphaValue];
			[alphaSld addTarget:self action:@selector(alphaSldChanged:) forControlEvents:UIControlEventValueChanged];
			[alphaSld setFrame:CGRectMake((opad.displayWidth - opad.numWidth * 5) / 2, alphaLbl.frame.origin.y + alphaLbl.frame.size.height / 2, opad.numWidth * 5, opad.numWidth)];
			[self.view addSubview:alphaSld];
		}
		[alphaSld setAlpha:0];
		
		if (!rotateLbl) {
			rotateLbl = [[UILabel alloc] init];
			[rotateLbl setText:@"Rotate"];
			[rotateLbl setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize * 0.8]];
			[rotateLbl setTextColor:opad.fontColor];
			[rotateLbl setBackgroundColor:[UIColor clearColor]];
			[rotateLbl setFrame:CGRectMake((opad.displayWidth - opad.numWidth * 5) / 2, alphaSld.frame.origin.y + alphaSld.frame.size.height + opad.numWidth / 2, opad.numWidth * 2, opad.numWidth)];
			[self.view addSubview:rotateLbl];
		}
		[rotateLbl setAlpha:0];
		
		if (!leftRotate) {
			leftRotate = [UIButton buttonWithType:UIButtonTypeCustom];
			[leftRotate.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize]];
//			[leftRotate setTitle:@"<-" forState:UIControlStateNormal];
			[leftRotate setImage:[UIImage imageNamed:@"rotateArrowL.PNG"] forState:UIControlStateNormal];
			[leftRotate addTarget:self action:@selector(leftRotateTapped:) forControlEvents:UIControlEventTouchUpInside];
			[leftRotate setFrame:CGRectMake((opad.displayWidth - opad.numWidth * 3 - opad.numWidth * 3) / 2, rotateLbl.frame.origin.y + rotateLbl.frame.size.height, opad.numWidth * 3, opad.numWidth)];
			[self.view addSubview:leftRotate];
		}
		[leftRotate setAlpha:0];
		
		if (!rightRotate) {
			rightRotate = [UIButton buttonWithType:UIButtonTypeCustom];
			[rightRotate.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize]];
//			[rightRotate setTitle:@"->" forState:UIControlStateNormal];
			[rightRotate setImage:[UIImage imageNamed:@"rotateArrowR.PNG"] forState:UIControlStateNormal];
			[rightRotate addTarget:self action:@selector(rightRotateTapped:) forControlEvents:UIControlEventTouchUpInside];
			[rightRotate setFrame:CGRectMake((opad.displayWidth + opad.numWidth * 3 - opad.numWidth * 3) / 2, rotateLbl.frame.origin.y + rotateLbl.frame.size.height, opad.numWidth * 3, opad.numWidth)];
			[self.view addSubview:rightRotate];
		}
		[rightRotate setAlpha:0];

		[menuView setTransform:opad.idleTrans];
		[camerarollBtn setTransform:opad.idleTrans];
		[alphaBtn setTransform:opad.idleTrans];
		[alphaLbl setTransform:opad.idleTrans];
		[alphaSld setTransform:opad.idleTrans];
		[rotateLbl setTransform:opad.idleTrans];
		[leftRotate setTransform:opad.idleTrans];
		[rightRotate setTransform:opad.idleTrans];
		
		[menuView setTransform:opad.upTrans];
		[camerarollBtn setTransform:opad.upTrans];
		[alphaLbl setTransform:opad.upTrans];
		[alphaBtn setTransform:opad.upTrans];
		[alphaSld setTransform:opad.upTrans];
		[rotateLbl setTransform:opad.upTrans];
		[leftRotate setTransform:opad.upTrans];
		[rightRotate setTransform:opad.upTrans];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		[menuView setAlpha:1];
		[camerarollBtn setAlpha:1];
		[alphaLbl setAlpha:1];
		[alphaBtn setAlpha:1];
		[alphaSld setAlpha:1];
		[rotateLbl setAlpha:1];
		[leftRotate setAlpha:1];
		[rightRotate setAlpha:1];

		[menuView setTransform:opad.idleTrans];
		[camerarollBtn setTransform:opad.idleTrans];
		[alphaBtn setTransform:opad.idleTrans];
		[alphaLbl setTransform:opad.idleTrans];
		[alphaSld setTransform:opad.idleTrans];
		[rotateLbl setTransform:opad.idleTrans];
		[leftRotate setTransform:opad.idleTrans];
		[rightRotate setTransform:opad.idleTrans];
		
		[UIView commitAnimations];
		
		isSetting = true;
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		
		[menuView setAlpha:0];
		[camerarollBtn setAlpha:0];
		[alphaLbl setAlpha:0];
		[alphaBtn setAlpha:0];
		[alphaSld setAlpha:0];
		[rotateLbl setAlpha:0];
		[leftRotate setAlpha:0];
		[rightRotate setAlpha:0];

		[menuView setTransform:opad.upTrans];
		[camerarollBtn setTransform:opad.upTrans];
		[alphaBtn setTransform:opad.upTrans];
		[alphaLbl setTransform:opad.upTrans];
		[alphaSld setTransform:opad.upTrans];
		[rotateLbl setTransform:opad.upTrans];
		[leftRotate setTransform:opad.upTrans];
		[rightRotate setTransform:opad.upTrans];
		
		[UIView commitAnimations];
		
		isSetting = false;
	}
	
	[self setSettingInfoBtnEnable];
}

-(IBAction) camerarollBtnTapped: (UIButton *) sender {
	[self camerarollSet];
}

-(void) camerarollSet {
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//	[imagePicker setAllowsEditing:YES];
	[imagePicker setAllowsEditing:NO];
	[imagePicker setDelegate:self];
	
	[self presentViewController:imagePicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissViewControllerAnimated:YES completion:nil];
		
	UIImage *orglImage;
	orglImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	CGSize  size = { opad.displayWidth, opad.displayHeight};
    UIGraphicsBeginImageContext(size);
	
    CGRect  rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [orglImage drawInRect:rect];
	
    UIImage*    shrinkedImage;
    shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    oldImgView.image = shrinkedImage;

	isSetting = true;
	[self setting];
	
	[oldImgView setAlpha:(float)alphaValue / 100];
	
	camerarollHasSet = true;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//	if (camerarollHasSet == false) {
//		[self camerarollSet];
//	}
//	else {
//		[picker dismissViewControllerAnimated:YES completion:nil];
//	}
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction) alphaBtnTapped:(UIButton * ) sender {

}

-(IBAction) alphaSldChanged: (UISlider *) sender {
	alphaValue = sender.value;
	[oldImgView setAlpha:(float)alphaValue / 100];
}

-(IBAction) leftRotateTapped: (UISlider *) sender {
	rotateState = rotateState + 1;
	[self rotateTrans];
}

-(IBAction) rightRotateTapped: (UISlider *) sender {
	rotateState = rotateState - 1;
	[self rotateTrans];
}

-(void) rotateTrans {
//	rotateState = rotateState % 4;
	
	if ((rotateState == 4) || (rotateState == -4)) {
		rotateState = 0;
	}
	
	switch (rotateState) {
		case 0:
			[oldImgView setTransform:opad.idleTrans];
//			[oldImgView setFrame:CGRectMake(0, 0, opad.displayWidth, opad.displayHeight)];
			break;
		case 1:
		case -3:
			[oldImgView setTransform:opad.idleTrans];
//			[oldImgView setTransform:opad.scaleTrans];
			[oldImgView setTransform:opad.leftRotateTrans];
//			[oldImgView setFrame:CGRectMake(0, 0, opad.displayWidth, opad.displayHeight)];
			break;
		case 2:
		case -2:
			[oldImgView setTransform:opad.idleTrans];
			[oldImgView setTransform:opad.reverseTrans];
//			[oldImgView setFrame:CGRectMake(0, 0, opad.displayHeight, opad.displayWidth)];
			break;
		case 3:
		case -1:
			[oldImgView setTransform:opad.idleTrans];
//			[oldImgView setTransform:opad.scaleTrans];
			[oldImgView setTransform:opad.rightRotateTrans];
//			[oldImgView setFrame:CGRectMake(0, 0, opad.displayWidth, opad.displayHeight)];
			break;
		default:
			break;
	}
	[oldImgView setFrame:CGRectMake(0, 0, opad.displayWidth, opad.displayHeight)];

}

-(IBAction) infoBtnTapped: (UIButton *) sender {
	if (!isInfo) {
		if (!menuView) {
			menuView = [[UIImageView alloc] init];
			[menuView setImage:[UIImage imageNamed:@"menuView.PNG"]];
			[menuView setFrame:CGRectMake(opad.numWidth / 2, opad.numWidth * 2, opad.displayWidth - opad.numWidth, opad.displayHeight - opad.numWidth * 4)];
			[self.view addSubview:menuView];
		}
		[menuView setAlpha:0];
		
		if(!explainLbl) {
			explainLbl = [[UILabel alloc] init];
			[explainLbl setFrame:CGRectMake((opad.numWidth * 2) / 2, opad.numWidth * 2 + opad.numWidth, opad.displayWidth - opad.numWidth * 2, opad.numWidth * 3)];
			[explainLbl setTextAlignment:NSTextAlignmentCenter];
			[explainLbl setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize]];
			[explainLbl setTextColor:opad.fontColor];
			[explainLbl setNumberOfLines:0];
			[explainLbl setText:@"Select your OLD photo,\nadjust and take NEW photo.\nEnjoy 'Then' and 'Now'!"];
			[explainLbl setBackgroundColor:[UIColor clearColor]];
			[self.view addSubview:explainLbl];
		}
		[explainLbl setAlpha:0];
		
		if (!twitterBtn) {
			twitterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[twitterBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:opad.fontSize]];
			[twitterBtn setTitleColor:opad.fontColor forState:UIControlStateNormal];
			[twitterBtn setTitle:@"Twitter" forState:UIControlStateNormal];
			[twitterBtn setTitle:@"" forState:UIControlStateHighlighted];
			[twitterBtn setBackgroundImage:[UIImage imageNamed:@"redLine.PNG"] forState:UIControlStateNormal];
			[twitterBtn setBackgroundImage:[UIImage imageNamed:@"redLine.PNG"] forState:UIControlStateHighlighted];
			[twitterBtn addTarget:self action:@selector(twitterBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
			[twitterBtn setFrame:CGRectMake((opad.displayWidth - opad.numWidth * 3) / 2, explainLbl.frame.origin.y + explainLbl.frame.size.height + opad.numWidth, opad.numWidth * 3, opad.numWidth)];
			[self.view addSubview:twitterBtn];
		}
		[twitterBtn setAlpha:0];
		
		[menuView setTransform:opad.idleTrans];
		[twitterBtn setTransform:opad.idleTrans];
		[explainLbl setTransform:opad.idleTrans];
		
		[menuView setTransform:opad.upTrans];
		[twitterBtn setTransform:opad.upTrans];
		[explainLbl setTransform:opad.upTrans];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		[menuView setAlpha:1];
		[twitterBtn setAlpha:1];
		[explainLbl setAlpha:1];
		
		[menuView setTransform:opad.idleTrans];
		[twitterBtn setTransform:opad.idleTrans];
		[explainLbl setTransform:opad.idleTrans];

		[UIView commitAnimations];
		
		isInfo = true;
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];

		[menuView setAlpha:0];
		[twitterBtn setAlpha:0];
		[explainLbl setAlpha:0];
		
		[menuView setTransform:opad.upTrans];
		[twitterBtn setTransform:opad.upTrans];
		[explainLbl setTransform:opad.upTrans];

		[UIView commitAnimations];
		
		isInfo = false;

	}
	[self setSettingInfoBtnEnable];
}

-(void) setSettingInfoBtnEnable {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	
	if (isSetting) {
		[infoBtn setAlpha:0];
	}
	else {
		[infoBtn setAlpha:1];
	}

	if (isInfo) {
		[settingBtn setAlpha:0];
	}
	else {
		[settingBtn setAlpha:1];
	}
	
	[UIView commitAnimations];
}

-(IBAction) twitterBtnTapped: (UIButton *) sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/209crc"]];
}

@end
