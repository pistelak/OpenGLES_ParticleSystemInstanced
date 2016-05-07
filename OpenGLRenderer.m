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
    
    GLuint _modelMatricesBuffer;
    
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
    
    static GLKMatrix4 modelMatrices[9];
    
    modelMatrices[0] = GLKMatrix4Identity;
    modelMatrices[0] = GLKMatrix4Scale(modelMatrices[0], 0.3f, 0.3f, 0.3f);
    modelMatrices[0] = GLKMatrix4Translate(modelMatrices[0], 1.f, 0, 0);
    
    modelMatrices[1] = GLKMatrix4Identity;
    modelMatrices[1] = GLKMatrix4Scale(modelMatrices[1], 0.3f, 0.3f, 0.3f);
    modelMatrices[1] = GLKMatrix4Translate(modelMatrices[1], -1.f, 0, 0);
    
    modelMatrices[2] = GLKMatrix4Identity;
    modelMatrices[2] = GLKMatrix4Scale(modelMatrices[2], 0.3f, 0.3f, 0.3f);
    modelMatrices[2] = GLKMatrix4Translate(modelMatrices[2], 3.f, 0, 0);
    
    modelMatrices[3] = GLKMatrix4Identity;
    modelMatrices[3] = GLKMatrix4Scale(modelMatrices[3], 0.3f, 0.3f, 0.3f);
    modelMatrices[3] = GLKMatrix4Translate(modelMatrices[3], -3.f, 0, 0);
    
    modelMatrices[4] = GLKMatrix4Identity;
    modelMatrices[4] = GLKMatrix4Scale(modelMatrices[4], 0.3f, 0.3f, 0.3f);
    modelMatrices[4] = GLKMatrix4Translate(modelMatrices[4], 5.f, 0, 0);
    
    modelMatrices[5] = GLKMatrix4Identity;
    modelMatrices[5] = GLKMatrix4Scale(modelMatrices[5], 0.3f, 0.3f, 0.3f);
    modelMatrices[5] = GLKMatrix4Translate(modelMatrices[5], -5.f, 0, 0);
    
    modelMatrices[6] = GLKMatrix4Identity;
    modelMatrices[6] = GLKMatrix4Scale(modelMatrices[6], 0.3f, 0.3f, 0.3f);
    modelMatrices[6] = GLKMatrix4Translate(modelMatrices[6], 1.f, 2.f, 0);
    
    modelMatrices[7] = GLKMatrix4Identity;
    modelMatrices[7] = GLKMatrix4Scale(modelMatrices[7], 0.3f, 0.3f, 0.3f);
    modelMatrices[7] = GLKMatrix4Translate(modelMatrices[7], -1.f, 2.f, 0);
    
    modelMatrices[8] = GLKMatrix4Identity;
    modelMatrices[8] = GLKMatrix4Scale(modelMatrices[8], 0.3f, 0.3f, 0.3f);
    modelMatrices[8] = GLKMatrix4Translate(modelMatrices[8], 3.f, 2.f, 0);
    
    glGenBuffers(1, &_modelMatricesBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _modelMatricesBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLKMatrix4) * 9, &modelMatrices, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

#pragma mark -
#pragma mark GLKit delegates

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUniformMatrix4fv(_shaderObject.u_viewMatrix, 1, NO, _viewMatrix.m);
    
    //model matrices
    glBindBuffer(GL_ARRAY_BUFFER, _modelMatricesBuffer);
    
    const GLuint modelMatrixAttributePosition = _shaderObject.in_modelMatrix;
    
    for (unsigned positionIndex = modelMatrixAttributePosition; positionIndex < modelMatrixAttributePosition+ 4; ++positionIndex) {
        glEnableVertexAttribArray(positionIndex);
        glVertexAttribPointer(positionIndex, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4 * 4, (void *)(sizeof(float) * (positionIndex * 4)));
        glVertexAttribDivisor(positionIndex, 1);
    }
    
    [_sphere draw];
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

- (GLKMatrix4) projectionMatrix
{
    const GLfloat fov = 45.f;
    const GLfloat aspect = _width/_height;
    const GLfloat nearZ = 0.1f;
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
