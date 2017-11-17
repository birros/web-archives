public class WebArchives.ZoomBox : Gtk.Box {
    private Context context;
    private Gtk.Button zoom_out_button;
    private Gtk.Button zoom_label_button;
    private Gtk.Button zoom_in_button;
    private ulong zoom_level_callback;
    private ulong can_zoom_out_callback;
    private ulong can_zoom_in_callback;
    private ulong can_zoom_reset_callback;

    public ZoomBox () {
        set_orientation (Gtk.Orientation.HORIZONTAL);
        get_style_context().add_class ("linked");

        zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic");
        zoom_out_button.clicked.connect (on_zoom_out);
        add (zoom_out_button);

        zoom_label_button = new Gtk.Button.with_label ("100%");
        zoom_label_button.clicked.connect (on_zoom_reset);
        add (zoom_label_button);

        zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic");
        zoom_in_button.clicked.connect (on_zoom_in);
        add (zoom_in_button);
    }

    private void on_can_zoom_out () {
        zoom_out_button.set_sensitive (context.web_view_state.can_zoom_out);
    }

    private void on_can_zoom_in () {
        zoom_in_button.set_sensitive (context.web_view_state.can_zoom_in);
    }

    private void on_can_zoom_reset () {
        zoom_label_button.set_sensitive (context.web_view_state.can_zoom_reset);
    }

    private void on_zoom_reset () {
        context.web_view_state.zoom_reset ();
    }

    private void on_zoom_out () {
        context.web_view_state.zoom_out ();
    }

    private void on_zoom_in () {
        context.web_view_state.zoom_in ();
    }

    private void on_zoom_level () {
        double level = context.web_view_state.zoom_level * 100;
        zoom_label_button.label = @"$level%";
    }

    public void set_context (Context context) {
        if (this.context != null) {
            this.context.web_view_state.disconnect (zoom_level_callback);
            this.context.web_view_state.disconnect (can_zoom_out_callback);
            this.context.web_view_state.disconnect (can_zoom_in_callback);
            this.context.web_view_state.disconnect (can_zoom_reset_callback);
        }

        this.context = context;

        zoom_level_callback =
            context.web_view_state.notify["zoom-level"].connect (on_zoom_level);
        can_zoom_out_callback =
            context.web_view_state.notify["can-zoom-out"].connect (
                on_can_zoom_out
            );
        can_zoom_in_callback =
            context.web_view_state.notify["can-zoom-in"].connect (
                on_can_zoom_in
            );
        can_zoom_reset_callback =
            context.web_view_state.notify["can-zoom-reset"].connect (
                on_can_zoom_reset
            );

        on_zoom_level ();
        on_can_zoom_out ();
        on_can_zoom_in ();
        on_can_zoom_reset ();
    }
}
