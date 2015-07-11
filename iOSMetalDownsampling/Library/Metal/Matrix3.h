//
//  Matrix3.h
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKMath.h>

@import simd;

@interface Matrix3: NSObject{
@public
	GLKMatrix3 glkMatrix;
}

+ (Matrix3 *)matrix3FromCMatrix:(matrix_float3x3)matrix;
+ (Matrix3 *)matrix3Make:(float)m00 m01:(float)m01 m02:(float) m02 m10:(float)m10 m11:(float)m11 m12:(float)m12 m20:(float)m20 m21:(float)m21 m22:(float)m22;
+ (Matrix3 *)invertMatrix:(Matrix3 *)matrix;
+ (Matrix3 *)transposeMatrix:(Matrix3 *)matrix;

- (matrix_float3x3)cMatrix;

@end

