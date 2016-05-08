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

const unsigned kMaximumNumberOfParticles = 1000;
const unsigned kNumberOfInflightBuffers = 3;

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
   
    GLsync _fences[kNumberOfInflightBuffers];
    GLuint _modelMatricesBuffers[kNumberOfInflightBuffers];
    GLuint _vertexArrayObjects[kNumberOfInflightBuffers];
    
    unsigned _currentBufferIndex;
    unsigned _currentNumberOfParticles;
}

- (instancetype) init
{
    self = [super init];
    if (self) {

        _currentBufferIndex = 0;
        _currentNumberOfParticles = 0;
        
        for (unsigned i = 0; i < kNumberOfInflightBuffers; ++i) {
            _fences[i] = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
        }
        
        _shaderObject = [[ParticleSystemShaders alloc] init];
        _sphere = [[ModelObject alloc] initWithModelName:@"sphere" andShaderObject:_shaderObject];
        
        [self updateCameraWithTime:0];
        [self prepareToDraw];
    }
    
    return self;
}

//- (void) increaseNumberOfParticles
//{
//    if (_currentNumberOfParticles < kMaximumNumberOfParticles) {
//        _currentNumberOfParticles += 100;
//    }
//}

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
    
    // Vertex array objects
    const GLuint modelMatrixAttributePosition = _shaderObject.in_modelMatrix;
    for (unsigned i = 0; i < kNumberOfInflightBuffers; ++i) {
        
        glGenVertexArrays(1, &_vertexArrayObjects[i]);
        glBindVertexArray(_vertexArrayObjects[i]);
        
        glGenBuffers(1, &_modelMatricesBuffers[i]);
        glBindBuffer(GL_ARRAY_BUFFER, _modelMatricesBuffers[i]);
        glBufferData(GL_ARRAY_BUFFER, kMaximumNumberOfParticles * sizeof(GLKMatrix4), NULL, GL_STREAM_DRAW);
        
        for (unsigned positionIndex = modelMatrixAttributePosition; positionIndex < modelMatrixAttributePosition + 4; ++positionIndex) {
            glEnableVertexAttribArray(positionIndex);
            glVertexAttribPointer(positionIndex, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4 * 4, (void *)(sizeof(float) * (positionIndex * 4)));
            glVertexAttribDivisor(positionIndex, 1);
        }
    }
    
    for (unsigned positionIndex = modelMatrixAttributePosition; positionIndex < modelMatrixAttributePosition + 4; ++positionIndex) {
        glDisableVertexAttribArray(positionIndex);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

#pragma mark -
#pragma mark GLKit delegates

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Update uniforms.
    glUniformMatrix4fv(_shaderObject.u_viewMatrix, 1, NO, _viewMatrix.m);
    
    /**
     * Update model matrices and draw.
     */
    
    _currentNumberOfParticles = 9;
    
    static GLKMatrix4 firstModelMatrices[9];
    
    firstModelMatrices[0] = GLKMatrix4Identity;
    firstModelMatrices[0] = GLKMatrix4Scale(firstModelMatrices[0], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[0] = GLKMatrix4Translate(firstModelMatrices[0], 1.f, 0, 0);
    
    firstModelMatrices[1] = GLKMatrix4Identity;
    firstModelMatrices[1] = GLKMatrix4Scale(firstModelMatrices[1], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[1] = GLKMatrix4Translate(firstModelMatrices[1], -1.f, 0, 0);
    
    firstModelMatrices[2] = GLKMatrix4Identity;
    firstModelMatrices[2] = GLKMatrix4Scale(firstModelMatrices[2], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[2] = GLKMatrix4Translate(firstModelMatrices[2], 3.f, 0, 0);
    
    firstModelMatrices[3] = GLKMatrix4Identity;
    firstModelMatrices[3] = GLKMatrix4Scale(firstModelMatrices[3], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[3] = GLKMatrix4Translate(firstModelMatrices[3], -3.f, 0, 0);
    
    firstModelMatrices[4] = GLKMatrix4Identity;
    firstModelMatrices[4] = GLKMatrix4Scale(firstModelMatrices[4], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[4] = GLKMatrix4Translate(firstModelMatrices[4], 5.f, 0, 0);
    
    firstModelMatrices[5] = GLKMatrix4Identity;
    firstModelMatrices[5] = GLKMatrix4Scale(firstModelMatrices[5], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[5] = GLKMatrix4Translate(firstModelMatrices[5], -5.f, 0, 0);
    
    firstModelMatrices[6] = GLKMatrix4Identity;
    firstModelMatrices[6] = GLKMatrix4Scale(firstModelMatrices[6], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[6] = GLKMatrix4Translate(firstModelMatrices[6], 1.f, 2.f, 0);
    
    firstModelMatrices[7] = GLKMatrix4Identity;
    firstModelMatrices[7] = GLKMatrix4Scale(firstModelMatrices[7], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[7] = GLKMatrix4Translate(firstModelMatrices[7], -1.f, 2.f, 0);
    
    firstModelMatrices[8] = GLKMatrix4Identity;
    firstModelMatrices[8] = GLKMatrix4Scale(firstModelMatrices[8], 0.3f, 0.3f, 0.3f);
    firstModelMatrices[8] = GLKMatrix4Translate(firstModelMatrices[8], 3.f, 2.f, 0);
    
    static GLKMatrix4 secondModelMatrices[9];
    
    secondModelMatrices[0] = GLKMatrix4Identity;
    secondModelMatrices[0] = GLKMatrix4Scale(secondModelMatrices[0], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[0] = GLKMatrix4Translate(secondModelMatrices[0], 1.f, 0, 0);
    
    secondModelMatrices[1] = GLKMatrix4Identity;
    secondModelMatrices[1] = GLKMatrix4Scale(secondModelMatrices[1], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[1] = GLKMatrix4Translate(secondModelMatrices[1], -1.f, 0, 0);
    
    secondModelMatrices[2] = GLKMatrix4Identity;
    secondModelMatrices[2] = GLKMatrix4Scale(secondModelMatrices[2], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[2] = GLKMatrix4Translate(secondModelMatrices[2], 3.f, 0, 0);
    
    secondModelMatrices[3] = GLKMatrix4Identity;
    secondModelMatrices[3] = GLKMatrix4Scale(secondModelMatrices[3], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[3] = GLKMatrix4Translate(secondModelMatrices[3], -3.f, 0, 0);
    
    secondModelMatrices[4] = GLKMatrix4Identity;
    secondModelMatrices[4] = GLKMatrix4Scale(secondModelMatrices[4], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[4] = GLKMatrix4Translate(secondModelMatrices[4], 5.f, 0, 0);
    
    secondModelMatrices[5] = GLKMatrix4Identity;
    secondModelMatrices[5] = GLKMatrix4Scale(secondModelMatrices[5], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[5] = GLKMatrix4Translate(secondModelMatrices[5], -5.f, 0, 0);
    
    secondModelMatrices[6] = GLKMatrix4Identity;
    secondModelMatrices[6] = GLKMatrix4Scale(secondModelMatrices[6], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[6] = GLKMatrix4Translate(secondModelMatrices[6], 1.f, 2.f, 0);
    
    secondModelMatrices[7] = GLKMatrix4Identity;
    secondModelMatrices[7] = GLKMatrix4Scale(secondModelMatrices[7], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[7] = GLKMatrix4Translate(secondModelMatrices[7], -1.f, 2.f, 0);
    
    secondModelMatrices[8] = GLKMatrix4Identity;
    secondModelMatrices[8] = GLKMatrix4Scale(secondModelMatrices[8], 0.1f, 0.1f, 0.1f);
    secondModelMatrices[8] = GLKMatrix4Translate(secondModelMatrices[8], 3.f, 2.f, 0);
    
    GLKMatrix4 *newData;
    if (_currentBufferIndex == 0) {
        newData = &secondModelMatrices[0];
    } else {
        newData = &firstModelMatrices[0];
    }
    
    GLuint newDataLength = _currentNumberOfParticles * sizeof(GLKMatrix4);
    GLuint bufferLength = kMaximumNumberOfParticles * sizeof(GLKMatrix4);
    
    assert(newDataLength < bufferLength);
    
    // Wait for fence.
    glClientWaitSync(_fences[_currentBufferIndex], GL_SYNC_FLUSH_COMMANDS_BIT, GL_TIMEOUT_IGNORED);
    glDeleteSync(_fences[_currentBufferIndex]);
    
    updateDataInArrayBuffer(_modelMatricesBuffers[_currentBufferIndex],
                            bufferLength,
                            newData,
                            newDataLength);
    
    // Draw.
    glBindVertexArray(_vertexArrayObjects[_currentBufferIndex]);
    
    [_sphere drawInstanced:_currentNumberOfParticles];
    
    glBindVertexArray(0);
    
    // New fence for this frame.
    _fences[_currentBufferIndex] = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
    
    // Update buffer index.
    _currentBufferIndex = (_currentBufferIndex + 1) % kNumberOfInflightBuffers;
    
}

static inline BOOL updateDataInArrayBuffer(const GLuint buffer,
                                           const GLuint bufferLength,
                                           const void *newData,
                                           const size_t newDataSize)
{
    const GLuint kOffset = 0;
    
    // Bind and map buffer.
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
    void *dst = glMapBufferRange(GL_ARRAY_BUFFER, kOffset, bufferLength,
                                 GL_MAP_WRITE_BIT | GL_MAP_FLUSH_EXPLICIT_BIT |
                                 GL_MAP_UNSYNCHRONIZED_BIT);
    
    // Modify buffer, flush, and unmap.
    memcpy(dst, newData, newDataSize);
    
    glFlushMappedBufferRange(GL_ARRAY_BUFFER, kOffset, bufferLength);
    
    return glUnmapBuffer(GL_ARRAY_BUFFER);
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

static inline GLKMatrix4 projectionMatrix(GLuint width, GLuint height)
{
    static const GLfloat fov = 45.f;
    const GLfloat aspect = width/height;
    static const GLfloat nearZ = 0.1f;
    static const GLfloat farZ = 100.f;
    
    return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fov), aspect, nearZ, farZ);
}

static inline GLKMatrix4 lookAt(GLKVector3 cameraPosition)
{
    static const GLKVector3 kCenter = {0.0f, 0.0f, 0.0f};
    static const GLKVector3 kUp     = {0.0f, 1.0f, 0.0f};
    
    return GLKMatrix4MakeLookAt(cameraPosition.x, cameraPosition.y, cameraPosition.z,
                                kCenter.x, kCenter.y, kCenter.z,
                                kUp.x, kUp.y, kUp.z);
}

static inline GLKMatrix4 modelMatrixWithPositionAndScale(GLKVector3 position, float scale)
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, position.x, position.y, position.z);
    modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, scale);
    
    return modelMatrix;
}



@end
