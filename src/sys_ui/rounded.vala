using Clutter;
using Cogl;

namespace Panos {
    public class RoundedClipEffect : Clutter.ShaderEffect {
        private float _clip_radius = 10.0f;

        private const string FRAGMENT_SHADER_SOURCE = """
uniform sampler2D tex;
uniform vec2 size;
uniform float radius;

void main() {
    vec4 c = texture2D(tex, cogl_tex_coord0_in.xy);
    vec2 uv = cogl_tex_coord0_in.xy * size;

    vec2 center = size * 0.5;
    vec2 q = abs(uv - center) - (size * 0.5 - radius);
    float d = min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;

    float mask = smoothstep(1.0, -1.0, d);
    cogl_color_out = c * mask;
}
""";

        public RoundedClipEffect() {
            Object(shader_type: Cogl.ShaderType.FRAGMENT);

            // Set the shader source
            set_shader_source(FRAGMENT_SHADER_SOURCE);
        }

        public override string get_static_shader_source() {
            return FRAGMENT_SHADER_SOURCE;
        }

        public override void paint_target(Clutter.PaintNode node, Clutter.PaintContext paint_context) {
            var actor = get_actor();
            if (actor == null)return;

            float width, height;
            get_target_size(out width, out height);

            // Set uniforms
            set_uniform_vec2("size", width, height);
            set_uniform_float("radius", _clip_radius);

            // Chain up to parent
            base.paint_target(node, paint_context);
        }

        // Helper methods for setting different uniform types
        private void set_uniform_int(string name, int value) {
            var gvalue = GLib.Value(typeof (int));
            gvalue.set_int(value);
            set_uniform_value(name, gvalue);
        }

        private void set_uniform_float(string name, float value) {
            var gvalue = GLib.Value(typeof (float));
            gvalue.set_float(value);
            set_uniform_value(name, gvalue);
        }

        private void set_uniform_vec2(string name, float x, float y) {
            float[] floats = { x, y };
            var gvalue = GLib.Value(typeof (Clutter.ShaderFloat));
            Clutter.Value.set_shader_float(gvalue, floats);

            set_uniform_value(name, gvalue);
        }

        private void set_uniform_vec4(string name, float x, float y, float z, float w) {
            float[] floats = { x, y, z, w };
            var gvalue = GLib.Value(typeof (Clutter.ShaderFloat));
            Clutter.Value.set_shader_float(gvalue, floats);

            set_uniform_value(name, gvalue);
        }

        // Public API properties and methods
        public float clip_radius {
            get { return _clip_radius; }
            set {
                _clip_radius = value;
                queue_repaint();
            }
        }
    }
}