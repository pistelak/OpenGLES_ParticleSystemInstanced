//
//  meshObject.m
//  OpenGLES_ParticleSystem
//
//  Created by Radek Pistelak on 5/6/16.
//  Copyright © 2016 ran. All rights reserved.
//

#import "meshObject.h"
#import "Shaders/glUtil.h"



@implementation meshObject
{
    GLuint _vao;
    NSArray<GLKMesh *> *_meshes;
    ParticleSystemShaders *_shaderObject;
}

- (instancetype) initWithModelName:(NSString *) modelName andShaderObject:(ParticleSystemShaders *) shaderObject;
{
    self = [super init];
    if (self) {
        
        _modelName = modelName;
        _shaderObject = shaderObject;
        
        if (![self loadGLKMeshes]) {
            return nil;
        }
    }
    
    return self;
}

#pragma mark -

- (BOOL) loadGLKMeshes
{
    NSError *error;
    _meshes = [GLKMesh newMeshesFromAsset:[self createAsset] sourceMeshes:nil error:&error];
    
    if (!_meshes || error) {
        return NO;
    }
    
    return YES;
}

- (MDLAsset *) createAsset
{
    GLKMeshBufferAllocator *allocator = [[GLKMeshBufferAllocator alloc] init];
    
    return [[MDLAsset alloc] initWithURL:[self urlForResource]
                        vertexDescriptor:[self modelIOVertexDescriptor]
                         bufferAllocator:allocator];
}

- (NSURL *) urlForResource
{
    return [[NSBundle mainBundle] URLForResource:_modelName withExtension:@"obj"];
}

- (MDLVertexDescriptor *) modelIOVertexDescriptor
{
    MDLVertexDescriptor *modelIOVertexDesc = [[MDLVertexDescriptor alloc] init];
    modelIOVertexDesc.attributes[0].name = MDLVertexAttributePosition;
    modelIOVertexDesc.attributes[0].format = MDLVertexFormatFloat3;
    modelIOVertexDesc.attributes[0].offset = 0;
    
    modelIOVertexDesc.attributes[1].name = MDLVertexAttributeNormal;
    modelIOVertexDesc.attributes[1].format = MDLVertexFormatFloat3;
    modelIOVertexDesc.attributes[1].offset = 12;

    modelIOVertexDesc.layouts[0].stride = 24;
    
    return modelIOVertexDesc;
}

/** 
 *  OpenGL vertex descriptor ...
 */
 
typedef struct {
    GLfloat position[3];
    GLfloat normal[3];
} vertex_t;

#pragma mark -
#pragma mark Drawing

- (void) drawInstanced:(int32_t) numberOfParticles
{
    glBindBuffer(GL_ARRAY_BUFFER, [[self vertexBuffer] glBufferName]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [[self elementBuffer] glBufferName]);
    
    const GLfloat stride = sizeof(vertex_t);
    
    glVertexAttribPointer(_shaderObject.in_position, 3, GL_FLOAT, NO, stride, offsetof(vertex_t, position));
    glEnableVertexAttribArray(_shaderObject.in_position);
    
    glVertexAttribPointer(_shaderObject.in_normal, 3, GL_FLOAT, NO, stride, (const void *) offsetof(vertex_t, normal));
    glEnableVertexAttribArray(_shaderObject.in_normal);
    
    glDrawElementsInstanced([[self submesh] mode],
                            [[self submesh] elementCount],
                            [[self submesh] type],
                            0, // indices
                            numberOfParticles);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glDisableVertexAttribArray(_shaderObject.in_position);
    glDisableVertexAttribArray(_shaderObject.in_normal);
}

#pragma mark -
#pragma mark Getter methods

- (GLKMesh *) mesh {
    return [_meshes firstObject];
}

- (GLKMeshBuffer *) vertexBuffer {
    return [self.mesh.vertexBuffers firstObject];
}

- (GLKSubmesh *) submesh {
    return [self.mesh.submeshes firstObject];
}

- (GLKMeshBuffer *) elementBuffer {
    return [self.submesh elementBuffer];
}

@end
