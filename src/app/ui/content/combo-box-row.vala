public class WebArchives.ComboBoxRow : Gtk.ListBoxRow {
    public LanguageItem language_item {get; private set;}

    public ComboBoxRow (LanguageItem language_item) {
        this.language_item = language_item;

        string language = LanguageFormater.format_language (
            language_item.language
        );

        Gtk.Label label = new Gtk.Label (language);
        label.margin_top = 6;
        label.margin_end = 6;
        label.margin_bottom = 6;
        label.margin_start = 6;
        label.xalign = 0;
        label.ellipsize = Pango.EllipsizeMode.END;
        add (label);
    }
}
