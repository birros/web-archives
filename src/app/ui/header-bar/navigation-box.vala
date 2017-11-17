public class WebArchives.NavigationBox : Gtk.Box {
    private Context context;
    private Gtk.Button home_button;
    private Gtk.Button previous_button;
    private Gtk.Button next_button;

    private ulong can_go_back_callback;
    private ulong can_go_forward_callback;

    public NavigationBox () {
        spacing = 6;

        home_button = new Gtk.Button.from_icon_name ("go-home-symbolic");
        previous_button = new Gtk.Button.from_icon_name (
            "go-previous-symbolic"
        );
        next_button = new Gtk.Button.from_icon_name ("go-next-symbolic");
        Gtk.Box box = new Gtk.Box (orientation = Gtk.Orientation.HORIZONTAL, 0);

        box.get_style_context().add_class ("linked");

        add (home_button);
        add (box);
        box.add (previous_button);
        box.add (next_button);

        home_button.clicked.connect (on_home);
        previous_button.clicked.connect (on_previous);
        next_button.clicked.connect (on_next);
    }

    public void set_context (Context context) {
        if (this.context != null) {
            bool back_connected = SignalHandler.is_connected (
                context.navigation_state, can_go_back_callback
            );
            bool forward_connected = SignalHandler.is_connected (
                context.navigation_state, can_go_forward_callback
            );
            if (back_connected) {
                context.navigation_state.disconnect (can_go_back_callback);
            }
            if (forward_connected) {
                context.navigation_state.disconnect (can_go_forward_callback);
            }
        }

        this.context = context;

        can_go_back_callback =
            context.navigation_state.notify["can-go-back"].connect (
                on_can_go_back
            );
        can_go_forward_callback =
            context.navigation_state.notify["can-go-forward"].connect (
                on_can_go_forward
            );

        on_can_go_back ();
        on_can_go_forward ();
    }

    private void on_can_go_back () {
        previous_button.set_sensitive (context.navigation_state.can_go_back);
        home_button.set_sensitive (context.navigation_state.can_go_back);
    }

    private void on_can_go_forward () {
        next_button.set_sensitive (context.navigation_state.can_go_forward);
    }

    private void on_home () {
        context.navigation_state.go_home ();
    }

    private void on_previous () {
        context.navigation_state.go_back ();
    }

    private void on_next () {
        context.navigation_state.go_forward ();
    }
}
