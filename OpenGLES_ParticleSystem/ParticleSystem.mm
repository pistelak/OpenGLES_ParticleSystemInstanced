//
//  ParticleSystem.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ParticleSystem.h"

#import <vector>

@implementation ParticleSystem
{
    GLuint _vao;
    GLuint _vertexBuffer;
    
    std::vector<particle_t> _particles;
}

- (instancetype) initWithParticleCount:(NSInteger) particleCount shaderObject:(ShaderBaseObject *) shaderObject andLifetime:(float) lifetime
{
    self = [super init];
    if (self) {
        _shaderObject = shaderObject;
        _particleCount = particleCount;
        _lifetime = lifetime;
        
        [self generateParticles];
        [self setupGL];
        [self updateWithTime:_lifetime + 1.f];
    }
    
    return self;
}

- (void) generateParticles
{
    for (NSInteger i = 0; i < _particleCount; ++i) {
        
        particle_t newParticle;
        
        newParticle.lifetime = [self randomNumberBetweenMin:0.f andMax:_lifetime withOffset:0.f];
        newParticle.startPosition = [self GLKVector3WithRandomNumbersInIntervalMin:0.f andMax:0.3f withOffset:-0.125f];
        newParticle.endPosition = [self GLKVector3WithRandomNumbersInIntervalMin:0.f andMax:2.f withOffset:-1.f];
        
        _particles.push_back(newParticle);
    }
}

#pragma mark -
#pragma mark Drawing

- (void) setupGL
{
    [_shaderObject loadShaders];
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, _particleCount * sizeof(particle_t), &_particles.front(), GL_STATIC_DRAW);
    
    glVertexAttribPointer(_shaderObject.in_lifetime, 1, GL_FLOAT,
                          GL_FALSE, sizeof(particle_t),
                          (const GLvoid *) offsetof(particle_t, lifetime));
    
    glVertexAttribPointer(_shaderObject.in_startPosition, 3, GL_FLOAT,
                          GL_FALSE, sizeof(particle_t),
                          (const GLvoid *) offsetof(particle_t, startPosition));
    
    glVertexAttribPointer(_shaderObject.in_endPosition, 3, GL_FLOAT,
                          GL_FALSE, sizeof(particle_t),
                          (const GLvoid *) offsetof(particle_t, endPosition));
}

- (void) drawWithProjectionMatrix:(GLKMatrix4)projectionMatrix eyePosition:(GLKVector3)eyePosition andFov:(float)fov
{
    glUseProgram(_shaderObject.program);
    
    // update uniforms
    glUniformMatrix4fv(_shaderObject.u_projectionMatrix, 1, GL_FALSE, projectionMatrix.m);
    glUniform3fv(_shaderObject.u_centerPosition, 1, _centerPosition.v);
    glUniform4fv(_shaderObject.u_color, 1, _particleColor.v);
    glUniform1f(_shaderObject.u_time, _time);
    glUniform1f(_shaderObject.u_fov, fov);
    glUniform3fv(_shaderObject.u_eyePosition, 1, eyePosition.v);
    glUniform2fv(_shaderObject.u_drawableSize, 1, _drawableSize.v);

    glEnableVertexAttribArray(_shaderObject.in_lifetime);
    glEnableVertexAttribArray(_shaderObject.in_startPosition);
    glEnableVertexAttribArray(_shaderObject.in_endPosition);

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glDrawArrays(GL_POINTS, 0, (int) _particles.size());
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDisableVertexAttribArray(_shaderObject.in_lifetime);
    glDisableVertexAttribArray(_shaderObject.in_startPosition);
    glDisableVertexAttribArray(_shaderObject.in_endPosition);
    
    glUseProgram(0);
}

- (void) updateWithTime:(NSTimeInterval) deltaTime
{
    _time += deltaTime;
    
    if (_time > _lifetime) {
        
        _time = 0.f;
        
        _centerPosition = [self GLKVector3WithRandomNumbersInIntervalMin:0.f andMax:1.f withOffset:-0.5f];
        _particleColor = [self GLKVector4WithRandomNumbersInIntervalMin:0.f andMax:0.5f withOffset:0.5f];
        _particleColor.a = 0.5f;
    }
}

#pragma mark -
#pragma mark Helper methods 

- (BOOL)loadTextureFromFilePath:(NSString *)filePath
{
    NSError *error;
    
    _spriteTexture = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&error];
    
    if (error || !_spriteTexture) {
        NSLog(@"ERR file %s line %d: %@", __FILE__, __LINE__, [error description]);
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Math 

- (float) randomNumberBetweenMin:(float) min andMax:(float) max withOffset:(float) offset
{
    float pseudoRandomNumber = min + static_cast <float> (rand()) / ( static_cast <float> (RAND_MAX/(max-min)));
    return pseudoRandomNumber + offset;
}

- (GLKVector3) GLKVector3WithRandomNumbersInIntervalMin:(float) min andMax:(float) max withOffset:(float) offset
{
    return GLKVector3Make([self randomNumberBetweenMin:min andMax:max withOffset:offset],
                          [self randomNumberBetweenMin:min andMax:max withOffset:offset],
                          [self randomNumberBetweenMin:min andMax:max withOffset:offset]);
    
}

- (GLKVector4) GLKVector4WithRandomNumbersInIntervalMin:(float) min andMax:(float) max withOffset:(float) offset
{
    return GLKVector4Make([self randomNumberBetweenMin:min andMax:max withOffset:offset],
                          [self randomNumberBetweenMin:min andMax:max withOffset:offset],
                          [self randomNumberBetweenMin:min andMax:max withOffset:offset],
                          [self randomNumberBetweenMin:min andMax:max withOffset:offset]);
}

@end
