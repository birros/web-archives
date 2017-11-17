public class WebArchives.NotificationBar : Gtk.Frame {
    public signal void close ();

    public NotificationBar (string text) {
        get_style_context().add_class ("app-notification");

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        Gtk.Label label = new Gtk.Label (text);
        Gtk.Button button = new Gtk.Button.from_icon_name (
            "window-close-symbolic"
        );

        label.halign = Gtk.Align.START;
        label.ellipsize = Pango.EllipsizeMode.END;
        button.relief = Gtk.ReliefStyle.NONE;
        button.clicked.connect (() => {close ();});

        add (box);
        box.pack_start (label, true);
        box.add (button);
    }
}
