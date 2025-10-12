public class WebArchives.NotebookPopupMenu : Gtk.Popover {
    public signal void create_window ();

    public NotebookPopupMenu () {
        Object ();

        set_position (Gtk.PositionType.BOTTOM);

        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        // box.margin = 10;

        Gtk.Button button = new Gtk.Button ();
        button.set_label (_("Detach to a new window"));
        box.append (button);
        set_child (box);


        button.clicked.connect (() => {
            create_window ();
        });
    }
}
