namespace Panos {
    public class RoundedShaderEffect : Clutter.ShaderEffect {
        public RoundedShaderEffect () {
            Object (
                    shader_type: Cogl.ShaderType.FRAGMENT
            );

            try {
                uint8[] contents;

                var file = File.new_for_path ("/home/john/Projects/butter-compositor/data/rounded.vert");
                file.load_contents (null, out contents, null);

                stdout.printf ("%s", (string) contents);

                info ("%s", (string) contents);

                set_shader_source ((string) contents);
            } catch (Error e) {
                critical ("Unable to load rounded.vert: %s", e.message);
            }
        }

        public override void paint_target (Clutter.PaintNode node, Clutter.PaintContext ctx) {
            var actor = get_actor ();
        }
    }

    public class MenuBar : Clutter.Actor {
        public MenuBar () {
            width = 120;
            height = 120;
            fixed_x = 120;
            fixed_y = 120;

            set_background_color ({ 0xff, 0xff, 0xff, 0xff });
        }
    }
}