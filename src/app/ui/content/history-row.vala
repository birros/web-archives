public class WebArchives.HistoryRow : Gtk.ListBoxRow {
    public HistoryItem item {get; private set;}
    public signal void remove_clicked ();

    public HistoryRow (HistoryItem item) {
        this.item = item;

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.margin_end = 6;
        box.margin_start = 6;
        add (box);

        Gtk.Label label = new Gtk.Label (item.title);
        label.hexpand = true;
        label.ellipsize = Pango.EllipsizeMode.MIDDLE;
        label.halign = Gtk.Align.START;
        box.add (label);

        Gtk.Button button = new Gtk.Button.from_icon_name (
            "edit-delete-symbolic"
        );
        button.get_style_context().add_class ("image-button");
        button.get_style_context().add_class ("sidebar-button");
        button.clicked.connect (() => {remove_clicked ();});
        box.add (button);
    }
}
