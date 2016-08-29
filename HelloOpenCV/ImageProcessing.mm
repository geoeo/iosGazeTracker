//
//  ImageProcessing.m
//  HelloOpenCV
//
//  Created by Marc Haubenstock on 14/07/2016.
//  Copyright © 2016 Marc Haubenstock. All rights reserved.
//

#import "ImageProcessing.hm"

@implementation ImageProcessing

#ifdef __cplusplus

static CascadeClassifier faceCascade;
static CascadeClassifier eyeCascade;

// MatLab’s gradient algorithm
+(void)computeMatGradientX:(const Mat&)mat Out:(Mat&)outMat{
  
  for (int y = 0; y < mat.rows; ++y) {
    const uchar* Mrow = mat.ptr<uchar>(y);
    Float64 * Orow = outMat.ptr<Float64>(y);
    
    Orow[0] = Mrow[1] - Mrow[0];
    
    for (int x = 1; x < mat.cols-1; ++x) {
      Orow[x] = (Mrow[(x+1)] - Mrow[(x-1)])/2.0;;
    }
    
    Orow[mat.cols-1] = Mrow[mat.cols-1] - Mrow[mat.cols-2];
    
  }

}

+(void)computeMatGradientY:(const Mat&)mat Out:(Mat&)outMat{

  for (int x = 0; x < mat.cols; ++x) {
    
    outMat.at<Float64>(0,x) = mat.at<uchar>(1,x) - mat.at<uchar>(0,x);
    
    for (int y = 1; y < mat.rows-1; ++y) {
      outMat.at<Float64>(y,x) = (mat.at<uchar>(y+1,x) - mat.at<uchar>(y-1,x))/2.0;
    }
    
    outMat.at<Float64>(mat.rows-1,x) = mat.at<uchar>(mat.rows-1,x) - mat.at<uchar>(mat.rows-2,x);
    
  }

}

+(void)invertMat:(Mat&)mat_src{
  bitwise_not(mat_src,mat_src);
}

+(void)extractLuminance:(Mat&)image To:(Mat&)luminance{

    Mat chan[3];
    split(image,chan);
    luminance = chan[0]; // CV_8UC1
  

}

+(void)guassianBlur:(Mat&)src withSigmaX:(int)sigmaX SigmaY:(int)sigmaY{

    GaussianBlur( src, src, cv::Size(0,0), sigmaX,sigmaY);
    //GaussianBlur( src, src, cv::Size(3,3), 0,0);

}
+(void)setupDetectors{

  NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:lbpCascadeFace ofType:cascadeFileType];
  string faceCascadeFile = string([faceCascadePath UTF8String]);
  
  if(!faceCascade.load(faceCascadeFile)){
    NSLog(@"Error loading face cascade xml");
   }
  
  NSString *eyeCascadePath = [[NSBundle mainBundle] pathForResource:haarCascadeEyes ofType:cascadeFileType];
  string eyeCascadeFile = string([eyeCascadePath UTF8String]);
  
  if(!eyeCascade.load(eyeCascadeFile)){
    NSLog(@"Error loading eye cascade xml");
  }

}

+(cv::Rect)detectFace:(cv::Mat &)src drawRect:(bool)drawFlag{

  
  std::vector<cv::Rect> faces;
  
  //faceCascade.detectMultiScale(src,faces,1.1,1,0|CV_HAAR_SCALE_IMAGE|CV_HAAR_FIND_BIGGEST_OBJECT,cv::Size(150,150));
  faceCascade.detectMultiScale(src,faces,1.1,1,0,cv::Size(150,150)); // lbp
  
  if(faces.size() <1) return cv::Rect();
  
  cv::Rect face = faces[0];
  for (int i = 1; i < faces.size(); ++i) {
    if(faces[i].area() > face.area()){
      face = faces[i];
    }
  }

  return face;
}

+(std::vector<cv::Rect>)detectEyes:(cv::Mat &)faceROI drawRect:(bool)drawFlag{

  std::vector<cv::Rect> eyes;
  
  eyeCascade.detectMultiScale(faceROI, eyes, 1.1,1,0, cv::Size(20,20));
  
  std::vector<cv::Rect> mainEyes;
  
  if(eyes.size() >= 2){
    mainEyes.push_back(eyes[0]);
    mainEyes.push_back(eyes[1]);
  }

  return mainEyes;


}

+(std::vector<cv::Rect>)estimateEyes:(cv::Rect &)faceROI xOffset:(int)x_off yOffset:(int)y_off drawRect:(bool)drawFlag{

  //-- Find eye regions and draw them
  int eye_region_width = faceROI.width * (kEyePercentWidth/100.0);
  int eye_region_height = faceROI.width * (kEyePercentHeight/100.0);
  int eye_region_top = faceROI.height * (kEyePercentTop/100.0);
  
  cv::Rect leftEyeRegion(x_off + faceROI.width*(kEyePercentSide/100.0),
                         y_off + eye_region_top,eye_region_width,eye_region_height);
                         
  cv::Rect rightEyeRegion(x_off + faceROI.width - eye_region_width - faceROI.width*(kEyePercentSide/100.0),
                          y_off + eye_region_top,eye_region_width,eye_region_height);
  
                          
  std::vector<cv::Rect> eyes;
  eyes.push_back(leftEyeRegion);
  eyes.push_back(rightEyeRegion);

  return eyes;

}

