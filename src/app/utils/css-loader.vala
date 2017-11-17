public class WebArchives.CssLoader : Object {
    public static Gtk.CssProvider load_css (string css_file) {
        Gtk.CssProvider provider = new Gtk.CssProvider ();
        try {
            File file = File.new_for_uri (
                "resource:///com/github/birros/WebArchives/" + css_file
            );
            provider.load_from_file (file);
        } catch (Error e) {
            warning (e.message);
        }
        return provider;
    }
}
