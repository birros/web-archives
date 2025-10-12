public class WebArchives.NotebookTabLabel : Gtk.Box {
    private Gtk.Label label;
    public signal void close ();

    public NotebookTabLabel (string? text = null) {
        set_size_request(140, 0);

        label = new Gtk.Label (text);
        label.set_ellipsize (Pango.EllipsizeMode.END);

        Gtk.Image img = new Gtk.Image.from_icon_name("window-close-symbolic");

        Gtk.Button button = new Gtk.Button();
        button.set_child (img);
        button.clicked.connect (on_close);

        append (button);
    }

    private void on_close () {
        close ();
    }


    public void set_text (string text) {
        label.set_text (text);
    }
}
