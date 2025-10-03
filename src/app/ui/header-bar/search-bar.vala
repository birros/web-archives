public class WebArchives.SearchBar : Gtk.SearchEntry {
    private Context context;
    private ulong key_up_callback;
    private ulong text_callback;

    public SearchBar () {
        set_max_width_chars (57);
        search_changed.connect (on_search_changed);
    }

    private void on_search_changed () {
        context.search_state.text = get_text ();
    }

    public void set_context (Context context) {
        if (this.context != null) {
            this.context.search_state.disconnect (key_up_callback);
            this.context.search_state.disconnect (text_callback);
        }

        this.context = context;

        key_up_callback = context.search_state.key_up.connect (() => {
            // grab_focus_without_selecting ();
        });
        text_callback = context.search_state.notify["text"].connect (() => {
            set_text (context.search_state.text);
        });
        set_text (context.search_state.text);
    }
}
