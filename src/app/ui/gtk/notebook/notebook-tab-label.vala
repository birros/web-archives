public class WebArchives.NotebookTabLabel : Gtk.Box {
    private Gtk.Label label;
    public signal void close ();

    public NotebookTabLabel (string? text = null) {
        set_size_request(140, 0);

        label = new Gtk.Label (text);
        label.set_ellipsize (Pango.EllipsizeMode.END);

        Gtk.Image img = new Gtk.Image.from_icon_name(
            "window-close-symbolic", Gtk.IconSize.MENU
        );

        Gtk.Button button = new Gtk.Button();
        button.set_relief (Gtk.ReliefStyle.NONE);
        button.set_image (img);
        button.clicked.connect (on_close);

        Gtk.EventBox event_box = new Gtk.EventBox ();
        event_box.add (label);

        pack_start (event_box, true, true, 0);
        pack_start (button, false, false, 0);
        show_all ();

        button_release_event.connect (on_right_click);
    }

    private void on_close () {
        close ();
    }

    private bool on_right_click (Gdk.EventButton event) {
        if (event.button == 3) {
            popup_menu ();
        }
        return true;
    }

    public void set_text (string text) {
        label.set_text (text);
    }
}
