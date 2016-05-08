//
//  Mesh.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 5/6/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shaders/ParticleSystemShaders.h"

@interface Mesh : NSObject

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithModelName:(NSString *) modelName andShaderObject:(ParticleSystemShaders *) shaderObject;

- (void) drawInstanced:(int32_t) instaceCount;

@property (nonatomic, copy, readonly) NSString * modelName;

@end
