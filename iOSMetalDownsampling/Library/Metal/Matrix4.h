//
//  Matrix4.h
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKMath.h>
#import "Matrix3.h"

@import simd;

@interface Matrix4 : NSObject{
@public
	GLKMatrix4 glkMatrix;
}

@property(nonatomic, readonly) int lengthInBytes;

+ (Matrix4 *)makePerspectiveViewAngle:(float)angleRad
								  aspectRatio:(float)aspect
										  nearZ:(float)nearZ
											farZ:(float)farZ;

+ (Matrix4 *)matrix4FromCMatrix:(matrix_float4x4)matrix;
+ (Matrix4 *)scaleMatrix:(Matrix4 *)matrix x:(float)x y:(float)y z:(float)z;
+ (Matrix4 *)rotateMatrix:(Matrix4 *)matrix x:(float)xAngleRad y:(float)yAngleRad z:(float)zAngleRad;
+ (Matrix4 *)translateMatrix:(Matrix4 *)matrix x:(float)x y:(float)y z:(float)z;
+ (Matrix4 *)multiplyMatrix:(Matrix4 *)matrixA byMatrix:(Matrix4 *)matrixB;
+ (Matrix4 *)transposeMatrix:(Matrix4 *)matrix;
+ (Matrix4 *)matrixFromAxisRotation:(float)x y:(float)y z:(float)z angle:(float)angle;
+ (Matrix3 *)getMatrix3ForMatrix:(Matrix4 *)matrix;
+ (Matrix4 *)matrixFromTranslation:(float)x y:(float)y z:(float)z;
+ (float)degreesToRad:(float)degrees;
+ (int)sizeOfVectorFloat4;

- (instancetype)init;
- (instancetype)copy;
- (matrix_float4x4)cMatrix;
- (void *)raw;

@end
