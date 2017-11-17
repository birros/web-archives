public class WebArchives.Notebook : Gtk.Notebook {
    private HashTable<Gtk.Widget, ulong> close_callbacks;
    private HashTable<Gtk.Widget, ulong> popup_callbacks;
    private HashTable<Gtk.Widget, Gtk.Widget> labels;

    public Notebook () {
        close_callbacks = new HashTable<Gtk.Widget, ulong> (null, null);
        popup_callbacks = new HashTable<Gtk.Widget, ulong> (null, null);
        labels = new HashTable<Gtk.Widget, Gtk.Widget> (null, null);

        set_scrollable (true);
        set_show_tabs (false);
        set_show_border (false);
        set_group_name ("web-archives-notebook");

        page_added.connect (on_page_added);
        popup_menu.connect (on_popup_menu);
        page_removed.connect (on_page_removed);

        show_all ();
    }

    private bool on_popup_menu () {
        info ("notebook-popup-menu");

        int current = get_current_page ();
        Gtk.Widget page = get_nth_page (current);
        Gtk.Widget label = get_tab_label (page);

        show_popup_menu (label, page);
        return true;
    }

    private void show_popup_menu (Gtk.Widget label, Gtk.Widget page) {
        NotebookPopupMenu tab_popup_menu = new NotebookPopupMenu (label);
        tab_popup_menu.create_window.connect (() => {
            info ("create-window");
            create_window (page, 0, 0);
        });
    }

    private void on_page_added (Gtk.Widget page) {
        info ("page-added");

        if (get_n_pages () > 1) {
            set_show_tabs (true);
        }

        child_set_property (page, "tab-expand", true);
        set_tab_reorderable (page, true);
        set_tab_detachable (page, true);

        NotebookTabLabel label = (NotebookTabLabel) get_tab_label (page);
        ulong close_callback = label.close.connect(() => {
            info ("close");
            int page_num = page_num (page);
            remove_page (page_num);
        });
        ulong popup_callback = label.popup_menu.connect(() => {
            info ("label-popup-menu");
            show_popup_menu (label, page);
            return true;
        });

        close_callbacks.insert (label, close_callback);
        popup_callbacks.insert (label, popup_callback);
        labels.insert (page, label);
    }

    private void on_page_removed (Gtk.Widget page, uint page_num) {
        info ("page-removed");

        if (get_n_pages () == 1) {
            set_show_tabs (false);
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
