public class WebArchives.TagFormater : Object {
    private static HashTable<string, string> data = null;

    private static void init_data () {
        data = new HashTable<string, string> (str_hash, str_equal);
        data.insert ("nopic", _("No pictures"));
        data.insert ("_pictures:no", _("No pictures"));
        data.insert ("novid", _("No videos"));
        data.insert ("_videos:no", _("No videos"));
        data.insert ("_ftindex", _("Full text index"));
    }

    public static string format_tag (string input) {
        if (data == null) {
            init_data ();
        }

        string? output = data.lookup (input);
        if (output != null) {
            return output;
        } else {
            return input;
        }
    }
}
