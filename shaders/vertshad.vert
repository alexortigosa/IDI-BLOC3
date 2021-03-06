#version 330 core

in vec3 vertex;
in vec3 normal;

in vec3 matamb;
in vec3 matdiff;
in vec3 matspec;
in float matshin;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 TG;
uniform vec3 posFoc;
uniform vec3 colFoc;


// Valors per als components que necessitem dels focus de llum
vec3 colFocus = vec3(0.8, 0.8, 0.8);
vec3 llumAmbient = vec3(0.2, 0.2, 0.2);
vec3 posFocus = vec3(1, 1, 1);  // en SCA

out vec3 fcolor;
out vec3 matamb2;
out vec3 matdiff2;
out vec3 matspec2;
out float matshin2;
out vec4 posVertSCO;
out vec3 normalSCO;

vec3 Lambert (vec3 NormSCO, vec3 L) 
{
    // S'assumeix que els vectors que es reben com a paràmetres estan normalitzats

    // Inicialitzem color a component ambient
    vec3 colRes = llumAmbient * matamb;

    // Afegim component difusa, si n'hi hax
    if (dot (L, NormSCO) > 0)
      colRes = colRes + colFocus * matdiff * dot (L, NormSCO);
    return (colRes);
}

vec3 Phong (vec3 NormSCO, vec3 L, vec4 vertSCO) 
{
    // Els vectors estan normalitzats

    // Inicialitzem color a Lambert
    vec3 colRes = Lambert (NormSCO, L);

    // Calculem R i V
    if (dot(NormSCO,L) < 0)
      return colRes;  // no hi ha component especular

    vec3 R = reflect(-L, NormSCO); // equival a: normalize (2.0*dot(NormSCO,L)*NormSCO - L);
    vec3 V = normalize(-vertSCO.xyz);

    if ((dot(R, V) < 0) || (matshin == 0))
      return colRes;  // no hi ha component especular
    
    // Afegim la component especular
    float shine = pow(max(0.0, dot(R, V)), matshin);
    return (colRes + matspec * colFocus * shine); 
}

void main()
{
    
    //fcolor = matdiff;
    colFocus=colFoc;
    posFocus=posFoc;
    posVertSCO = view*TG*vec4(vertex,1.0);
    vec4 posF = view*vec4(posFocus,1.0);
    vec4 L = posF - posVertSCO;
    mat3 NormalMatrix = inverse (transpose (mat3 (view * TG)));
    normalSCO = NormalMatrix*normal;
    //fcolor=Lambert(normalize(N),normalize(L.xyz));
    fcolor=Phong(normalize(normalSCO),normalize(L).xyz,posVertSCO);
    matamb2=matamb;
    matdiff2=matdiff;
    matspec2=matspec;
    matshin2=matshin;
    gl_Position = proj * view * TG * vec4 (vertex, 1.0);
}
