//
//  MyPoint.h
//  HelloOpenCV
//
//  Created by Marc Haubenstock on 08/08/2016.
//  Copyright © 2016 Marc Haubenstock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPoint : NSObject {
    // Protected instance variables (not recommended)
}

-(void) setX:(int) x AndY:(int)y;
-(int) getX;
-(int) getY;

+(MyPoint*) createPointWithX:(int)x andY:(int)y;

@end


