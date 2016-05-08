/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The EAGLView class is a UIView subclass that renders OpenGL scene.
*/

#import "View.h"
#import "OpenGLRenderer.h"

#import "meshObject.h"

@interface View ()
{
    EAGLContext* _context;
}
@end

@implementation View

- (instancetype) init
{    
    if ((self = [super init]))
	{
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        
        if (!_context || ![EAGLContext setCurrentContext:_context]) {
            return nil;
		}
		
        _renderer = [[OpenGLRenderer alloc] init];
		if (!_renderer) {
            return nil;
		}
        
        self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        
        [self setContext:_context];
        [self setDelegate:_renderer];
    }
	
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    [_renderer resizeWithWidth:CGRectGetWidth(self.frame) * screenScale
                     andHeight:CGRectGetHeight(self.frame) * screenScale];
}

@end
