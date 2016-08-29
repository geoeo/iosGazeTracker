//
//  Helpers.m
//  HelloOpenCV
//
//  Created by Marc Haubenstock on 18/07/2016.
//  Copyright © 2016 Marc Haubenstock. All rights reserved.
//

#import "Helpers.hm"

@implementation Helpers

#ifdef __cplusplus

+(cv::Mat)matrixMagnitudeWithX:(const cv::Mat&)matX andY:(const cv::Mat&)matY{

  cv::Mat magnitudeMat(matX.rows, matX.cols, CV_64F);
  
  for (int y = 0; y < matX.rows; ++y) {
    
    const double * xRow = matX.ptr<double>(y), *yRow = matY.ptr<double>(y);
    double * magRow = magnitudeMat.ptr<double>(y);
    
    for (int x = 0; x < matX.cols; ++x) {
      double gX = xRow[x], gY = yRow[x];
      magRow[x] = sqrt(gX * gX + gY * gY);
    
    }
  }
  
  return magnitudeMat;

}

+(double)computeDynamicThresholdWithSrc:(const cv::Mat&)mat andFactor:(double)stdDevFactor{

  cv::Scalar stdMagGrad, meanMagGrad;
  cv::meanStdDev(mat, meanMagGrad, stdMagGrad);
  double stdDev = stdMagGrad[0] / sqrt(mat.rows*mat.cols);
  
  return stdDevFactor * stdDev + meanMagGrad[0];
}

+(void)ApplyThresholdToGradient:(cv::Mat &)matX andY:(cv::Mat &)matY withMag:(const cv::Mat &)magnitude{

  for(int y=0; y < matX.rows; ++y){
  
  }

}

+(bool)floodShouldPushPoint:(MyPoint *)p andMat:(const cv::Mat &)mat{
  return [p getX] >= 0 && [p getX] < mat.cols && [p getY] >= 0 && [p getY] < mat.rows;
}

+(void)floodFill:(cv::Mat &)mask Source:(cv::Mat &)mat seedX:(int)x seedY:(int)y{

  NSMutableArray<MyPoint *> * toDo = [[NSMutableArray alloc] init];
  [toDo addObject:[MyPoint createPointWithX:x andY:y]];
  while (!(toDo.count == 0)) {
      MyPoint *p = [toDo objectAtIndex:0];
      [toDo removeObjectAtIndex:0];
      if(mat.at<float>([p getY], [p getX]) == 0.0f){
        continue;
      }
    
    // add in every direction
      MyPoint * rightPoint = [MyPoint createPointWithX:[p getX] + 1 andY:[p getY]];
    if ([Helpers floodShouldPushPoint:rightPoint andMat:mat]) [toDo addObject:rightPoint];
      MyPoint * leftPoint = [MyPoint createPointWithX:[p getX] - 1 andY:[p getY]];
    if ([Helpers floodShouldPushPoint:leftPoint andMat:mat]) [toDo addObject: leftPoint];
      MyPoint * downPoint = [MyPoint createPointWithX:[p getX] andY:[p getY] + 1];
    if ([Helpers floodShouldPushPoint:downPoint andMat:mat]) [toDo addObject: downPoint];
      MyPoint * upPoint = [MyPoint createPointWithX:[p getX] andY:[p getY] - 1];
    if ([Helpers floodShouldPushPoint:upPoint andMat:mat]) [toDo addObject:upPoint];
    // kill it
    mat.at<float>([p getY], [p getX]) = 0.0f;
    mask.at<uchar>([p getY], [p getX]) = 0;

  }

}

+(cv::Mat)floodKillEdges:(cv::Mat &)mat
{

  rectangle(mat,cv::Rect(0,0,mat.cols,mat.rows),255);
  cv::Mat mask(mat.rows, mat.cols, CV_8U, 255);
  
  
  for (int x = 0; x < mat.cols; x+=mat.cols-1) {
   for(int y = 0; y < mat.rows; y++){
     [Helpers floodFill:mask Source:mat seedX:x seedY:y];
   }
  }
  
  for (int x = 0; x < mat.cols; x++) {
   for(int y = 0; y < mat.rows; y+=mat.rows-1){
     [Helpers floodFill:mask Source:mat seedX:x seedY:y];
   }
  }


  
  return mask;
}
#endif



@end
