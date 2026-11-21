export const ballCount = 12;
export const haloWidth = 0.05;
export const blur = 0.035;
export const colorTop = [16, 0, 190];
export const colorBottom = [12, 5, 123];
export const haloColor = [255, 0, 2];
export const haloStrength = 0.55;

/**
 * GLSL ES 1.00 on purpose: works on WebGL 1 and 2. Only float maths, so it's
 * fine on mobile GPUs where mediump ints are 16-bit.
 */
export const vertexShader = `
attribute vec2 position;

void main() {
  gl_Position = vec4(position, 0., 1.);
}
`;

export const fragmentShader = `
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 u_resolution;
// xy = centre, z = radius. Short-side units, origin at screen centre, y up.
uniform vec3 u_balls[${ballCount}];

// Smooth-min radius. Higher = balls merge from further apart.
const float mergeSmoothness = .16;
// float() because JS prints 1, not 1.0, and GLSL ES won't convert int to float.
const vec3 colorTop = vec3(${colorTop}) / 255.;
const vec3 colorBottom = vec3(${colorBottom}) / 255.;
const vec3 haloColor = vec3(${haloColor}) / 255.;
const float haloStrength = float(${haloStrength});
const float haloWidth = float(${haloWidth});
const float blur = float(${blur});

// Polynomial smooth min (Inigo Quilez).
float smoothUnion(float a, float b, float k) {
  float h = max(k - abs(a - b), 0.) / k;
  return min(a, b) - h * h * k * .25;
}

void main() {
  float shortSide = min(u_resolution.x, u_resolution.y);
  vec2 uv = (gl_FragCoord.xy - .5 * u_resolution) / shortSide;

  // Start "far away". Keep it small: mediump floats may only reach 2^14.
  float dist = 10.;
  for (int i = 0; i < ${ballCount}; i++) {
    vec3 ball = u_balls[i];
    dist = smoothUnion(dist, length(uv - ball.xy) - ball.z, mergeSmoothness);
  }

  vec3 gradient = mix(colorBottom, colorTop, gl_FragCoord.y / u_resolution.y);

  // body: inside the blobs. halo: body + a rim of haloWidth around it.
  float body = 1. - smoothstep(-blur, blur, dist);
  float halo = 1. - smoothstep(haloWidth - blur, haloWidth + blur, dist);
  vec3 color = mix(max(haloColor * haloStrength, gradient), gradient, body);

  // Premultiplied alpha; outside the halo is transparent (page gradient).
  gl_FragColor = vec4(color * halo, halo);
}
`;
