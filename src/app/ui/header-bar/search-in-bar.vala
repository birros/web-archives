public class WebArchives.SearchInBar : Gtk.Box {
    private Context context;
    private Gtk.SearchEntry search_entry;
    private ulong focus_callback;
    private ulong text_callback;

    public SearchInBar () {
        search_entry = new Gtk.SearchEntry ();
        Gtk.Button up_button = new Gtk.Button.from_icon_name ("go-up-symbolic");
        up_button.tooltip_text =
            _("Find previous occurrence of the search string");
        Gtk.Button down_button = new Gtk.Button.from_icon_name (
            "go-down-symbolic"
        );
        down_button.tooltip_text =
            _("Find next occurrence of the search string");

        search_entry.search_changed.connect (on_search_changed);
        search_entry.set_max_width_chars (49);

        up_button.clicked.connect (on_up);
        down_button.clicked.connect (on_down);

        append (search_entry);
        append (up_button);
        append (down_button);

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

    private void on_focus () {
        // search_entry.grab_focus_without_selecting ();
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
