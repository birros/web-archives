public class WebArchives.TagParser : Object {
    private const string[] keys = {
        "nopic",
        "novid",
        "ftindex"
    };

    public static Array<string> parse_tags (string input) {
        string[] tags = input.split (";");
        Array<string> output = new Array<string> ();

        foreach (string tag in tags) {
            foreach (string key in keys) {
                /**
                 *  We use index_of because some tags are malformated.
                 */
                if (tag.index_of (key) != -1) {
                    string tag_formated = TagFormater.format_tag (key);
                    output.append_val (tag_formated);
                }
            }
        }

        return output;
    }
}
