/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The EAGLView class is a UIView subclass that renders OpenGL scene.
*/

#import <UIKit/UIKit.h>

#import "OpenGLRenderer.h"

@interface View : GLKView

@property (nonatomic, strong) OpenGLRenderer *renderer;

@end
