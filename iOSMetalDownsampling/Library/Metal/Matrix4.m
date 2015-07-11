//
//  Matrix4.m
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

#import "Matrix4.h"

@implementation Matrix4

#pragma mark - Accessors

- (int)lengthInBytes{
	return 16;
}

#pragma mark - Matrix creation

+ (Matrix4 *)matrix4FromCMatrix:(matrix_float4x4)matrix {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	
	float m00 = matrix.columns[0][0];
	float m01 = matrix.columns[0][1];
	float m02 = matrix.columns[0][2];
	float m03 = matrix.columns[0][3];
	
	float m10 = matrix.columns[1][0];
	float m11 = matrix.columns[1][1];
	float m12 = matrix.columns[1][2];
	float m13 = matrix.columns[1][3];
	
	float m20 = matrix.columns[2][0];
	float m21 = matrix.columns[2][1];
	float m22 = matrix.columns[2][2];
	float m23 = matrix.columns[2][3];
	
	float m30 = matrix.columns[3][0];
	float m31 = matrix.columns[3][1];
	float m32 = matrix.columns[3][2];
	float m33 = matrix.columns[3][3];
	
	matrix4->glkMatrix = GLKMatrix4Make(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33);
	
	return matrix4;
}

+ (Matrix4 *)makePerspectiveViewAngle:(float)angleRad
								  aspectRatio:(float)aspect
										  nearZ:(float)nearZ
											farZ:(float)farZ{
	Matrix4 *matrix = [[Matrix4 alloc] init];
	matrix->glkMatrix = GLKMatrix4MakePerspective(angleRad, aspect, nearZ, farZ);
	return matrix;
}

- (instancetype)init{
	self = [super init];
	if(self != nil){
		glkMatrix = GLKMatrix4Identity;
	}
	return self;
}

- (instancetype)copy{
	Matrix4 *mCopy = [[Matrix4 alloc] init];
	mCopy->glkMatrix = self->glkMatrix;
	return mCopy;
}

#pragma mark - Matrix transformation

+ (Matrix4 *)scaleMatrix:(Matrix4 *)matrix x:(float)x y:(float)y z:(float)z {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	GLKMatrix4 m = matrix->glkMatrix;
	
	m = GLKMatrix4Scale(m, x, y, z);
	
	matrix4->glkMatrix = m;
	
	return matrix4;
}

+ (Matrix4 *)rotateMatrix:(Matrix4 *)matrix x:(float)xAngleRad y:(float)yAngleRad z:(float)zAngleRad {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	GLKMatrix4 m = matrix->glkMatrix;
	
	m = GLKMatrix4Rotate(m, xAngleRad, 1, 0, 0);
	m = GLKMatrix4Rotate(m, yAngleRad, 0, 1, 0);
	m = GLKMatrix4Rotate(m, zAngleRad, 0, 0, 1);
	
	matrix4->glkMatrix = m;
	
	return matrix4;
}

+ (Matrix4 *)translateMatrix:(Matrix4 *)matrix x:(float)x y:(float)y z:(float)z {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	GLKMatrix4 m = matrix->glkMatrix;
	
	m = GLKMatrix4Translate(m, x, y, z);
	
	matrix4->glkMatrix = m;
	
	return matrix4;
}

+ (Matrix4 *)multiplyMatrix:(Matrix4 *)matrixA byMatrix:(Matrix4 *)matrixB {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	GLKMatrix4 mA = matrixA->glkMatrix;
	GLKMatrix4 mB = matrixB->glkMatrix;
	
	matrix4->glkMatrix = GLKMatrix4Multiply(mA, mB);
	
	return matrix4;
}

+ (Matrix4 *)transposeMatrix:(Matrix4 *)matrix {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	GLKMatrix4 m = matrix->glkMatrix;
	
	m = GLKMatrix4Transpose(m);
	
	matrix4->glkMatrix = m;
	
	return matrix4;
}

+ (Matrix3 *)getMatrix3ForMatrix:(Matrix4 *)matrix {
	GLKMatrix4 m = matrix->glkMatrix;
	Matrix3 *matrix3 = [[Matrix3 alloc] init];
	
	matrix3->glkMatrix = GLKMatrix4GetMatrix3(m);
	
	return matrix3;
}

+ (Matrix4 *)matrixFromAxisRotation:(float)x y:(float)y z:(float)z angle:(float)angle {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	
	float c = cos(angle);
	float s = sin(angle);
	
	float m00 = x * x + (1 - x * x) * c;
	float m01 = x * y * (1 - c) - z*s;
	float m02 = x * z * (1 - c) + y * s;
	float m03 = 0.0;
	
	float m10 = x * y * (1 - c) + z * s;
	float m11 = y * y + (1 - y * y) * c;
	float m12 = y * z * (1 - c) - x * s;
	float m13 = 0.0;
	
	float m20 = x * z * (1 - c) - y * s;
	float m21 = y * z * (1 - c) + x * s;
	float m22 = z * z + (1 - z * z) * c;
	float m23 = 0.0;
	
	float m30 = 0.0;
	float m31 = 0.0;
	float m32 = 0.0;
	float m33 = 1.0;
	
	matrix4->glkMatrix = GLKMatrix4Make(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33);
	
	return matrix4;
}

+ (Matrix4 *)matrixFromTranslation:(float)x y:(float)y z:(float)z {
	Matrix4 *matrix4 = [[Matrix4 alloc] init];
	
	float m00 = 1;
	float m01 = 0;
	float m02 = 0;
	float m03 = 0;
	
	float m10 = 0;
	float m11 = 1;
	float m12 = 0;
	float m13 = 0;
	
	float m20 = 0;
	float m21 = 0;
	float m22 = 1;
	float m23 = 0;
	
	float m30 = x;
	float m31 = y;
	float m32 = z;
	float m33 = 1;
	
	matrix4->glkMatrix = GLKMatrix4Make(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33);
	
	return matrix4;
}

- (void *)raw {
	return glkMatrix.m;
}

+ (float)degreesToRad:(float)degrees {
	return GLKMathDegreesToRadians(degrees);
}

- (matrix_float4x4)cMatrix {
	
	vector_float4 X = { glkMatrix.m00, glkMatrix.m01, glkMatrix.m02, glkMatrix.m03 };
	vector_float4 Y = { glkMatrix.m10, glkMatrix.m11, glkMatrix.m12, glkMatrix.m13 };
	vector_float4 Z = { glkMatrix.m20, glkMatrix.m21, glkMatrix.m22, glkMatrix.m23 };
	vector_float4 W = { glkMatrix.m30, glkMatrix.m31, glkMatrix.m32, glkMatrix.m33 };
	
	matrix_float4x4 mat = { X, Y, Z, W };
	
	return mat;
}

+ (int)sizeOfVectorFloat4 {
	return sizeof(vector_float4);
}

@end