public class WebArchives.HistoryView : Gtk.Box {
    private Context context;
    private Gtk.ListBox list_box;

    public HistoryView (Context context) {
        this.context = context;
        homogeneous = true;

        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (
            null, null
        );
        add (scrolled_window);

        Hdy.Clamp max_width_bin = new Hdy.Clamp ();
        max_width_bin.set_maximum_size (500);
        scrolled_window.add (max_width_bin);

        list_box = new Gtk.ListBox ();
        list_box.margin_end = 6;
        list_box.margin_start = 6;
        list_box.margin_bottom = 6;
        list_box.get_style_context ().add_class ("history");
        list_box.selection_mode = Gtk.SelectionMode.NONE;
        list_box.row_activated.connect (on_row_activated);
        list_box.set_header_func (update_header);
        max_width_bin.add (list_box);

        Gtk.Label placeholder = new Gtk.Label (_("No browsing history."));
        placeholder.margin = 12;
        placeholder.wrap = true;
        placeholder.justify = Gtk.Justification.CENTER;
        placeholder.show_all ();
        list_box.set_placeholder (placeholder);

        show_all ();

        context.archive_state.notify["archive"].connect (on_archive);
    }

    private void on_archive () {
        if (context.archive_state.archive != null) {
            HistoryModel model = new HistoryModel (
                context.history_store,
                context.archive_state.archive.name
            );
            list_box.bind_model (model, list_box_create_row);
        }
    }

    private void update_header (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        HistoryRow history_row = (HistoryRow) row;
        HistoryItem item = history_row.item;
        DateTime date_time = new DateTime.from_unix_local (item.timestamp);

        // determine if display header is needed
        bool display_header = false;
        if (before == null) {
            display_header = true;
        } else {
            HistoryRow before_history = (HistoryRow) before;
            HistoryItem before_item = before_history.item;
            DateTime before_date_time = new DateTime.from_unix_local (
                before_item.timestamp
            );

            // check if days are different
            if (
                date_time.get_year () != before_date_time.get_year () ||
                date_time.get_day_of_year () !=
                    before_date_time.get_day_of_year ()
            ) {
                display_header = true;
            }
        }

        if (display_header) {
            string header = date_time.format (_("%e %b %y"));

            Gtk.Label label = new Gtk.Label (header);
            label.margin_top = 9;
            label.margin_bottom = 9;
            label.xalign = 0;

            Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.add (label);
            box.show_all ();

            row.set_header (box);
            if (before == null) {
                box.get_style_context ().add_class ("first");
            }
        } else {
            Gtk.Separator separator =
                new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            row.set_header (separator);
        }
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        HistoryRow history_row = (HistoryRow) row;
        HistoryItem item = history_row.item;
        context.web_view_state.load_uri (item.url);
    }

    private void on_remove (HistoryItem item) {
        context.history_store.remove (item);
    }

    private Gtk.Widget list_box_create_row (Object item) {
        HistoryItem history_item = (HistoryItem) item;
        HistoryRow row = new HistoryRow (history_item);
        row.remove_clicked.connect (() => {
            on_remove (history_item);
        });
        row.show_all ();
        return row;
    }
}
