//
//  OpenGLRenderer.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "OpenGLRenderer.h"
#import "glUtil.h"

#import "ParticleSystemShaders.h"
#import "Mesh.h"
#import "ParticleSystem.h"

#import "Math.h"

@implementation OpenGLRenderer
{
    /*
     Using ivars instead of properties to avoid any performance penalities with
     the Objective-C runtime.
     */
    
    BOOL _firstDrawOccurred;
    CFTimeInterval _timeSinceLastDraw;
    CFTimeInterval _timeSinceLastDrawPreviousTime;
    NSUInteger _numberOfRenderedParticles;
    
    CGFloat _width;
    CGFloat _height;
    
    CGFloat _angle;
    GLKVector3 _eyePosition;
    GLKMatrix4 _viewMatrix;
    
    ParticleSystemShaders *_shaderObject;
    ParticleSystem *_particleSystem;
    Mesh *_sphere;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        
        _firstDrawOccurred = NO;

        _shaderObject = [[ParticleSystemShaders alloc] init];
        _sphere = [[Mesh alloc] initWithModelName:@"sphere" andShaderObject:_shaderObject];
        _particleSystem = [[ParticleSystem alloc] initWithMesh:_sphere andShader:_shaderObject];
        
        [self updateCameraWithTime:0];
        [self prepareToDraw];
    }
    
    return self;
}

- (void) resizeWithWidth:(GLuint)width andHeight:(GLuint)height
{
    _width = width;
    _height = height;
    
    glViewport(0, 0, _width, _height);
    glUniformMatrix4fv(_shaderObject.u_projectionMatrix, 1, NO, projectionMatrix(width, height).m);
}

- (void) prepareToDraw
{
    glClearColor(0.f, 0.7f, 0.f, 1.f);
    
    glUseProgram(_shaderObject.program);

    glEnable(GL_DEPTH_TEST);
}

#pragma mark -
#pragma mark GLKit delegates

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if(!_firstDrawOccurred) {
        _timeSinceLastDraw             = 0.0;
        _timeSinceLastDrawPreviousTime = CACurrentMediaTime();
        _firstDrawOccurred              = YES;
    }
    else {
        CFTimeInterval currentTime = CACurrentMediaTime();
        _timeSinceLastDraw = currentTime - _timeSinceLastDrawPreviousTime;
        _timeSinceLastDrawPreviousTime = currentTime;
        
        NSLog(@"Particles: %lu - frameTime: %f", _numberOfRenderedParticles, _timeSinceLastDraw);
    }
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Update uniforms.
    glUniformMatrix4fv(_shaderObject.u_viewMatrix, 1, NO, _viewMatrix.m);
    
    _numberOfRenderedParticles = [_particleSystem currentNumberOfParticles];
    
    [_particleSystem draw];
    
    _timeSinceLastDraw = CFAbsoluteTimeGetCurrent();
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    [self updateCameraWithTime:[controller timeSinceLastUpdate]];
}

- (void) updateCameraWithTime:(NSTimeInterval) timeInterval
{
    _angle += timeInterval * 0.1;
    _eyePosition = GLKVector3Make(sinf(_angle) * 10.f, 2.5f, cosf(_angle) * 10.f);
    _viewMatrix = lookAt(_eyePosition);
}

#pragma mark -
#pragma mark MVP matrices



@end
