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

typedef struct {
    float lifetime;
    GLKVector3 startPosition;
    GLKVector3 endPosition;
} particle_t;

@interface ParticleSystem : NSObject

- (instancetype) initWithParticleCount:(NSInteger) particleCount
                          shaderObject:(ShaderBaseObject *) shaderObject
                           andLifetime:(float) lifetime;

@property (nonatomic, strong) ParticleSystemShaders *shaderObject;

@property (nonatomic, assign) NSInteger particleCount;

@property (nonatomic, assign) float time;
@property (nonatomic, assign) float lifetime;
@property (nonatomic, assign) GLKVector3 centerPosition; // random
@property (nonatomic, assign) GLKVector4 particleColor; // random

@property (nonatomic, assign) GLKVector2 drawableSize;

@property (nonatomic, strong) GLKTextureInfo *spriteTexture;

- (BOOL) loadTextureFromFilePath:(NSString *) filePath NS_UNAVAILABLE;

- (void) drawWithProjectionMatrix:(GLKMatrix4) projectionMatrix eyePosition:(GLKVector3) eyePosition andFov:(float) fov;
- (void) updateWithTime:(NSTimeInterval) deltaTime;

@end
