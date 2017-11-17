public class WebArchives.Application : Gtk.Application {
    private Context context;
    private Persistence persistence;

    public Application () {
        GLib.Object (
            application_id: "com.github.birros.WebArchives",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void startup () {
        base.startup ();

        context = new Context ();
        persistence = new Persistence (context);

        context.tracker.refresh ();
        context.night_mode_state.notify["active"].connect (on_night_mode);
        info ("server_url: %s\n", context.server.url);

        // styles
        string[] styles = {
            "ui/gtk/notebook/notebook.css",
            "ui/content/history-view.css",
            "ui/content/shadow.css"
        };
        Gdk.Screen screen = Gdk.Screen.get_default ();
        foreach (string style in styles) {
            Gtk.CssProvider provider = CssLoader.load_css (style);
            Gtk.StyleContext.add_provider_for_screen (screen, provider, 400);
        }
    }

    protected override void shutdown () {
        base.shutdown ();
    }

    protected override void activate () {
        Context window_context = new Context.fork (context, Context.Layer.APP);
        Window window = new Window (this, window_context);
        /**
         * FIXME: better support of window size, maximize saving and restoring.
         */
        window.maximize ();
    }

    private void on_night_mode () {
        Gtk.Settings settings = Gtk.Settings.get_default ();
        settings.set_property (
            "gtk-application-prefer-dark-theme",
            context.night_mode_state.active
        );
    }
}
