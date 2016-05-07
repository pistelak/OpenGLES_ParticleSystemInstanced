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

#import "ModelObject.h" 

@implementation OpenGLRenderer
{
    /*
     Using ivars instead of properties to avoid any performance penalities with
     the Objective-C runtime.
     */
    
    CGFloat _width;
    CGFloat _height;
    
    CGFloat _angle;
    GLKVector3 _eyePosition;
    GLKMatrix4 _viewMatrix;
    
    ParticleSystemShaders *_shaderObject;
    
    ModelObject *_sphere;
    ModelObject *_cube;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        
        _shaderObject = [[ParticleSystemShaders alloc] init];
        
        _sphere = [[ModelObject alloc] initWithModelName:@"sphere" andShaderObject:_shaderObject];
        _cube = [[ModelObject alloc] initWithModelName:@"cube" andShaderObject:_shaderObject];
        
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
    
    glUniformMatrix4fv(_shaderObject.u_projectionMatrix, 1, NO, [self projectionMatrix].m);
}

- (void) prepareToDraw
{
    glClearColor(0.f, 0.7f, 0.f, 1.f);
    
    glUseProgram(_shaderObject.program);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    glUniformMatrix4fv(_shaderObject.u_modelMatrix, 1, NO, GLKMatrix4Identity.m);
}

#pragma mark -
#pragma mark GLKit delegates

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUniformMatrix4fv(_shaderObject.u_viewMatrix, 1, NO, _viewMatrix.m);
    
//    [_sphere draw];
    [_cube draw];
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

- (GLKMatrix4) projectionMatrix
{
    const GLfloat fov = 45.f;
    const GLfloat aspect = _width/_height;
    const GLfloat nearZ = 0.01f;
    const GLfloat farZ = 100.f;
    
    return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fov), aspect, nearZ, farZ);
}

static inline GLKMatrix4 lookAt(GLKVector3 cameraPosition)
{
    return GLKMatrix4MakeLookAt(cameraPosition.x, cameraPosition.y, cameraPosition.z,
                                0.f, 0.f, 0.f,
                                0.f, 1.f, 0.f);
}

@end
