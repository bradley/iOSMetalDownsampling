//
//  METLTexture.h
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/24/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

@interface METLTexture : NSObject

@property (nonatomic) id <MTLTexture> texture;
@property (nonatomic) MTLTextureType target;
@property (nonatomic) uint32_t width;
@property (nonatomic) uint32_t height;
@property (nonatomic) uint32_t depth;
@property (nonatomic) MTLPixelFormat format;
@property (nonatomic) BOOL hasAlpha;
@property (nonatomic) NSString *path;

- (id) initWithResourceName:(NSString *)name
								ext:(NSString *)ext;

- (BOOL) finalize:(id<MTLDevice>)device;

- (BOOL) finalize:(id<MTLDevice>)device
				 flip:(BOOL)flip;

- (UIImage *)image;

- (void *)bytes;

@end