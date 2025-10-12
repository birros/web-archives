public class WebArchives.Notebook : Adw.Bin {
    private Gtk.Notebook notebook;
    private HashTable<Gtk.Widget, ulong> close_callbacks;
    private HashTable<Gtk.Widget, ulong> popup_callbacks;
    private HashTable<Gtk.Widget, Gtk.Widget> labels;

    public Notebook () {
        notebook = new Gtk.Notebook () {
            scrollable = true,
            show_tabs = false,
            show_border = false,
            group_name = "web-archives-notebook"
        };

        set_child (notebook);

        close_callbacks = new HashTable<Gtk.Widget, ulong> (null, null);
        popup_callbacks = new HashTable<Gtk.Widget, ulong> (null, null);
        labels = new HashTable<Gtk.Widget, Gtk.Widget> (null, null);

        notebook.page_added.connect (on_page_added);
        notebook.page_removed.connect (on_page_removed);
        // notebook.popup_menu.connect (on_popup_menu); // Popup menus in GTK4 are different
    }

    public Gtk.Notebook get_notebook () {
        return notebook;
    }

    private void on_page_added (Gtk.Widget page) {
        info ("page-added");

        if (notebook.get_n_pages () > 1) {
            notebook.show_tabs = true;
        }

        notebook.set_tab_reorderable (page, true);
        notebook.set_tab_detachable (page, true);

        NotebookTabLabel label = (NotebookTabLabel) notebook.get_tab_label (page);

        ulong close_callback = label.close.connect (() => {
            info ("close");
            int page_num = notebook.page_num (page);
            notebook.remove_page (page_num);
        });

        close_callbacks.insert (label, close_callback);
        labels.insert (page, label);
    }

    private void on_page_removed (Gtk.Widget page, uint page_num) {
        info ("page-removed");

        if (notebook.get_n_pages () == 1) {
            notebook.show_tabs = false;
        }

        Gtk.Widget label = labels.get (page);
        if (close_callbacks.contains (label)) {
            ulong close_callback = close_callbacks.get (label);
            if (GLib.SignalHandler.is_connected (label, close_callback)) {
                label.disconnect (close_callback);
            }
        }
        if (popup_callbacks.contains (label)) {
            ulong popup_callback = popup_callbacks.get (label);
            if (GLib.SignalHandler.is_connected (label, popup_callback)) {
                label.disconnect (popup_callback);
            }
        }

        close_callbacks.remove (label);
        popup_callbacks.remove (label);
        labels.remove (page);
    }
}

