//
//  MyPoint.m
//  HelloOpenCV
//
//  Created by Marc Haubenstock on 08/08/2016.
//  Copyright © 2016 Marc Haubenstock. All rights reserved.
//

#import "MyPoint.h"

@implementation MyPoint  {

  int _x;
  int _y;


}

-(void)setX:(int)x AndY:(int)y{

  _x = x;
  _y = y;


}

-(int)getX{

  return _x;
}

-(int)getY{
  return _y;
}

+(MyPoint*)createPointWithX:(int)x andY:(int)y{
  MyPoint* p = [[MyPoint alloc] init];  
  [p setX:x AndY:y];
  
  return p;

}



@end