//
//  ViewController.h
//  HelloOpenCV
//
//  Created by Marc Haubenstock on 13/07/2016.
//  Copyright (c) 2016 Marc Haubenstock. All rights reserved.
//


#import <opencv2/highgui/cap_ios.h>
#import <UIKit/UIKit.h>
#import "ImageProcessing.hm"

using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>
{

  __weak IBOutlet UIButton *endButon;
  __weak IBOutlet UISwitch *XYSwitch;
  __weak IBOutlet UISwitch *XYToggle;
  gradientMode activeGradientMode;


  
  CvVideoCamera* videoCamera;
}

-(IBAction)actionStart:(id)sender;
-(IBAction)stopCamera:(id)sender;
-(void)switchStateChanged:(UISwitch *)switchState;
-(void)toggleStateChanged:(UISwitch *)switchState;

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (weak) IBOutlet UIButton *button;
@property (weak) IBOutlet UIImageView *imageView;

@end

