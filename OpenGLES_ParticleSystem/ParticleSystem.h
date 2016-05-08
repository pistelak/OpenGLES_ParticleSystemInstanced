//
//  ParticleSystem.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import <Foundation/Foundation.h>

// OpenGL
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>

#import "ParticleSystemShaders.h"
#import "Mesh.h"


@interface ParticleSystem : NSObject

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithMesh:(Mesh *) mesh andShader:(ParticleSystemShaders *) shaderObject;

- (void) draw;

- (NSUInteger) currentNumberOfParticles;

@end
