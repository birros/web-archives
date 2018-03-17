public class WebArchives.SearchRecentRow : Gtk.ListBoxRow {
    public SearchRecentItem item {get; private set;}
    public signal void remove_clicked ();

    public SearchRecentRow (SearchRecentItem item) {
        this.item = item;

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        add (box);

        Gtk.Label label = new Gtk.Label (item.text);
        label.ellipsize = Pango.EllipsizeMode.MIDDLE;
        label.margin = 6;
        label.hexpand = true;
        label.halign = Gtk.Align.START;
        box.add (label);

        Gtk.Button button = new Gtk.Button.from_icon_name (
            "edit-delete-symbolic"
        );
        button.margin_end = 6;
        button.get_style_context().add_class ("image-button");
        button.get_style_context().add_class ("sidebar-button");
        button.clicked.connect (() => {remove_clicked ();});
        box.add (button);
    }
}
