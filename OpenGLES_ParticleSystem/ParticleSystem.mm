//
//  ParticleSystem.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ParticleSystem.h"

#import "Math.h"
#import "Particles.h"

const unsigned kNumberOfInflightBuffers = 3;

@interface ParticleSystem ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ParticleSystem
{
    std::vector<particle_t> _particles;
    
    uint32_t _particleCount;
    uint16_t _particleBatchSize;
   
    Mesh *_mesh;
    
    uint8_t _currentBufferIndex;
    
    GLsync _fences[kNumberOfInflightBuffers];
    GLuint _modelMatricesBuffers[kNumberOfInflightBuffers];
    GLuint _vertexArrayObjects[kNumberOfInflightBuffers];
    
    ParticleSystemShaders *_shaderObject;
}

- (instancetype) initWithMesh:(Mesh *) mesh andShader:(ParticleSystemShaders *) shaderObject
{
    self = [super init];
    if (self) {
        
        _shaderObject = shaderObject;
        _mesh = mesh;
        
        _particleCount = 0;
        _particleBatchSize = kBatchSize;
        
        for (unsigned i = 0; i < kNumberOfInflightBuffers; ++i) {
            _fences[i] = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
        }
        
        const NSTimeInterval timeInterval = 1.0; // in seconds
        _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                  target:self
                                                selector:@selector(increaseParticleCount:)
                                                userInfo:nil
                                                 repeats:YES];
        
        [self setupVertexArrayObjects];
    }
    
    return self;
}

- (void) increaseParticleCount:(NSTimer *) timer
{
    if ((_particleCount + _particleBatchSize) < kMaximumNumberOfParticles) {
        _particleCount += _particleBatchSize;
    } else {
        [_timer invalidate];
    }
}

#pragma mark -
#pragma mark Drawing

- (void) setupVertexArrayObjects
{
    const GLuint modelMatrixAttributePosition = _shaderObject.in_modelMatrix;
    for (unsigned i = 0; i < kNumberOfInflightBuffers; ++i) {
        
        glGenVertexArrays(1, &_vertexArrayObjects[i]);
        glBindVertexArray(_vertexArrayObjects[i]);
        
        glGenBuffers(1, &_modelMatricesBuffers[i]);
        glBindBuffer(GL_ARRAY_BUFFER, _modelMatricesBuffers[i]);
        glBufferData(GL_ARRAY_BUFFER, kMaximumNumberOfParticles * sizeof(GLKMatrix4), NULL, GL_DYNAMIC_DRAW);
        
        for (unsigned positionIndex = modelMatrixAttributePosition; positionIndex < modelMatrixAttributePosition + 4; ++positionIndex) {
            glEnableVertexAttribArray(positionIndex);
            glVertexAttribPointer(positionIndex, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4 * 4, (void *)(sizeof(float) * (positionIndex * 4)));
            glVertexAttribDivisor(positionIndex, 1);
        }
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    
        for (unsigned positionIndex = modelMatrixAttributePosition; positionIndex < modelMatrixAttributePosition + 4; ++positionIndex) {
            glDisableVertexAttribArray(positionIndex);
        }
    }
}

- (void) draw
{
    std::vector<GLKMatrix4> modelMatrices = updateParticles(&_particles, _particleCount);

    const uint32_t numberOfInstances = (uint32_t) modelMatrices.size();
    
    GLuint newDataLength = numberOfInstances * sizeof(GLKMatrix4);
    GLuint bufferLength = kMaximumNumberOfParticles * sizeof(GLKMatrix4);
    
    assert(newDataLength <= bufferLength);
    
    // Wait for fence.
    glClientWaitSync(_fences[_currentBufferIndex], GL_SYNC_FLUSH_COMMANDS_BIT, GL_TIMEOUT_IGNORED);
    glDeleteSync(_fences[_currentBufferIndex]);
    
    updateDataInArrayBuffer(_modelMatricesBuffers[_currentBufferIndex],
                            bufferLength,
                            &modelMatrices.front(),
                            newDataLength);
    
    // Draw.
    glBindVertexArray(_vertexArrayObjects[_currentBufferIndex]);
    
    [_mesh drawInstanced:numberOfInstances];
    
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
    BOOL success;
    
    const GLuint kOffset = 0;
    
    // Bind and map buffer.
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
    void *dst = glMapBufferRange(GL_ARRAY_BUFFER, kOffset, bufferLength,
                                 GL_MAP_WRITE_BIT | GL_MAP_FLUSH_EXPLICIT_BIT |
                                 GL_MAP_UNSYNCHRONIZED_BIT);
    
    // Modify buffer, flush, and unmap.
    memcpy(dst, newData, newDataSize);
    
    glFlushMappedBufferRange(GL_ARRAY_BUFFER, kOffset, bufferLength);
    
    success =glUnmapBuffer(GL_ARRAY_BUFFER);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    return success;
}

#pragma mark -

- (NSUInteger) currentNumberOfParticles {
    return _particles.size();
}

@end
