//
//  ShaderBaseObject+Binding.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 5/6/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ShaderBaseObject+Binding.h"

#import "glUtil.h"

#import <objc/runtime.h>

@implementation ShaderBaseObject (Binding)

- (void) bindObjCPropertiesOnShader
{
    unsigned int propertyCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &propertyCount);
    
    for (NSUInteger i = 0; i < propertyCount; ++i) {
        Ivar ivar = ivars[i];
        
        bindIvar(self.program, ivar_getName(ivar), [self ivarPosition:ivar]);
    }
    
    free(ivars);
}

static inline void bindIvar(GLuint program, const char *iVarName, GLuint *position)
{
    const char *propertyName = &iVarName[1];
    
    const static char *inPrefix = "in_";
    const static char *uPrefix = "u_";
    
    if (memcmp(propertyName, inPrefix, 3) == 0) {
        *position = glGetAttribLocation(program, propertyName);
    } else if (memcmp(propertyName, uPrefix, 2) == 0) {
        *position = glGetUniformLocation(program, propertyName);
    }
    
    GetGLError();
}

- (GLuint *) ivarPosition:(Ivar) ivar
{
    CFTypeRef mySelfRef = CFBridgingRetain(self);
    
    GLuint *position = (GLuint *) ((uint8_t *)mySelfRef + ivar_getOffset(ivar));
    
    CFBridgingRelease(mySelfRef);
    
    return position;
}

@end
