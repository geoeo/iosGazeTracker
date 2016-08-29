//
//  ViewController.m
//  HelloOpenCV
//
//  Created by Marc Haubenstock on 13/07/2016.
//  Copyright (c) 2016 Marc Haubenstock. All rights reserved.
//

#import "ViewController.h"
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

@interface ViewController ()

@end

@implementation ViewController

@synthesize videoCamera;
@synthesize imageView;

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
  self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
  self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
  self.videoCamera.defaultFPS = 30;
  self.videoCamera.grayscaleMode = YES; // if YES then in YUV space
  self.videoCamera.delegate = self;
  
  activeGradientMode = YGrad;
  
  [self->XYSwitch addTarget:self action:@selector(switchStateChanged:) forControlEvents:UIControlEventValueChanged];
  [self->XYToggle addTarget:self action:@selector(toggleStateChanged:) forControlEvents:UIControlEventValueChanged];
  
  [ImageProcessing setupDetectors];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Protocol CvVideoCameraDelegate
#ifdef __cplusplus

static cv::Rect lastValidLeftEye = cv::Rect(0,0,1,1);
static cv::Rect lastValidRightEye = cv::Rect(0,0,1,1);

-(void)processImage:(Mat&)image{
//  Mat imageCopy;
//  cvtColor(image,imageCopy,CV_BGRA2BGR);
  
//  Mat imageCopyGray;
//  cvtColor(image,imageCopyGray,CV_BGRA2GRAY);

  //invert image
  //[ImageProcessing invertMat:imageCopy];
  //cvtColor(imageCopy,image,CV_BGR2BGRA);
  
  Mat luminace(image.rows,image.cols,CV_8UC1);
  [ImageProcessing extractLuminance:image To:luminace];
  
  cv::Rect faceROI = [ImageProcessing detectFace:luminace drawRect:false];
  //std::vector<cv::Rect> eyes = [ImageProcessing detectEyes:luminace drawRect:false];
  int x_offset = faceROI.x;
  int y_offset = faceROI.y;
  
  std::vector<cv::Rect> eyes = [ImageProcessing estimateEyes:faceROI xOffset:x_offset yOffset:y_offset drawRect:false];
  
  if(eyes[0].height > 0){
    lastValidLeftEye = eyes[0];
  }
  
  if(eyes[1].height > 0){
    lastValidRightEye = eyes[1];
  }
  
  [ImageProcessing guassianBlur:luminace withSigmaX:0.005*340 SigmaY:0.005*512];
  
  Mat grad;
  Mat abs_grad_x, abs_grad_y;
  
  //calc X image gradient
  Mat outMatX(image.rows,image.cols,CV_64F);
  [ImageProcessing computeMatGradientX:luminace Out:outMatX];
  
  //calc Y image gradient
  Mat outMatY(image.rows,image.cols,CV_64F);
  [ImageProcessing computeMatGradientY:luminace Out:outMatY];
  
  Mat face = luminace(faceROI);
  Mat eyeDebugL(lastValidLeftEye.height,lastValidLeftEye.width,CV_64F);
  Mat eyeDebugR(lastValidRightEye.height,lastValidRightEye.width,CV_64F);

  cv::Point eyeCenterL = [ImageProcessing findEyeCenterWithFace:luminace andEye:lastValidLeftEye debug:eyeDebugL];
  cv::Point eyeCenterR = [ImageProcessing findEyeCenterWithFace:luminace andEye:lastValidRightEye debug:eyeDebugR];
  
  eyeCenterL.x += lastValidLeftEye.x;
  eyeCenterL.y += lastValidLeftEye.y;
  
  eyeCenterR.x += lastValidRightEye.x;
  eyeCenterR.y += lastValidRightEye.y;

  // convert back to CV_8U for display
  convertScaleAbs( outMatX, abs_grad_x );
  convertScaleAbs( outMatY, abs_grad_y );
  
  switch(activeGradientMode){
  
    case XGrad:
      rectangle(abs_grad_x, faceROI, 255);
      abs_grad_x.copyTo(image);
    break;
    case YGrad:
      rectangle(abs_grad_y, faceROI, 255);
      abs_grad_y.copyTo(image);
    break;
    case XYGrad:
//      cv::add(abs_grad_x, abs_grad_y, grad);
//      rectangle(grad, faceROI, 255);
//      if(eyes.size() == 2){
//        rectangle(grad,eyes[0],255);
//        rectangle(grad,eyes[1],255);
//      }
      if(eyes.size() == 2){
        rectangle(luminace,lastValidLeftEye,255);
        rectangle(luminace,lastValidRightEye,255);
      }
      //convertScaleAbs(eyeDebugR,grad);
//      circle(grad, eyeCenterL, 5, 255);
//      circle(grad, eyeCenterR, 5, 255);
//      grad.copyTo(image);
      circle(luminace, eyeCenterL, 5, 255);
      circle(luminace, eyeCenterR, 5, 255);
      luminace.copyTo(image);
//      eyeDebugR.copyTo(image);
      break;
  
  }

}
#endif


#pragma mark - UI Actions

- (IBAction)actionStart:(id)sender
{
  [self.videoCamera start];
}

- (IBAction)stopCamera:(id)sender
{
  [self.videoCamera stop];
}

- (void)switchStateChanged:(UISwitch *)switchState{

  if(XYToggle.isOn) return;

  if([switchState isOn]){
    activeGradientMode = YGrad;
  }
  else {
    activeGradientMode = XGrad;
  }

}

- (void)toggleStateChanged:(UISwitch *)switchState{

  if([switchState isOn]){
    activeGradientMode = XYGrad;
  }
  else {
    activeGradientMode = self->XYSwitch.isOn ? YGrad : XGrad;
  }

}

@end
