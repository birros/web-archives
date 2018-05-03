/**
 *  This class is a rough reimplementation of the Reader class of the kiwix
 *  library. This one depends only on the Zim library.
 *
 *  See the original source file for more details:
 *  https://github.com/kiwix/kiwix-lib/blob/e9ab074b5d73ecbaa37eb140fb753d34896e5d3a/src/reader.cpp
 */

private class Suggestion {
    public string title;
    public string url;
}

public class WebArchives.ZimReader {
    private Zim.File zim_file;
    private List<Suggestion> suggestions;
    private uint suggestions_offset;

    public ZimReader (Zim.File zim_file) {
        this.zim_file = zim_file;

        suggestions = new List<Suggestion> ();
        suggestions_offset = 0;
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
        ulong size = zim_file.get_filesize ();
        return size / 1024;
    }

    public string get_id () {
        Zim.Fileheader fileheader = zim_file.get_fileheader ();
        string uuid = fileheader.get_uuid ();
        return uuid;
    }

    public string get_random_page_url () {
        uint articles_namespace_begin_offset =
            zim_file.get_namespace_begin_offset ('A');
        uint articles_namespace_count = zim_file.get_namespace_count ('A');

        int random_number = Random.int_range(0, (int) articles_namespace_count);
        uint idx = articles_namespace_begin_offset + random_number;

        Zim.Article article = zim_file.get_article_by_index (idx);
        string url = "A/" + article.get_url ();

        return url;
    }

    public uint get_article_count () {
        HashTable<string, uint> table = parseCounterMetadata ();

        uint count = table.get ("text/html");
        if (count == 0) {
            count = zim_file.get_namespace_count ('A');
        }

        return count;
    }

    public uint get_media_count () {
        HashTable<string, uint> table = parseCounterMetadata ();

        uint count = 0;
        string [] types = {"image/jpeg", "image/gif", "image/png"};
        foreach (unowned string type in types) {
            count += table.get (type);
        }

        if (count == 0) {
            count = zim_file.get_namespace_count ('I');
        }
        return count;
    }

    public uint get_global_count () {
        uint global_count = zim_file.get_count_articles ();
        return global_count;
    }

    public bool get_faveicon (out uint8[] data, out string mimetype) {
        uint8[] foo = {};
        data = foo;
        mimetype = "";

        string [] paths = {
            "-/favicon.png", "I/favicon.png", "I/favicon", "-/favicon"
        };
        foreach (unowned string path in paths) {
            string [] infos = path.split ("/");
            char namesp = infos[0][0];
            string url = infos[1];

            Zim.Article article = zim_file.get_article_by_namespace (
                namesp, url
            );
            if (article.good ()) {
                data = article.get_data ();
                mimetype = article.get_mime_type ();
                return true;
            }
        }

        return false;
    }

    public bool get_next_suggestion (
        out string suggestion_title,
        out string suggestion_url
    ) {
        if (this.suggestions_offset != this.suggestions.length()) {
            Suggestion suggestion = this.suggestions.nth_data (
              this.suggestions_offset
            );
            suggestion_title = suggestion.title;
            suggestion_url = suggestion.url;
            this.suggestions_offset++;
            return true;
        } else {
            suggestion_title = "";
            suggestion_url = "";
            return false;
        }
    }

    public void search_suggestions_smart (string query, uint limit) {
        this.suggestions = new List<Suggestion> ();
        this.suggestions_offset = 0;

        Zim.Search search = new Zim.Search (zim_file);
        search.set_query (query);
        search.set_range (0, limit);
        search.set_suggestion_mode (true);

        uint matches_estimated = search.get_matches_estimated ();

        if (matches_estimated > 0) {
            Zim.SearchIterator search_iterator = search.begin ();
            do {
                Suggestion suggestion = new Suggestion ();
                suggestion.title = search_iterator.get_title();
                suggestion.url = "/" + search_iterator.get_url();
                this.suggestions.append (suggestion);
            } while (search_iterator.next());
        } else {
            string[] variants = get_title_variants (query);
            foreach (string variant in variants) {
                search_suggestions (variant, limit);
            }
        }
    }

    private string[] get_title_variants (string title) {
        string[] variants = {};
        variants += title;
        variants += change_case (title, true, false); //first letter upper case
        variants += change_case (title, false, false); //first letter lower case
        variants += change_case (title, true, true); //title case
        return variants;
    }

    private string change_case (string title, bool upper, bool title_case) {
        bool next = true;

        StringBuilder result = new StringBuilder ();
        unichar c;

        for (int i = 0; title.get_next_char (ref i, out c);) {
            if (next) {
                if (upper || title_case) {
                    result.append_unichar (c.totitle ());
                } else {
                    result.append_unichar (c.tolower ());
                }
                next = false;
            } else {
                if (title_case) {
                    result.append_unichar (c.tolower ());
                    next = c.isspace () || c.iscntrl ();
                } else {
                    result.append_unichar (c);
                }
            }
        }

        return result.str;
    }

    private void search_suggestions (string query, uint limit) {
        if (this.suggestions.length () > limit) {
            return;
        }

        if (query.length == 0) {
            return;
        }

        Zim.FileIterator file_iterator = zim_file.find_by_title ('A', query);
        while (true) {
            Zim.Article article = file_iterator.get_article();

            Suggestion suggestion = new Suggestion ();
            suggestion.title = article.get_title();
            suggestion.url = "/A/" + article.get_url();

            if (suggestion.title.has_prefix (query)) {
                bool insert = true;
                this.suggestions.foreach ((item) => {
                    if (item.url == suggestion.url) {
                        insert = false;
                        return;
                    }
                });
                if (insert) {
                    this.suggestions.append (suggestion);
                }
            }

            if (!(
                  file_iterator.next() &&
                  this.suggestions.length () < limit &&
                  suggestion.title.has_prefix (query)
                )) {
                break;
            }
        }
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
        Zim.Article article = zim_file.get_article_by_namespace ('M', name);
        uint8[] data = article.get_data ();
        var builder = new StringBuilder ();
        builder.append_len ((string)data, data.length);
        return builder.str;
    }
}
