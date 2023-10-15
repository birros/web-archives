/**
 *  This class is a rough reimplementation of the Reader class of the kiwix
 *  library. This one depends only on the Zim library.
 *
 *  See the original source file for more details:
 *  https://github.com/kiwix/kiwix-lib/blob/e9ab074b5d73ecbaa37eb140fb753d34896e5d3a/src/reader.cpp
 */

public class Suggestion {
    public string title;
    public string path;
}

public class WebArchives.ZimReader {
    private Zim.Archive archive;
    private Zim.SuggestionSearcher suggestion_searcher;

    public ZimReader (Zim.Archive archive) {
        this.archive = archive;
        this.suggestion_searcher = new Zim.SuggestionSearcher (archive);
    }

    public string get_title () {
        return getMetatag ("Title");
    }

    public string get_date () {
        return getMetatag ("Date");
    }

    public string get_language () {
        return getMetatag ("Language");
    }

    public string get_tags () {
        return getMetatag ("Tags");
    }

    public string get_name () {
        return getMetatag ("Name");
    }

    public string get_description () {
        return getMetatag ("Description");
    }

    public string get_creator () {
        return getMetatag ("Creator");
    }

    public string get_publisher () {
        return getMetatag ("Publisher");
    }

    public ulong get_file_size () {
        ulong size = archive.get_filesize ();
        return size / 1024;
    }

    public string get_id () {
        string uuid = archive.get_uuid ();
        return uuid;
    }

    public string get_random_page_url () {
        try {
            Zim.Entry entry = archive.get_random_entry ();
            string url = entry.get_path ();
            return url;
        } catch (Error err) {
            warning(err.message);
            return "C/";
        }
    }

    public uint get_article_count () {
        uint count = archive.get_article_count();
        return count;
    }

    public uint get_media_count () {
        HashTable<string, uint> table = parseCounterMetadata ();

        uint count = 0;
        string [] types = {"image/jpeg", "image/gif", "image/png"};
        foreach (unowned string type in types) {
            count += table.get (type);
        }

        return count;
    }

    public uint get_global_count () {
        uint global_count = archive.get_all_entry_count ();
        return global_count;
    }

    public bool get_faveicon (out uint8[] data, out string mimetype) {
        try {
            Zim.Item item = archive.get_illustration_item (48);

            data = item.get_data();
            mimetype = item.get_mimetype();

            return true;
        } catch (Error err) {
            warning(err.message);

            data = {};
            mimetype = "";

            return false;
        }
    }

    public List<Suggestion> search_suggestions (string query, uint limit) {
        List<Suggestion> suggestions = new List<Suggestion> ();

        Zim.SuggestionSearch suggestion_search = suggestion_searcher.suggest (query);
        Zim.SuggestionResultIterator results_iterator = suggestion_search.get_results (0, (int) limit);

        do {
            try {
                Zim.Entry entry = results_iterator.get_entry ();

                Suggestion suggestion = new Suggestion ();
                suggestion.title = entry.get_title();
                suggestion.path = "/" + entry.get_path();
                suggestions.append (suggestion);
            } catch (Error err) {
                continue;
            }
        } while (results_iterator.next());

        // If the `SuggestionSearcher` doesn't work, perhaps iterate on the
        // article titles

        return suggestions;
    }

    private HashTable<string, uint> parseCounterMetadata () {
        HashTable<string, uint> table = new HashTable<string, uint> (
            str_hash, str_equal
        );

        string counter = getMetatag ("Counter");
        string[] lines = counter.split (";");
        foreach (unowned string line in lines) {
            string[] infos = line.split ("=");
            if (infos.length == 2) {
                string mimetype = infos[0];
                uint count = (uint) uint64.parse (infos[1]);
                table.insert (mimetype, count);
            }
        }
        return table;
    }

    private string getMetatag (string name) {
        try {
            string metadata = archive.get_metadata (name);
            return metadata;
        } catch (Error err) {
            warning(err.message);
            return "";
        }
    }
}
