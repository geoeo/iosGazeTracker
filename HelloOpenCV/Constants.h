//
//  Constants.h
//  HelloOpenCV
//
//  Created by Marc Haubenstock on 17/07/2016.
//  Copyright © 2016 Marc Haubenstock. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

static NSString* const lbpCascadeFace = @"lbpcascade_frontalface";
static NSString* const haarCascadeFace = @"haarcascade_frontalface_alt";
static NSString* const haarCascadeEyes = @"haarcascade_eye_tree_eyeglasses";
static NSString* const cascadeFileType = @"xml";

// Size constants
const int kEyePercentTop = 25;
const int kEyePercentSide = 13;
const int kEyePercentHeight = 30;
const int kEyePercentWidth = 35;

// Algorithm Parameters
const int kFastEyeWidth = 50;
const int kWeightBlurSize = 5;
const bool kEnableWeight = true;
const float kWeightDivisor = 1.0;
const double kGradientThreshold = 50.0;

// Postprocessing
const bool kEnablePostProcess = true;
const float kPostProcessThreshold = 0.97;


#endif /* Constants_h */
