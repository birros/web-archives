public class WebArchives.SearchResultRow : Gtk.ListBoxRow {
    public SearchResultItem item {get; private set;}

    public SearchResultRow (SearchResultItem item) {
        this.item = item;

        Gtk.Label label = new Gtk.Label (item.text);
        label.ellipsize = Pango.EllipsizeMode.MIDDLE;
        label.margin = 6;
        label.hexpand = true;
        label.halign = Gtk.Align.START;
        add (label);
    }
}
