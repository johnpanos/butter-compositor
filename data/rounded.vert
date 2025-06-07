// Rounded rectangle clipping shader (without blur)
// Extracted from GNOME Mutter compositor
// Original source: https://gitlab.gnome.org/GNOME/mutter/-/blob/858b5c12b1f55043964c2e2bd30de8cf112e76d2/src/compositor/meta-background-content.c#L138

// Uniform variables
uniform vec4 bounds;           // x, y: top left; z, w: bottom right
uniform float clip_radius;
uniform vec4 inner_bounds;
uniform float inner_clip_radius;
uniform vec2 pixel_step;
uniform int skip;
uniform float border_width;
uniform float border_brightness;

// Varying input (assuming standard texture coordinates)
varying vec2 cogl_tex_coord0_in;
varying vec4 cogl_color_out;

// Function to calculate coverage for rounded rectangle
float rounded_rect_coverage(vec2 p, vec4 bounds, float clip_radius)
{
    // Outside the bounds
    if (p.x < bounds.x || p.x > bounds.z
    || p.y < bounds.y || p.y > bounds.w) {
        return 0.0;
    }

    float center_left = bounds.x + clip_radius;
    float center_right = bounds.z - clip_radius;
    float center_x;

    if (p.x < center_left)
    center_x = center_left;
    else if (p.x > center_right)
    center_x = center_right;
    else
    return 1.0; // The vast majority of pixels exit early here

    float center_top = bounds.y + clip_radius;
    float center_bottom = bounds.w - clip_radius;
    float center_y;

    if (p.y < center_top)
    center_y = center_top;
    else if (p.y > center_bottom)
    center_y = center_bottom;
    else
    return 1.0;

    vec2 delta = p - vec2(center_x, center_y);
    float dist_squared = dot(delta, delta);

    // Fully outside the circle
    float outer_radius = clip_radius + 0.5;
    if (dist_squared >= (outer_radius * outer_radius))
    return 0.0;

    // Fully inside the circle
    float inner_radius = clip_radius - 0.5;
    if (dist_squared <= (inner_radius * inner_radius))
    return 1.0;

    // Only pixels on the edge of the curve need expensive antialiasing
    return outer_radius - sqrt(dist_squared);
}

// Main fragment shader code for rounded clipping with optional border
void main()
{
    if (skip == 0) {
        vec2 texture_coord = cogl_tex_coord0_in.xy / pixel_step;

        float outer_alpha = rounded_rect_coverage(texture_coord,
                                                  bounds,
                                                  clip_radius);
        if (border_width > 0.0) {
            float inner_alpha = rounded_rect_coverage(texture_coord,
                                                      inner_bounds,
                                                      inner_clip_radius);
            float border_alpha = clamp(outer_alpha - inner_alpha, 0.0, 1.0)
            * cogl_color_out.a;

            cogl_color_out *= smoothstep(0.0, 0.6, inner_alpha);
            cogl_color_out = mix(cogl_color_out,
                                 vec4(vec3(border_brightness), 1.0),
                                 border_alpha);
        } else {
            cogl_color_out = cogl_color_out * outer_alpha;
        }
    }
}