public class WebArchives.SearchInBar : Gtk.Box {
    private Context context;
    private Gtk.SearchEntry search_entry;
    private ulong focus_callback;
    private ulong text_callback;

    public SearchInBar () {
        search_entry = new Gtk.SearchEntry ();
        Gtk.Button up_button = new Gtk.Button.from_icon_name ("go-up-symbolic");
        Gtk.Button down_button = new Gtk.Button.from_icon_name (
            "go-down-symbolic"
        );

        search_entry.search_changed.connect (on_search_changed);
        search_entry.key_release_event.connect (on_key_release_event);
        search_entry.key_press_event.connect (on_key_press_event);
        search_entry.set_max_width_chars (49);

        up_button.clicked.connect (on_up);
        down_button.clicked.connect (on_down);

        add (search_entry);
        add (up_button);
        add (down_button);

        get_style_context().add_class ("linked");
    }

    private void on_up () {
        context.search_in_state.previous ();
    }

    private void on_down () {
        context.search_in_state.next ();
    }

    private void on_search_changed () {
        context.search_in_state.text = search_entry.get_text ();
    }

    private bool on_key_release_event (Gdk.EventKey event) {
        if (event.keyval == Gdk.Key.Escape) {
            context.route_state.route = RouteState.Route.WEB;
        }
        return false;
    }

    private bool on_key_press_event (Gdk.EventKey event) {
        switch (event.keyval) {
            case Gdk.Key.Return:
            case Gdk.Key.KP_Enter:
            {
                context.search_in_state.next ();
                return true;
            }
            case Gdk.Key.Down:
            {
                context.search_in_state.key (SearchInState.Key.DOWN);
                return true;
            }
            case Gdk.Key.Up:
            {
                context.search_in_state.key (SearchInState.Key.UP);
                return true;
            }
            case Gdk.Key.Page_Up:
            {
                context.search_in_state.key (SearchInState.Key.PAGE_UP);
                return true;
            }
            case Gdk.Key.Page_Down:
            {
                context.search_in_state.key (SearchInState.Key.PAGE_DOWN);
                return true;
            }
        }
        return false;
    }

    private void on_focus () {
        search_entry.grab_focus_without_selecting ();
    }

    private void on_text () {
        if (search_entry.get_text () != context.search_in_state.text) {
            search_entry.set_text (context.search_in_state.text);
        }
    }

    public void set_context (Context context) {
        if (this.context != null) {
                this.context.search_in_state.disconnect (focus_callback);
                this.context.search_in_state.disconnect (text_callback);
        }

        this.context = context;

        focus_callback = context.search_in_state.focus.connect (on_focus);
        text_callback = context.search_in_state.notify["text"].connect (
            on_text
        );
    }
}
