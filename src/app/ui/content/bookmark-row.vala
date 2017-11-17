public class WebArchives.BookmarkRow : Gtk.ListBoxRow {
    public BookmarkItem item {get; private set;}
    public signal void remove_clicked (BookmarkItem item);

    public BookmarkRow (BookmarkItem item) {
        this.item = item;

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.margin_left = 6;
        box.margin_right = 6;
        add (box);

        Gtk.Label label = new Gtk.Label (item.title);
        label.ellipsize = Pango.EllipsizeMode.END;
        label.hexpand = true;
        label.halign = Gtk.Align.START;
        box.add (label);

        Gtk.Button button = new Gtk.Button.from_icon_name (
            "edit-delete-symbolic"
        );
        button.get_style_context().add_class ("image-button");
        button.get_style_context().add_class ("sidebar-button");
        button.clicked.connect (() => {remove_clicked (item);});
        box.add (button);
    }
}
