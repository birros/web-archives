public class WebArchives.Application : Gtk.Application {
    private struct Size {
        int width;
        int height;
    }

    private Context context;
    private Persistence persistence;
    private GLib.Settings settings;
    private HashTable<Gtk.Window, Size?> sizes;
    private const OptionEntry [] option_entries = {
        {
            "version", 'v', 0,
            OptionArg.NONE, null,
            N_("Print version number"), null
        },
        { null }
    };
    private const GLib.ActionEntry [] action_entries = {
        { "quit", on_quit }
    };

    public Application () {
        GLib.Object (
            application_id: "com.github.birros.WebArchives",
            flags: ApplicationFlags.HANDLES_OPEN
        );

        sizes = new HashTable<Gtk.Window, Size?> (direct_hash, direct_equal);
        add_main_option_entries (option_entries);
    }

    protected override void open (File[] files, string hint) {
        foreach (File file in files) {
            Context window_context = new Context.fork (
                context, Context.Layer.APP
            );

            Window window = new Window (this, window_context, null, null, file);
            /**
             * FIXME: better support of window size, maximize saving and
             * restoring.
             */
            window.maximize ();
        }
    }

    protected override int handle_local_options (VariantDict options) {
        if (options.contains ("version")) {
            stdout.printf (
                "%s %s\n", "web-archives", WebArchives.Config.VERSION
            );
            return 0;
        }
        return -1;
    }

    protected override void startup () {
        base.startup ();

        settings = new Settings ("com.github.birros.WebArchives");
        settings.changed["night-mode"].connect (on_gsettings_night_mode);

        add_action_entries (action_entries, this);
        set_accels_for_action ("app.quit", {"<Primary>q"});

        context = new Context ();
        persistence = new Persistence (context);

        context.tracker.refresh ();
        context.night_mode_state.notify["active"].connect (on_night_mode);
        context.night_mode_state.active = settings.get_boolean ("night-mode");
        info ("server_url: %s\n", context.server.url);

        window_added.connect (on_window_added);
        window_removed.connect (on_window_removed);

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

        add_window (window);
    }

    private void on_night_mode () {
        settings.set_boolean ("night-mode", context.night_mode_state.active);
    }

    private void on_gsettings_night_mode () {
        bool night_mode = settings.get_boolean ("night-mode");
        Gtk.Settings gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.set_property (
            "gtk-application-prefer-dark-theme", night_mode
        );
    }

    private void on_window_added (Gtk.Window window) {
        int width, height;
        settings.get ("window-size", "(ii)", out width, out height);
        bool maximized = settings.get_boolean ("window-maximized");

        window.resize (width, height);
        if (maximized) {
            window.maximize ();
        }

        window.configure_event.connect ((event) => {
            return on_configure_event (event, window);
        });
    }

    private bool on_configure_event (
        Gdk.EventConfigure event, Gtk.Window window
    ) {
        int width, height;
        window.get_size (out width, out height);

        Size size = {
            width: width,
            height: height
        };
        sizes.insert (window, size);

        return false;
    }

    private void on_window_removed (Gtk.Window window) {
        Size? size = sizes.get (window);
        sizes.remove (window);
        bool maximized = window.is_maximized;

        if (!maximized && size != null) {
            settings.set ("window-size", "(ii)", size.width, size.height);
        }
        settings.set_boolean ("window-maximized", maximized);
    }

    private void on_quit () {
        base.quit ();
    }
}
