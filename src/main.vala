public class WindowManagerPanos : Meta.Plugin {
    public Clutter.Stage stage { get; protected set; }

    Clutter.Actor window_actor;
    SwitchLauncherApp app;

    public override void start () {
        unowned Meta.Display display = get_display ();

        stage = display.get_compositor ().get_stage () as Clutter.Stage;

        var system_background = new Meta.Background (display);
        system_background.set_color ({ 0x2e, 0x34, 0x36, 0xff });

        var background_actor = new Meta.BackgroundActor (display, 0);
        ((Meta.BackgroundContent) background_actor.content).background = system_background;

        background_actor.add_constraint (new Clutter.BindConstraint (stage,
                                                                     Clutter.BindCoordinate.ALL, 0));
        stage.insert_child_below (background_actor, null);

        var group = display.get_compositor ().get_window_group ();
        group.add_constraint (new Clutter.BindConstraint (stage,
                                                          Clutter.BindCoordinate.ALL, 0));

        app = new SwitchLauncherApp (stage);
        stage.show ();

        display.window_created.connect ((display, window) => {
            window_actor = (Meta.WindowActor) window.get_compositor_private ();
            window.maximize (Meta.MaximizeFlags.BOTH);
            // window_actor.add_effect (effect);
        });
    }
}

int main (string[] args) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

    stdout.printf ("string format");

    Meta.Context ctx = new Meta.Context ("panos");

    try {
        ctx.configure (ref args);
    } catch (Error e) {
        stderr.printf ("Error initializing: %s\n", e.message);
        return -1;
    }

    ctx.set_plugin_gtype (typeof (WindowManagerPanos));

    try {
        ctx.setup ();
    } catch (Error e) {
        stderr.printf ("Failed to setup: %s\n", e.message);
        return -1;
    }


    try {
        ctx.start ();
        if (ctx.get_compositor_type () == Meta.CompositorType.WAYLAND) {
        }
    } catch (Error e) {
        stderr.printf ("Failed to start: %s\n", e.message);
        return -1;
    }

    try {
        ctx.run_main_loop ();
    } catch (Error e) {
        stderr.printf ("Gala terminated with a failure: %s\n", e.message);
        return -1;
    }

    return 0;
}