//
//  OpenGLRenderer.h
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 4/24/16.
//  Copyright © 2016 ran. All rights reserved.
//

@import Foundation;
@import GLKit;

#import <OpenGLES/ES3/gl.h>

#import <ModelIO/ModelIO.h>

#import "ParticleSystemShaders.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface OpenGLRenderer : NSObject <GLKViewDelegate, GLKViewControllerDelegate>

- (void) resizeWithWidth:(GLuint)width andHeight:(GLuint)height;


@end
