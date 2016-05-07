
/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Includes the appropriate OpenGL headers (depending on whether this
  is built for iOS or OSX) and provides some API utility functions.
 */

#ifndef __GL_UTIL_H__
#define __GL_UTIL_H__

#import <GLKit/GLKit.h>

static inline const char * GetGLErrorString(GLenum error)
{
	const char *str;
	switch( error )
	{
		case GL_NO_ERROR:
			str = "GL_NO_ERROR";
			break;
		case GL_INVALID_ENUM:
			str = "GL_INVALID_ENUM";
			break;
		case GL_INVALID_VALUE:
			str = "GL_INVALID_VALUE";
			break;
		case GL_INVALID_OPERATION:
			str = "GL_INVALID_OPERATION";
			break;		
		default:
			str = "(ERROR: Unknown Error Enum)";
			break;
	}
	return str;
}

#define GetGLError()									\
{														\
    GLenum err = glGetError();							\
    while (err != GL_NO_ERROR) {						\
        NSLog(@"GLError %s set in File:%s Line:%d\n",   \
        GetGLErrorString(err), __FILE__, __LINE__);	    \
        err = glGetError();								\
    }													\
}


#endif // __GL_UTIL_H__

