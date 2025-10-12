public class WebArchives.SearchBar : Adw.Bin {
    private Context context;
    private ulong key_up_callback;
    private ulong text_callback;

    private Gtk.SearchEntry entry;

    public SearchBar () {
        entry = new Gtk.SearchEntry () {
            max_width_chars = 57
        };

        entry.search_changed.connect (on_search_changed);

        // Put the entry inside our widget
        set_child (entry);
    }

    private void on_search_changed () {
        if (context != null) {
            context.search_state.text = entry.text;
        }
    }

    public void set_context (Context context) {
        if (this.context != null) {
            this.context.search_state.disconnect (key_up_callback);
            this.context.search_state.disconnect (text_callback);
        }

        this.context = context;

        key_up_callback = context.search_state.key_up.connect (() => {
            // entry.grab_focus_without_selecting ();
        });

        text_callback = context.search_state.notify["text"].connect (() => {
            entry.text = context.search_state.text;
        });

        entry.text = context.search_state.text;
    }

    public Gtk.SearchEntry get_entry () {
        return entry;
    }
}

