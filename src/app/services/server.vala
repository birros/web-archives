private class Article {
    public string path;
    public string title;
    public char? namespace;
    public string? uuid;
    public bool use_referer;
}

public class WebArchives.Server : Soup.Server {
    private const uint UUID_LENGTH = 36;
    private HashTable<string, Zim.Archive> archives;
    private HashTable<string, uint> counts;
    public string url { get; private set; }

    public Server () {
        archives = new HashTable<string, Zim.Archive> (str_hash, str_equal);
        counts = new HashTable<string, uint> (str_hash, str_equal);

        add_handler (null, default_handler);

        // Try to setup the server listener on ipv4 then ipv6, otherwise failing
        try {
            listen_local (0, Soup.ServerListenOptions.IPV4_ONLY);
            url = get_uris().data.to_string();
        } catch (Error e) {
            warning (e.message);

            try {
                listen_local (0, Soup.ServerListenOptions.IPV6_ONLY);
                url = get_uris().data.to_string();
            } catch(Error e2) {
                warning (e.message);

                error ("Unable to setup internal server");
            }
        }
    }

    public void add_archive (ArchiveItem archive) {
        if (!archives.contains (archive.uuid)) {
            try {
                Zim.Archive file = new Zim.Archive (archive.path);
                archives.insert (archive.uuid, file);
                add_count (archive);
                info ("add archive: %s", archive.uuid);
            } catch (Error e) {
                warning ("Error: %s\n", e.message);
            }
        } else {
            add_count (archive);
        }
    }

    public void remove_archive (ArchiveItem archive) {
        if (!archives.contains (archive.uuid)) {
            return;
        }

        uint count = remove_count (archive);
        if (count == 0) {
            archives.remove (archive.uuid);
            info ("remove archive: %s", archive.uuid);
        }
    }

    private uint add_count (ArchiveItem archive) {
        if (!counts.contains (archive.uuid)) {
            counts.insert (archive.uuid, 0);
        }
        uint count = counts.get (archive.uuid);
        count++;
        counts.replace (archive.uuid, count);
        return count;
    }

    private uint remove_count (ArchiveItem archive) {
        uint count = counts.get (archive.uuid);
        count--;
        counts.replace (archive.uuid, count);
        if (count == 0) {
            counts.remove (archive.uuid);
        }
        return count;
    }

    private static string? get_referer (Soup.ServerMessage msg) {
        Soup.MessageHeaders headers = msg.get_request_headers();
        string? referer = headers.get_one ("Referer");
        return referer;
    }

    private static bool is_uuid (string uuid) {
        GLib.Regex exp = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
        return exp.match (uuid);
    }

    private static Article parse_infos (
        string server_url, string path, string? referer
    ) {
        Article article = new Article ();

        // get uuid and path
        if (
            path.length >= UUID_LENGTH + 2 &&
            path[0] == '/'                 &&
            path[UUID_LENGTH + 1] == '/'
        ) {
            article.path = path.substring(UUID_LENGTH + 1);
            string uuid = path.substring(1, UUID_LENGTH);
            if (is_uuid (uuid)) {
                article.uuid = uuid;
            } else {
                article.uuid = null;
            }
            article.use_referer = false;
        } else if (
            referer != null                                       &&
            referer.length >= server_url.length + UUID_LENGTH + 1 &&
            referer[server_url.length - 1] == '/'                 &&
            referer[server_url.length + UUID_LENGTH] == '/'
        ) {
            article.path = path;
            string uuid = referer.substring (server_url.length, UUID_LENGTH);
            if (is_uuid (uuid)) {
                article.uuid = uuid;
                article.use_referer = true;
            } else {
                article.uuid = null;
                article.use_referer = false;
            }
        } else {
            article.path = path;
            article.uuid = null;
            article.use_referer = false;
        }

        // get namespace
        if (
            article.path.length >= 3 &&
            article.path[0] == '/'   &&
            article.path[2] == '/'
        ) {
            article.namespace = article.path[1];
        } else {
            article.namespace = null;
        }

        // get title
        if (article.namespace != null) {
            article.title = article.path.substring (3);
        } else {
            article.title = article.path.substring (1);
        }

        return article;
    }

    /**
     * FIXME: For now, url analysis and retrieval can cause bugs, since in the
     * future articles will no longer necessarily be in the `A` namespace.
     * See : https://github.com/openzim/libzim/issues/15
     */
    private void default_handler (
        Soup.Server        server,
        Soup.ServerMessage msg,
        string             path,
        GLib.HashTable?    query
    ) {
        string? referer = get_referer (msg);
        Article article = parse_infos (url, path, referer);

        // check if uuid is set
        if (article.uuid == null) {
            msg.set_status (Soup.Status.NOT_FOUND, null);
            return;
        }

        // redirects to the real article url, which includes uuid in it
        if (article.use_referer) {
            string article_url = "/" + article.uuid + article.path;
            msg.set_redirect (Soup.Status.MOVED_PERMANENTLY, article_url);
            return;
        }

        // check if a zim archive corresponding to the uuid is opened
        unowned Zim.Archive archive;
        if (archives.contains (article.uuid)) {
            archive = archives.get (article.uuid);
        } else {
            msg.set_status (Soup.Status.NOT_FOUND, null);
            return;
        }

        // get the real path if it's the the main page
        string r_path;
        if (
            (article.title == "" || article.title == null)          &&
            (article.namespace == 'C' || article.namespace == null)
        ) {
            Zim.Entry home = null;

            if (archive.has_main_entry ()) {
                try {
                    home = archive.get_main_entry ();
                } catch (Error err) {
                    warning(err.message + ": get_main_entry");
                }
            }

            if (home == null) {
                try {
                    home = archive.get_random_entry ();
                } catch (Error err) {
                    warning(err.message + ": get_random_entry");
                }
            }

            if (home != null) {
                r_path = home.get_path ();

                if (r_path == "mainPage") {
                    Zim.Item item = home.get_item(true);
                    r_path = item.get_path();
                }
            } else {
                r_path = "C/";
            }
        } else {
            r_path = article.title;
        }

        try {
            Zim.Entry page = archive.get_entry_by_path (r_path);

            // if the page is good send the data
            Zim.Item item = page.get_item(true);
            uint8[]? blob = item.get_data();
            string mime_type = item.get_mimetype();

            msg.set_response (mime_type, Soup.MemoryUse.COPY, blob);
            msg.set_status (Soup.Status.OK, null);
        } catch (Error err) {
            warning(err.message + ": " + r_path);

            info ("NOT_FOUND: %s", path);
            msg.set_status (Soup.Status.NOT_FOUND, null);
            msg.set_response (
                "text/html", Soup.MemoryUse.COPY, "Not Found.".data
            );
        }
    }
}
