// Vertex shader

// AAPL metal sample code

const char* PSVertexShader = GLSL(300 es,

precision mediump float;
                                  
// Uniforms
uniform highp mat4 u_projectionMatrix;
uniform highp mat4 u_viewMatrix;
uniform highp mat4 u_modelMatrix;

// Attributes
in highp vec3 in_position;
in highp vec3 in_normal;
                                  
// Out
out vec3 v_normalCameraSpace;
out vec3 v_eyeDirectionCameraSpace;
out vec3 v_lightDirectionCameraSpace;
                                  
// Constants
const vec3 lightPosition = vec3(-1.0, 1.0, -1.0);

void main(void)
{
    mat4 modelViewMatrix = u_viewMatrix * u_modelMatrix;
    mat4 mvpMatrix = u_projectionMatrix * modelViewMatrix;
    
    // Calculate the position of the object from the perspective of the camera
    vec4 vertexPositionModelSpace = vec4(in_position, 1.0);
    gl_Position = mvpMatrix * vertexPositionModelSpace;
    
    // Calculate the normal from the perspective of the camera
    v_normalCameraSpace = (normalize(modelViewMatrix * vec4(in_normal, 0.0))).xyz;
    
    // Calculate the view vector from the perspective of the camera
    vec3 vertexPositionCameraSpace = (u_viewMatrix * u_modelMatrix * vertexPositionModelSpace).xyz;
    v_eyeDirectionCameraSpace = vec3(0.0) - vertexPositionCameraSpace;
    
    // Calculate the direction of the light from the position of the camera
    vec3 lightPositionCameraSpace = (u_viewMatrix * vec4(lightPosition, 1.0f)).xyz;
    v_lightDirectionCameraSpace = lightPositionCameraSpace + v_eyeDirectionCameraSpace;
}

);