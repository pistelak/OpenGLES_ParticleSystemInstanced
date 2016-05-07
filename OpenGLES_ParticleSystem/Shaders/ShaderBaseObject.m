//
//  ShaderBaseObject.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ShaderBaseObject.h"

#include "ShaderBaseObject+Binding.h"

@implementation ShaderBaseObject

- (void) loadShaders
{
    [self bindObjCPropertiesOnShader];
}

@end
