namespace Panos {
    public class PauseMenu {
        private Clutter.Actor actor;
        private Clutter.TransitionGroup transition;

        public PauseMenu(Clutter.Actor actor) {
            this.actor = actor;
            this.actor.set_pivot_point(1.0f, 0.5f);

            this.transition = new Clutter.TransitionGroup();
            transition.progress_mode = Clutter.AnimationMode.EASE_IN_CUBIC;
            transition.duration = 150;

            var scale_x = new Clutter.PropertyTransition("scale-x");
            scale_x.set_from_value(1.0f);
            scale_x.set_to_value(0.65f);

            var scale_y = new Clutter.PropertyTransition("scale-y");
            scale_y.set_from_value(1.0f);
            scale_y.set_to_value(0.65f);


            var translation_x = new Clutter.PropertyTransition("translation-x");
            translation_x.set_from_value(0.0f);
            translation_x.set_to_value(-65f);

            transition.add_transition(scale_x);
            transition.add_transition(scale_y);
            transition.add_transition(translation_x);
            transition.set_auto_reverse(true);
            transition.stop();

            this.actor.add_transition("pause-menu", transition);
        }

        public void toggle() {
            transition.start();
        }
    }
}