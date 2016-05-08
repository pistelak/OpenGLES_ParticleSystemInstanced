//
//  ParticleSystem.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ParticleSystem.h"

#import <vector>

const unsigned kMaximumNumberOfParticles = 100;
const unsigned kNumberOfInflightBuffers = 3;

typedef struct {
    GLKVector3 position;
    float scale;
} particle_t;

@interface ParticleSystem ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ParticleSystem
{
    std::vector<particle_t> _particles;
    
    /**
     * @brief Pocet castic ktere budou vykresleny na obrazovku.
     * Nepouzivat jako pocet instanci, protoze nemusi odpovidat skutecnemu poctu castic.
     * Promenna je automaticky kazdou vterinu navysena pomoci timeru.
     */
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
        _particleBatchSize = 10;
        
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
    if (_particleCount < kMaximumNumberOfParticles) {
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

- (void) draw
{
    std::vector<GLKMatrix4> modelMatrices = [self modelMatrices];

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
#pragma mark Helper "methods"

- (std::vector<GLKMatrix4>) modelMatrices
{
    std::vector<GLKMatrix4> modelMatrices;
    
    // new particles
    uint32_t currentNumberOfParticles = (uint32_t) _particles.size();
    uint32_t diff = _particleCount - currentNumberOfParticles;
    
    for (uint32_t i = 0; i < diff; ++i) {
        _particles.push_back(particleWithInitialPosition());
    }
    
    // adjust particle position
    currentNumberOfParticles = (uint32_t) _particles.size();
    
    for (uint32_t i = 0; i < currentNumberOfParticles; ++i) {
        particle_t *particle= &_particles.at(i);
        
        particle->position.y = particle->position.y + .001f;
        
        modelMatrices.push_back(particleModelMatrix(particle));
    }
    
    return modelMatrices;
}
        
static inline particle_t particleWithInitialPosition(void)
{
    particle_t newParticle;
    
    newParticle.position = GLKVector3Make(0, 0, 0);
    newParticle.scale = 0.1f;
    
    return newParticle;
}

static inline GLKMatrix4 particleModelMatrix(particle_t *particle)
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, particle->position.x, particle->position.y, particle->position.z);
    modelMatrix = GLKMatrix4Scale(modelMatrix, particle->scale, particle->scale, particle->scale);
    
    return modelMatrix;
}

#pragma mark -
#pragma mark Math 


- (float) randomNumberBetweenMin:(float) min andMax:(float) max withOffset:(float) offset
{
    float pseudoRandomNumber = min + static_cast <float> (rand()) / ( static_cast <float> (RAND_MAX/(max-min)));
    return pseudoRandomNumber + offset;
}
//
//- (GLKVector3) GLKVector3WithRandomNumbersInIntervalMin:(float) min andMax:(float) max withOffset:(float) offset
//{
//    return GLKVector3Make([self randomNumberBetweenMin:min andMax:max withOffset:offset],
//                          [self randomNumberBetweenMin:min andMax:max withOffset:offset],
//                          [self randomNumberBetweenMin:min andMax:max withOffset:offset]);
//    
//}
//
//- (GLKVector4) GLKVector4WithRandomNumbersInIntervalMin:(float) min andMax:(float) max withOffset:(float) offset
//{
//    return GLKVector4Make([self randomNumberBetweenMin:min andMax:max withOffset:offset],
//                          [self randomNumberBetweenMin:min andMax:max withOffset:offset],
//                          [self randomNumberBetweenMin:min andMax:max withOffset:offset],
//                          [self randomNumberBetweenMin:min andMax:max withOffset:offset]);
//}

@end
