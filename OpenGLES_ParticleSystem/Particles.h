//
//  Particles.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 5/9/16.
//  Copyright © 2016 ran. All rights reserved.
//

#ifndef Particles_h
#define Particles_h

#ifdef __cplusplus

#import <vector>

typedef struct {
    GLKVector3 position;
    GLKVector3 vec;
    float scale;
} particle_t;

const unsigned kMaximumNumberOfParticles = 10000;
const unsigned kBatchSize = 100;

static inline GLKMatrix4 particleModelMatrix(particle_t *particle)
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, particle->position.x, particle->position.y, particle->position.z);
    modelMatrix = GLKMatrix4Scale(modelMatrix, particle->scale, particle->scale, particle->scale);
    
    return modelMatrix;
}

static inline particle_t particleWithInitialPosition(void)
{
    particle_t newParticle;
    
    newParticle.position = GLKVector3Make(0.f, 0.f, 0.f);
    newParticle.scale = 0.05f;
    
    // inspired by https://github.com/floooh/oryol/blob/master/code/Samples/Instancing/Instancing.cc
    newParticle.vec = ballRandomGLKVector3(0.5f);
    newParticle.vec.y += 2.f;
    
    return newParticle;
}

static inline std::vector<GLKMatrix4> updateParticles(std::vector<particle_t> *particles, uint32_t newParticleCount)
{
    std::vector<GLKMatrix4> modelMatrices;
    
    // new particles
    uint32_t currentNumberOfParticles = (uint32_t) particles->size();
    uint32_t diff = newParticleCount - currentNumberOfParticles;
    
    for (uint32_t i = 0; i < diff; ++i) {
        particles->push_back(particleWithInitialPosition());
    }
    
    // adjust particle position
    const GLfloat kFrameTime = 1.0f / 60.0f;
    currentNumberOfParticles = (uint32_t) particles->size();
    
    for (uint32_t i = 0; i < currentNumberOfParticles; ++i) {
        particle_t *particle= &particles->at(i);
        
        // insipred by https://github.com/floooh/oryol/blob/master/code/Samples/Instancing/Instancing.cc
        particle->vec.y -= 1 * kFrameTime;
        particle->position = GLKVector3Add(particle->position, GLKVector3MultiplyScalar(particle->vec, kFrameTime));
        
        if (particle->position.y < -2.0f) {
            particle->position.y = -1.8f;
            particle->vec.y = -particle->vec.y;
            particle->vec = GLKVector3MultiplyScalar(particle->vec, 0.8f);
        }
        
        modelMatrices.push_back(particleModelMatrix(particle));
    }
    
    return modelMatrices;
}

#endif // cplusplus

#endif /* Particles_h */