+(cv::Point) findEyeCenterWithFace:(const cv::Mat &)face andEye:(const cv::Rect &)eyeROI debug:(cv::Mat &)outMat{

  cv::Point nullPoint = cv::Point();
  
  if(eyeROI.height == 0 || eyeROI.width == 0 || eyeROI.y + eyeROI.height >= face.rows || eyeROI.x + eyeROI.width >= face.cols) return nullPoint;

  cv::Mat eyeROIUnscaled = face(eyeROI);
  cv::Mat eyeROIMat;
  cv::resize(eyeROIUnscaled, eyeROIMat, cv::Size(kFastEyeWidth,((float)kFastEyeWidth/eyeROIUnscaled.cols) * eyeROIUnscaled.rows));

  // Sub matricies for eye ROI
  int eyeROIHeight = eyeROIMat.rows;
  int eyeROIWidth = eyeROIMat.cols;
  
  Mat outEyeMatX(eyeROIHeight,eyeROIWidth,CV_64F);
  Mat outEyeMatY(eyeROIHeight,eyeROIWidth,CV_64F);
  
  [ImageProcessing computeMatGradientX:eyeROIMat Out:outEyeMatX];
  [ImageProcessing computeMatGradientY:eyeROIMat Out:outEyeMatY];
  
  Mat magnitude = [Helpers matrixMagnitudeWithX:outEyeMatX andY:outEyeMatY];
  
  double gradientThresh = [Helpers computeDynamicThresholdWithSrc:magnitude andFactor: kGradientThreshold];
  
  for (int y = 0; y < eyeROIMat.rows; ++y) {
    double * xRows = outEyeMatX.ptr<double>(y), *yRows = outEyeMatY.ptr<double>(y);
    const double *magRows = magnitude.ptr<double>(y);
    
    for (int x = 0; x < eyeROIMat.cols; ++x) {
    
      double gradX = xRows[x], gradY = yRows[x];
      double magnitude = magRows[x];
      if(magnitude > gradientThresh){
        xRows[x] = gradX/magnitude;
        yRows[x] = gradY/magnitude;
      }
      else{
        xRows[x] = 0;
        yRows[x] = 0;
      }
    
    }
  }
  
  //-- Create a blurred and inverted image for weighting
  cv::Mat weight;
  cv::GaussianBlur(eyeROIMat, weight, cv::Size(kWeightBlurSize,kWeightBlurSize), 0,0);
  for (int y = 0; y < weight.rows; ++y) {
    unsigned char *row = weight.ptr<unsigned char>(y);
    for(int x = 0; x < weight.cols; ++x){
      row[x] = 255 - row[x];
    }
  }
  
  //-- Run the algorithm
  
  cv::Mat outSum = cv::Mat::zeros(eyeROIMat.rows, eyeROIMat.cols, CV_64F);
  
    for (int y = 0; y < weight.rows; ++y) {
    double * xRows = outEyeMatX.ptr<double>(y), *yRows = outEyeMatY.ptr<double>(y);
    
    for (int x = 0; x < weight.cols; ++x) {
    
      double gradX = xRows[x], gradY = yRows[x];
      if(gradX == 0 && gradY == 0){
        continue;
      }
      
      [ImageProcessing testPossibleCentersFormula:x Y:y Weight:weight gradX:gradX gradY:gradY Out:outSum];
    
    }
  }
  
  // scale all the values down, basically averaging them
  double numGradients = (weight.rows*weight.cols);
  cv::Mat resMat;
  outSum.convertTo(resMat, CV_32F,1/numGradients);
  
  //-- Find the maximum point
  cv::Point maxP;
  double maxVal;
  cv::minMaxLoc(resMat, NULL,&maxVal,NULL,&maxP);
  
  //-- Flood fill the edges
  if(kEnablePostProcess) {
    cv::Mat floodClone;
    double floodThresh = maxVal * kPostProcessThreshold;
    cv::threshold(resMat, floodClone, floodThresh, 0.0f, cv::THRESH_TOZERO);
    
    cv::Mat mask =  [Helpers floodKillEdges:floodClone];
    
    cv::minMaxLoc(resMat, NULL,&maxVal,NULL,&maxP , mask);
    
      
  outMat = mask;
    }
  

  
  float ratio = (((float)kFastEyeWidth)/eyeROI.width);
  int x = round(maxP.x / ratio);
  int y = round(maxP.y / ratio);
  return cv::Point(x,y);
  
}

+(void) testPossibleCentersFormula:(int)x Y:(int)y Weight:(const cv::Mat &)weight gradX:(double)gx gradY:(double)gy Out:(cv::Mat &)outMat
{
// for all possible centers
  for (int cy = 0; cy < outMat.rows; ++cy) {
    double *Or = outMat.ptr<double>(cy);
    const unsigned char *Wr = weight.ptr<unsigned char>(cy);
    for (int cx = 0; cx < outMat.cols; ++cx) {
      if (x == cx && y == cy) {
        continue;
      }
      // create a vector from the possible center to the gradient origin
      double dx = x - cx;
      double dy = y - cy;
      // normalize d
      double magnitude = sqrt((dx * dx) + (dy * dy));
      dx = dx / magnitude;
      dy = dy / magnitude;
      double dotProduct = dx*gx + dy*gy;
      dotProduct = std::max(0.0,dotProduct);
      // square and multiply by the weight
      if (kEnableWeight) {
        Or[cx] += dotProduct * dotProduct * (Wr[cx]/kWeightDivisor);
      } else {
        Or[cx] += dotProduct * dotProduct;
      }
    }
  }

}

#endif

@end
