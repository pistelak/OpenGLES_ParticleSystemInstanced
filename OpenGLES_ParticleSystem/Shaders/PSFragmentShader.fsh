
static const char* PSFragmentShader = GLSL(300 es,
                                           
precision highp float;
                                           
// Const
const vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 materialAmbientColor = vec4(0.18, 0.18, 0.18, 1.0);
const vec4 materialDiffuseColor = vec4(0.4, 0.4, 0.4, 1.0);
const vec4 materialSpecularColor = vec4(1.0, 1.0, 1.0, 1.0);
const float materialShine = 50.0;

// In
in vec3 v_normalCameraSpace;
in vec3 v_eyeDirectionCameraSpace;
in vec3 v_lightDirectionCameraSpace;
                   
// Out
out vec4 out_color;
                                           
float saturate(float val) {
   return clamp(val, 0.0, 1.0);
}
                                           
void main()
{
    // Get the ambient color (the color that represents all the light that bounces around
    // the scene and illuminates the object).
    vec4 ambient_color = materialAmbientColor;
    
    // Calculate the diffuse color (the color of the object given by direct illumination).
    // This is done by using the dot product between the surface normal and the light
    // vector to estimate how much the suface is facing towards the light.
    vec3 n = normalize(v_normalCameraSpace);
    vec3 l = normalize(v_lightDirectionCameraSpace);
    float n_dot_l = saturate( dot(n, l) );
    
    vec4 diffuse_color = lightColor * n_dot_l * materialDiffuseColor;
    
    // Calculate the specular color (the color given by the bright higlight of a shiny
    // object). This is done by using the dot product to calculate how close the
    // reflection of the light is pointing towards the viewer (e). The angle is raised by
    // the materialShine factor to control the size of the highlight.
    vec3 e = normalize(v_eyeDirectionCameraSpace);
    vec3 r = -l + 2.0f * n_dot_l * n;
    float e_dot_r =  saturate( dot(e, r) );
    vec4 specular_color = materialSpecularColor * lightColor * pow(e_dot_r, materialShine);
    
    // Combine the ambient, specular and diffuse colors to get the final color
    out_color = vec4(ambient_color + diffuse_color + specular_color);
}
 
 );