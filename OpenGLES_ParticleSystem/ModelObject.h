//
//  ModelObject.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 5/6/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Shaders/ParticleSystemShaders.h"

#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <ModelIO/ModelIO.h>

@interface ModelObject : NSObject

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithModelName:(NSString *) modelName andShaderObject:(ParticleSystemShaders *) shaderObject;

- (void) drawInstanced:(int32_t) particleCount;

@property (nonatomic, copy, readonly) NSString * modelName;

@end
