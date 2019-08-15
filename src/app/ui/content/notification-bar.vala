public class WebArchives.NotificationBar : Gtk.Frame {
    public signal void close ();
    private Gtk.Label label_text; 

    public NotificationBar (string text) {
        get_style_context().add_class ("app-notification");

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        label_text = new Gtk.Label (text);
        Gtk.Button button = new Gtk.Button.from_icon_name (
            "window-close-symbolic"
        );

        label_text.halign = Gtk.Align.START;
        label_text.ellipsize = Pango.EllipsizeMode.END;
        button.relief = Gtk.ReliefStyle.NONE;
        button.clicked.connect (() => {close ();});

        add (box);
        box.pack_start (label_text, true);
        box.add (button);
    }

    public void set_text (string text) {
        label_text.set_label(text);
    }
}
