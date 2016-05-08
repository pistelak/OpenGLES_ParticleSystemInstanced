//
//  Math.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 5/8/16.
//  Copyright © 2016 ran. All rights reserved.
//

#ifndef Math_h
#define Math_h

#import <GLKit/GLKit.h>

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

#pragma mark -
#pragma mark Random

static inline float randomNumber(float min, float max, float offset)
{
    float pseudoRandomNumber = min + (float) (rand()) / ( (float) (RAND_MAX/(max-min)));
    return pseudoRandomNumber + offset;
}

static inline GLKVector3 randomGLKVector3(float min, float max, float offset)
{
    return GLKVector3Make(randomNumber(min, max, offset),
                          randomNumber(min, max, offset),
                          randomNumber(min, max, offset));
}

static inline GLKVector3 ballRandomGLKVector3(float radius)
{
    // inspired by OpenGL Math
    GLKVector3 result;
    float length;
    
    do {
        result = randomGLKVector3(0, radius, -radius/2);
        length = GLKVector3Length(result);
        
    } while (length > radius);
    
    return result;
}

#endif /* Math_h */
