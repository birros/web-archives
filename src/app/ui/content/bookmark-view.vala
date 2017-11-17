public class WebArchives.BookmarkView : Gtk.Box {
    private Context context;
    private Gtk.ListBox list_box;

    public BookmarkView (Context context) {
        this.context = context;
        homogeneous = true;

        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (null, null);
        add (scrolled_window);

        MaxWidthBin max_width_bin = new MaxWidthBin (500);
        scrolled_window.add (max_width_bin);

        list_box = new Gtk.ListBox ();
        list_box.get_style_context ().add_class ("shadow");
        list_box.selection_mode = Gtk.SelectionMode.NONE;
        list_box.row_activated.connect (on_row_activated);
        list_box.set_header_func (update_header);
        max_width_bin.add (list_box);

        Gtk.Label placeholder = new Gtk.Label (_("No bookmarks saved."));
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
            BookmarkModel model = new BookmarkModel (
                context.bookmark_store,
                context.archive_state.archive.name
            );
            model.set_sort_func (sort_by_title);
            list_box.bind_model (model, list_box_create_row);
        }
    }

    private void update_header (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        if (before == null) {
            return;
        }

        Gtk.Separator separator;
        separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        row.set_header (separator);
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        BookmarkRow bookmark_row = (BookmarkRow) row;
        BookmarkItem item = bookmark_row.item;
        context.web_view_state.load_uri (item.url);
    }

    private void on_remove (BookmarkItem item) {
        context.bookmark_store.remove (item);
    }

    private Gtk.Widget list_box_create_row (Object item) {
        BookmarkItem bookmark_item = (BookmarkItem) item;
        BookmarkRow row = new BookmarkRow (bookmark_item);
        row.remove_clicked.connect (on_remove);
        row.show_all ();
        return row;
    }

    private int sort_by_title (BookmarkItem a, BookmarkItem b) {
        if (a.title.down () > b.title.down ()) {
            return 1;
        } else if (a.title.down () < b.title.down ()) {
            return -1;
        } else {
            return 0;
        }
    }
}
