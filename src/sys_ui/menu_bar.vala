using Clutter;

namespace Panos {
    public class Launcher : Actor {
        private Actor tile_container;

        public Launcher () {
            set_name ("launcher");
            set_background_color ({ 0xff, 0xff, 0xff, 0xff });
            init_tile ();
        }

        private void init_tile () {
            this.tile_container = new Actor ();
            this.tile_container.set_name ("tile");

            this.tile_container.set_background_color ({ 0x00, 0x00, 0x00, 0xff });

            add_child (this.tile_container);
        }

        public override void allocate (Clutter.ActorBox allocation) {
            critical ("called");
            set_allocation (allocation);

            var x = this.width * 0.5f;
            var y = this.height * 0.5f;
            var w = this.width * 0.8f;
            var h = this.height * 0.8f;

            var box = ActorBox ();
            box.set_size (w, h);
            box.set_origin (
                            x - w / 2,
                            y - h / 2
            );

            this.tile_container.allocate (box);
        }
    }
}