public class WebArchives.SearchView : Gtk.Box {
    private Context context;
    private ArticleSearcher article_searcher;
    private Gtk.Stack stack;
    private Gtk.ListBox list_box_result;
    private Gtk.ListBox list_box_recent;

    public SearchView (Context context) {
        this.context = context;
        homogeneous = true;

        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (
            null, null
        );
        add (scrolled_window);

        MaxWidthBin max_width_bin = new MaxWidthBin (500);
        scrolled_window.add (max_width_bin);

        stack = new Gtk.Stack ();
        stack.get_style_context ().add_class ("shadow");
        max_width_bin.add (stack);

        list_box_recent = new Gtk.ListBox ();
        list_box_recent.set_selection_mode (Gtk.SelectionMode.NONE);
        list_box_recent.row_activated.connect (on_recent_row_activated);
        list_box_recent.set_header_func (update_header);
        list_box_recent.key_press_event.connect (on_key_press_event);
        stack.add (list_box_recent);

        Gtk.Label recent_placeholder = new Gtk.Label (_("No recent searches."));
        recent_placeholder.margin = 12;
        recent_placeholder.wrap = true;
        recent_placeholder.justify = Gtk.Justification.CENTER;
        recent_placeholder.show_all ();
        list_box_recent.set_placeholder (recent_placeholder);

        list_box_result = new Gtk.ListBox ();
        list_box_result.set_selection_mode (Gtk.SelectionMode.NONE);
        list_box_result.row_activated.connect (on_result_row_activated);
        list_box_result.set_header_func (update_header);
        list_box_result.key_press_event.connect (on_key_press_event);
        stack.add (list_box_result);

        Gtk.Label result_placeholder = new Gtk.Label (_("No results."));
        result_placeholder.margin = 12;
        result_placeholder.wrap = true;
        result_placeholder.justify = Gtk.Justification.CENTER;
        result_placeholder.show_all ();
        list_box_result.set_placeholder (result_placeholder);

        show_all ();

        context.archive_state.notify["archive"].connect (on_archive);
        context.search_state.notify["text"].connect (on_text);
        context.search_state.key_down.connect (on_key_down);
    }

    private bool on_key_press_event (Gdk.EventKey event) {
        Gtk.ListBoxRow row;
        if (stack.get_visible_child () == list_box_result) {
            row = list_box_result.get_row_at_index (0);
        } else {
            row = list_box_recent.get_row_at_index (0);
        }

        if (row != null && row.is_focus && event.keyval == Gdk.Key.Up) {
            context.search_state.key_up ();
        }
        return base.key_press_event (event);
    }

    private void on_key_down () {
        Gtk.ListBoxRow row;
        if (stack.get_visible_child () == list_box_result) {
            row = list_box_result.get_row_at_index (0);
        } else {
            row = list_box_recent.get_row_at_index (0);
        }
        if (row != null) {
            row.grab_focus ();
        }
    }

    private void on_text ()
    {
        if (context.search_state.text == "") {
            stack.set_visible_child (list_box_recent);
        } else {
            stack.set_visible_child (list_box_result);
            SearchResultModel model = article_searcher.search_text (
                context.search_state.text
            );
            list_box_result.bind_model (model, list_box_result_create_row);
        }
    }

    private void on_archive () {
        if (
            context.archive_state.archive != null &&
            context.archive_state.archive.path != ""
        ) {
            article_searcher = new ArticleSearcher (
                context.archive_state.archive
            );
            SearchRecentModel search_recent_model = new SearchRecentModel (
                context.search_recent_store,
                context.archive_state.archive.name
            );
            list_box_recent.bind_model (
                search_recent_model, list_box_recent_create_row
            );
        }
    }

    private void update_header (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        if (before == null) {
            return;
        }

        Gtk.Separator separator =
            new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        row.set_header (separator);
    }

    private void on_result_row_activated (Gtk.ListBoxRow row) {
        SearchResultRow search_row = (SearchResultRow) row;
        SearchResultItem item = search_row.item;

        SearchRecentItem recent_item =
            context.search_recent_store.get_by_name_and_text (
                context.archive_state.archive.name,
                context.search_state.text
            );
        if (recent_item == null) {
            recent_item = new SearchRecentItem (
                context.search_state.text,
                context.archive_state.archive.name
            );
            recent_item.update_timestamp ();
            context.search_recent_store.add (recent_item);
        } else {
            recent_item.update_timestamp ();
        }

        context.web_view_state.load_uri (item.url);
    }

    private void on_recent_row_activated (Gtk.ListBoxRow row) {
        SearchRecentRow search_row = (SearchRecentRow) row;
        SearchRecentItem item = search_row.item;
        item.update_timestamp ();
        context.search_state.text = item.text;
    }

    private Gtk.Widget list_box_result_create_row (GLib.Object item) {
        SearchResultItem search_item = (SearchResultItem) item;
        SearchResultRow row = new SearchResultRow (search_item);
        row.show_all ();
        return row;
    }

    private void on_remove (SearchRecentItem item) {
        context.search_recent_store.remove (item);
    }

    private Gtk.Widget list_box_recent_create_row (GLib.Object item) {
        SearchRecentItem recent_item = (SearchRecentItem) item;
        SearchRecentRow row = new SearchRecentRow (recent_item);
        row.remove_clicked.connect (() => {
            on_remove (recent_item);
        });
        row.show_all ();
        return row;
    }
}
