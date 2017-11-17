/**
 *  Caching isocodes to reduce the amount of disk access.
 */
public class WebArchives.LanguageFormater : Object {
    private static HashTable<string, string> data_names = null;
    private static HashTable<string, string> data_links = null;

    private static void init_data () {
        if (data_names != null) {
            return;
        }

        string locale = Intl.get_language_names ()[0];

        data_names = new HashTable<string, string> (str_hash, str_equal);
        data_links = new HashTable<string, string> (str_hash, str_equal);

        libisocodes.ISO_639_3 iso_639_3 = new libisocodes.ISO_639_3 ();
        iso_639_3.set_locale (locale);

        try {
            libisocodes.ISO_639_3_Item[] foo = iso_639_3.find_all ();
            for (uint i = 0; i < foo.length; i++) {
                if (foo[i].id.length > 0) {
                    data_names.insert (foo[i].id, foo[i].name);
                }
                if (foo[i].part1_code.length > 0) {
                    data_names.insert (foo[i].part1_code, foo[i].name);
                    data_links.insert (foo[i].part1_code, foo[i].id);
                }
            }
        } catch (libisocodes.ISOCodesError e) {
            info (e.message);
        }
    }

    public static string format_language (string input) {
        init_data ();

        string? output = data_names.lookup (input);
        if (output != null) {
            return output;
        } else {
            if (input == "") {
                return _("Unspecified language");
            }
            return input;
        }
    }

    public static string? iso_639_1_to_iso_639_3 (string input) {
        init_data ();

        string? output = data_links.lookup (input);
        if (output != null) {
            return output;
        } else {
            return null;
        }
    }
}
