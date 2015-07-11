//
//  Matrix3.m
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

#import "Matrix3.h"

@implementation Matrix3


#pragma mark - Matrix creation

+ (Matrix3 *)matrix3FromCMatrix:(matrix_float3x3)matrix {
	Matrix3 *matrix3 = [[Matrix3 alloc] init];
	
	float m00 = matrix.columns[0][0];
	float m01 = matrix.columns[0][1];
	float m02 = matrix.columns[0][2];
	
	float m10 = matrix.columns[1][0];
	float m11 = matrix.columns[1][1];
	float m12 = matrix.columns[1][2];
	
	float m20 = matrix.columns[2][0];
	float m21 = matrix.columns[2][1];
	float m22 = matrix.columns[2][2];
	
	matrix3->glkMatrix = GLKMatrix3Make(m00, m01, m02, m10, m11, m12, m20, m21, m22);
	
	return matrix3;
}

+ (Matrix3 *)matrix3Make:(float)m00 m01:(float)m01 m02:(float)m02 m10:(float)m10 m11:(float)m11 m12:(float)m12 m20:(float)m20 m21:(float)m21 m22:(float)m22 {
	
	Matrix3 *matrix = [[Matrix3 alloc] init];
	matrix->glkMatrix = GLKMatrix3Make(m00, m01, m02, m10, m11, m12, m20, m21, m22);
	
	return matrix;
}

- (instancetype)init{
	self = [super init];
	if(self != nil){
		glkMatrix = GLKMatrix3Identity;
	}
	return self;
}


+ (Matrix3 *)invertMatrix:(Matrix3 *)matrix {
	Matrix3 *matrix3 = [[Matrix3 alloc] init];
	GLKMatrix3 m = matrix->glkMatrix;
	
	matrix3->glkMatrix = GLKMatrix3Invert(m, nil);
	
	return matrix3;
}

+ (Matrix3 *)transposeMatrix:(Matrix3 *)matrix {
	Matrix3 *matrix3 = [[Matrix3 alloc] init];
	GLKMatrix3 m = matrix->glkMatrix;
	
	matrix3->glkMatrix = GLKMatrix3Transpose(m);
	
	return matrix3;
}

- (matrix_float3x3)cMatrix {
	
	vector_float3 X = { glkMatrix.m00, glkMatrix.m01, glkMatrix.m02 };
	vector_float3 Y = { glkMatrix.m10, glkMatrix.m11, glkMatrix.m12 };
	vector_float3 Z = { glkMatrix.m20, glkMatrix.m21, glkMatrix.m22 };
	
	matrix_float3x3 mat = { X, Y, Z };
	
	return mat;
}

@end