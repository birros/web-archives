public class WebArchives.TagParser : Object {
    private const string[] keys = {
        "nopic",
        "_pictures:no",
        "novid",
        "_videos:no",
        "_ftindex",
    };

    private static bool includes(Array<string> arr, string val) {
        for (int i = 0; i < arr.length ; i++) {
            string item = arr.index(i);
            if (item == val) {
                return true;
            }
        }
        return false;
    }

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
                    if (!includes(output, tag_formated)) {
                        output.append_val (tag_formated);
                    }
                }
            }
        }

        return output;
    }
}
