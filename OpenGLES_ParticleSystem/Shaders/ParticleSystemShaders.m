//
//  ParticleSystemShaders.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ParticleSystemShaders.h"
#include "PSVertexShader.vsh"
#include "PSFragmentShader.fsh"


@implementation ParticleSystemShaders

- (instancetype) init
{
    self = [super init];
    if (self) {
        [self loadShaders];
    }
    
    return self;
}

- (void) loadShaders
{
    // Program
    ShaderProcessor* shaderProcessor = [[ShaderProcessor alloc] init];
    self.program = [shaderProcessor BuildProgram:PSVertexShader with:PSFragmentShader];

    // bind properties
    [super loadShaders];
}

@end
