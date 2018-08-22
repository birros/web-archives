public class WebArchives.Server : Soup.Server {
    private const uint UUID_LENGTH = 36;
    private HashTable<string, Zim.File> archives;
    private HashTable<string, uint> counts;
    public string url { get; private set; }

    public Server () {
        archives = new HashTable<string, Zim.File> (str_hash, str_equal);
        counts = new HashTable<string, uint> (str_hash, str_equal);

        add_handler (null, default_handler);

        try {
            listen_local (0, 0);
            uint port = get_uris().data.get_port();
            url = @"http://127.0.0.1:$port/";
        } catch (Error e) {
            error (e.message);
        }
    }

    public void add_archive (ArchiveItem archive) {
        if (!archives.contains (archive.uuid)) {
            try {
                Zim.File file = new Zim.File (archive.path);
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

    /**
     * FIXME: For now, url analysis and retrieval can cause bugs, since in the
     * future articles will no longer necessarily be in the `A` namespace.
     * See : https://github.com/openzim/libzim/issues/15
     */
    private void default_handler (
        Soup.Server        server,
        Soup.Message       msg,
        string             path_p,
        GLib.HashTable?    query,
        Soup.ClientContext client
    ) {
        string path = path_p;
        unowned Zim.File file;
        string uuid;
        uint home_index;
        Zim.Article page;
        Zim.Article home;
        char namesp;
        string article_url;
        uint8[]? blob;
        string mime_type;

        // check if url starts by `/<uuid>/` and try to get it if it's not set
        if (
            path.length < UUID_LENGTH + 2 ||
            path[0] != '/'                ||
            path[UUID_LENGTH + 1] != '/'
        ) {
            // get referer
            Soup.MessageHeaders headers = msg.request_headers;
            string referer = headers.get_one ("Referer");

            if (referer == null) {
                msg.set_status (Soup.Status.NOT_FOUND);
                return;
            }
            info ("Referer: %s", referer);

            // get uuid in referer
            uuid = referer.substring (url.length, UUID_LENGTH);

            // rewrite path
            path = "/" + uuid + path;
        }

        // check if a zim file corresponding to the uuid is opened
        uuid = path.substring(1, UUID_LENGTH);
        if (archives.contains (uuid)) {
            file = archives.get (uuid);
        } else {
            msg.set_status (Soup.Status.NOT_FOUND);
            return;
        }

        // get the real file path
        path = path.substring(UUID_LENGTH + 1);

        // check if the path start by `/<namespace>/` and and set it otherwise
        if (path.length < 3 || path[0] != '/' || path[2] != '/') {
            path = "/A" + path;
        }

        // get the real url of the main page
        if (path == "/A/") {
            if (file.get_fileheader ().has_main_page ()) {
                home_index = file.get_fileheader ().get_main_page ();
            } else {
                home_index = file.get_namespace_begin_offset ('A');
            }

            home = file.get_article_by_index (home_index);
            path += home.get_url ();
        }

        // get the page correponding to the url
        namesp = path [1];
        article_url = path.substring (3);
        page = file.get_article_by_namespace (namesp, article_url);

        // if the page is good send the data
        if (page.good ()) {
            if (page.is_redirect ()) {
                page = page.get_redirect_article ();
            }
            blob = page.get_data();
            mime_type = page.get_mime_type();

            msg.set_response (mime_type, Soup.MemoryUse.COPY, blob);
            msg.set_status (Soup.Status.OK);
        } else {
            info ("NOT_FOUND: %s", path);
            msg.set_status (Soup.Status.NOT_FOUND);
            msg.set_response (
                "text/html", Soup.MemoryUse.COPY, "Not Found.".data
            );
        }
    }
}
