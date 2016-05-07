//
//  ShaderBaseObject.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>
#import "ShaderProcessor.h"

#define GLSL(version, shader)  "#version " #version "\n" #shader

@interface ShaderBaseObject : NSObject

@property (readwrite) GLuint program;

- (void) loadShaders;

@end
