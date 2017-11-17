public class WebArchives.TitleBar : Gtk.Box {
    private Context context;
    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;

    private ulong title_callback;
    private ulong subtitle_callback;

    public TitleBar () {
        Object (orientation: Gtk.Orientation.VERTICAL);

        title_label = new Gtk.Label ("Title");
        subtitle_label = new Gtk.Label ("Subtitle");

        title_label.get_style_context().add_class ("title");
        title_label.set_ellipsize (Pango.EllipsizeMode.END);

        subtitle_label.get_style_context().add_class ("subtitle");
        subtitle_label.set_ellipsize (Pango.EllipsizeMode.END);

        add (title_label);
    }

    public void set_context (Context context) {
        if (this.context != null) {
            bool title_connected = SignalHandler.is_connected (
                this.context.title_state, title_callback
            );
            bool subtitle_connected = SignalHandler.is_connected (
                this.context.title_state, subtitle_callback
            );
            if (title_connected) {
                this.context.title_state.disconnect (title_callback);
            }
            if (subtitle_connected) {
                this.context.title_state.disconnect (subtitle_callback);
            }
        }

        this.context = context;

        title_callback = context.title_state.notify["title"].connect (() => {
            title_label.set_text (context.title_state.title);
        });
        subtitle_callback =
            context.title_state.notify["subtitle"].connect (() => {
                toggle_subtitle ();
            });

        title_label.set_text (context.title_state.title);
        toggle_subtitle ();
    }

    private void toggle_subtitle () {
        if (context.title_state.subtitle == "") {
            remove (subtitle_label);
        } else {
            subtitle_label.set_text (context.title_state.subtitle);
            add (subtitle_label);
            show_all ();
        }
    }
}
