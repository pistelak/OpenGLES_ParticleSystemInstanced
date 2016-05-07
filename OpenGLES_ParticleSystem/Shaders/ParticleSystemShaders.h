//
//  ParticleSystemShaders.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ShaderBaseObject.h"


@interface ParticleSystemShaders : ShaderBaseObject

// Attribute Handles
@property (readwrite) GLuint in_position;
@property (readwrite) GLuint in_normal;

// Uniform Handles
@property (readwrite) GLuint u_projectionMatrix;
@property (readwrite) GLuint u_viewMatrix;
@property (readwrite) GLuint u_modelMatrix;

@end
