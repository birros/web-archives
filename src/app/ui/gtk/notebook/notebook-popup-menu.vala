public class WebArchives.NotebookPopupMenu : Gtk.Popover {
    public signal void create_window ();

    public NotebookPopupMenu (Gtk.Widget widget) {
        Object (relative_to: widget);

        set_position (Gtk.PositionType.BOTTOM);

        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        box.margin = 10;

        Gtk.ModelButton button = new Gtk.ModelButton ();
        button.set_label (_("Detach to a new window"));
        box.pack_start (button, true, true, 0);
        add (box);

        show_all();

        button.clicked.connect (() => {
            create_window ();
        });
    }
}
