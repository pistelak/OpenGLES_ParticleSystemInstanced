//
//  ViewController.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 07.04.16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@dynamic view;

- (void) loadView
{
    self.view = [[View alloc] init];
    
    [self setPreferredFramesPerSecond:60];
    [self setDelegate:self.view.renderer];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}


@end
