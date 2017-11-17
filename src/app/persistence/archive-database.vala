public class WebArchives.ArchiveDatabase : Object {
    private Database database;
    private ArchiveStore archive_store;
    private HashTable<ArchiveItem, ulong> callbacks;
    private SList<ArchiveItem> cache;
    private uint timeout = 0;

    /**
     * SQLITE_MAX_VARIABLE_NUMBER:
     *     hard coded in the sqlite to 999.
     * INSERT_VARIABLES:
     *     number of variables used with Statement in insert function.
     */
    private const uint SQLITE_MAX_VARIABLE_NUMBER = 999;
    private const uint INSERT_VARIABLES = 17;
    private const uint CACHE_INSERT_MAX =
        SQLITE_MAX_VARIABLE_NUMBER / INSERT_VARIABLES;

    public ArchiveDatabase (Database database, ArchiveStore archive_store) {
        this.database = database;
        this.archive_store = archive_store;

        callbacks = new HashTable<ArchiveItem, ulong> (
            direct_hash, direct_equal
        );
        cache = new SList<ArchiveItem> ();

        if (database.db != null) {
            create_table ();
            fetch_table ();

            archive_store.foreach (listen);
            archive_store.item_added.connect (on_item_added);
            archive_store.item_removed.connect (on_item_removed);
        }
    }

    private void listen (ArchiveItem item) {
        ulong callback = item.notify.connect (() => {
            on_item_updated (item);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (ArchiveItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    private void on_item_added (ArchiveItem item) {
        insert (item);
        listen (item);
    }

    private void on_item_removed (ArchiveItem item) {
        delete_item (item);
        unlisten (item);
    }

    private void on_item_updated (ArchiveItem item) {
        update (item);
    }

    private void create_table () {
        string sql = """
        CREATE TABLE IF NOT EXISTS archives (
            path TEXT,
            favicon TEXT,
            title TEXT,
            date TEXT,
            lang TEXT,
            size INTEGER,
            name TEXT,
            uuid TEXT,
            tags TEXT,
            description TEXT,
            article_count INTEGER,
            media_count INTEGER,
            creator TEXT,
            publisher TEXT,
            url TEXT,
            timestamp INTEGER,
            scope TEXT
        );
        """;

        int rc = database.db.exec (sql);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }
    }

    private void fetch_table () {
        string sql = """
        SELECT
            path,
            favicon,
            title,
            date,
            lang,
            size,
            name,
            uuid,
            tags,
            description,
            article_count,
            media_count,
            creator,
            publisher,
            url,
            timestamp,
            scope
        FROM archives
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        do {
            rc = stmt.step ();
            switch (rc) {
                case Sqlite.DONE:
                {
                    break;
                }
                case Sqlite.ROW:
                {
                    ArchiveItem archive = new ArchiveItem (
                        stmt.column_text  (0),  //path
                        stmt.column_text  (1),  //favicon
                        stmt.column_text  (2),  //title
                        stmt.column_text  (3),  //date
                        stmt.column_text  (4),  //lang
                        stmt.column_int64 (5),  //size
                        stmt.column_text  (6),  //name
                        stmt.column_text  (7),  //uuid
                        stmt.column_text  (8),  //tags
                        stmt.column_text  (9),  //description
                        stmt.column_int64 (10), //article_count
                        stmt.column_int64 (11), //media_count
                        stmt.column_text  (12), // creator
                        stmt.column_text  (13), // publisher
                        stmt.column_text  (14), //url
                        stmt.column_int64 (15), //timestamp
                        stmt.column_text  (16)  //scope
                    );
                    archive_store.add (archive);
                    break;
                }
                default:
                {
                    error (database.db.errmsg ());
                }
            }
        } while (rc == Sqlite.ROW);
    }

    private void insert (ArchiveItem item) {
        if (cache.length () == 0) {
            if (timeout > 0) {
                Source.remove (timeout);
            }
            timeout = Timeout.add (1, () => {
                insert_multiple ();
                if (cache.length () == 0) {
                    timeout = 0;
                    return false;
                } else {
                    return true;
                }
            });
        }
        cache.append (item);
        if (cache.length () == CACHE_INSERT_MAX) {
            insert_multiple ();
        }
    }

    private void insert_multiple () {
        string request = """
        INSERT INTO archives (
            path,
            favicon,
            title,
            date,
            lang,
            size,
            name,
            uuid,
            tags,
            description,
            article_count,
            media_count,
            creator,
            publisher,
            url,
            timestamp,
            scope
        ) VALUES
        """;

        string val = """
        (
            $path%d,
            $favicon%d,
            $title%d,
            $date%d,
            $lang%d,
            $size%d,
            $name%d,
            $uuid%d,
            $tags%d,
            $description%d,
            $article_count%d,
            $media_count%d,
            $creator%d,
            $publisher%d,
            $url%d,
            $timestamp%d,
            $scope%d
        )
        """;

        string sql = request;
        for (var i = 0; i < cache.length (); i++) {
            string val_tmp = val.printf (i,i,i,i,i,i,i,i,i,i,i,i,i,i,i,i,i);
            sql += val_tmp;
            if (i < cache.length () - 1) {
                sql += ",";
            } else {
                sql += ";";
            }
        }

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int i = 0;
        cache.foreach ((archive) => {
            int path_position = stmt.bind_parameter_index ("$path" + i.to_string ());
            int favicon_position = stmt.bind_parameter_index ("$favicon" + i.to_string ());
            int title_position = stmt.bind_parameter_index ("$title" + i.to_string ());
            int date_position = stmt.bind_parameter_index ("$date" + i.to_string ());
            int lang_position = stmt.bind_parameter_index ("$lang" + i.to_string ());
            int size_position = stmt.bind_parameter_index ("$size" + i.to_string ());
            int name_position = stmt.bind_parameter_index ("$name" + i.to_string ());
            int uuid_position = stmt.bind_parameter_index ("$uuid" + i.to_string ());
            int tags_position = stmt.bind_parameter_index ("$tags" + i.to_string ());
            int description_position = stmt.bind_parameter_index ("$description" + i.to_string ());
            int article_count_position = stmt.bind_parameter_index ("$article_count" + i.to_string ());
            int media_count_position = stmt.bind_parameter_index ("$media_count" + i.to_string ());
            int creator_position = stmt.bind_parameter_index ("$creator" + i.to_string ());
            int publisher_position = stmt.bind_parameter_index ("$publisher" + i.to_string ());
            int url_position = stmt.bind_parameter_index ("$url" + i.to_string ());
            int timestamp_position = stmt.bind_parameter_index ("$timestamp" + i.to_string ());
            int scope_position = stmt.bind_parameter_index ("$scope" + i.to_string ());

            stmt.bind_text (path_position, archive.path);
            stmt.bind_text (favicon_position, archive.favicon);
            stmt.bind_text (title_position, archive.title);
            stmt.bind_text (date_position, archive.date);
            stmt.bind_text (lang_position, archive.lang);
            stmt.bind_int64 (size_position, archive.size);
            stmt.bind_text (name_position, archive.name);
            stmt.bind_text (uuid_position, archive.uuid);
            stmt.bind_text (tags_position, archive.tags);
            stmt.bind_text (description_position, archive.description);
            stmt.bind_int64 (article_count_position, archive.article_count);
            stmt.bind_int64 (media_count_position, archive.media_count);
            stmt.bind_text (creator_position, archive.creator);
            stmt.bind_text (publisher_position, archive.publisher);
            stmt.bind_text (url_position, archive.url);
            stmt.bind_int64 (timestamp_position, archive.timestamp);
            stmt.bind_text (scope_position, archive.scope);

            i++;
        });

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }

        cache = new SList<ArchiveItem> ();
    }

    private void delete_item (ArchiveItem item) {
        Sqlite.Statement stmt;
        int rc;
        if (item.scope == "RECENTS" || item.scope == "LOCAL") {
            string sql = """
            DELETE FROM archives
            WHERE path=$path AND scope=$scope;
            """;

            rc = database.db.prepare_v2 (sql, -1, out stmt);
            if (rc != Sqlite.OK) {
                error (database.db.errmsg ());
            }

            int path_position = stmt.bind_parameter_index ("$path");
            int scope_position = stmt.bind_parameter_index ("$scope");

            stmt.bind_text (path_position, item.path);
            stmt.bind_text (scope_position, item.scope);

            rc = stmt.step ();
            if (rc != Sqlite.DONE) {
                error (database.db.errmsg ());
            }
        }
        if (item.scope == "REMOTE") {
            string sql = """
            DELETE FROM archives
            WHERE uuid=$uuid AND scope=$scope;
            """;

            rc = database.db.prepare_v2 (sql, -1, out stmt);
            if (rc != Sqlite.OK) {
                error (database.db.errmsg ());
            }

            int uuid_position = stmt.bind_parameter_index ("$uuid");
            int scope_position = stmt.bind_parameter_index ("$scope");

            stmt.bind_text (uuid_position, item.uuid);
            stmt.bind_text (scope_position, item.scope);

            rc = stmt.step ();
            if (rc != Sqlite.DONE) {
                error (database.db.errmsg ());
            }
        }
    }

    private void update (ArchiveItem item) {
        Sqlite.Statement stmt;
        int rc;
        if (item.scope == "RECENTS" || item.scope == "LOCAL") {
            string sql = """
            UPDATE archives SET
                timestamp=$timestamp
            WHERE path=$path AND scope=$scope;
            """;

            rc = database.db.prepare_v2 (sql, -1, out stmt);
            if (rc != Sqlite.OK) {
                error (database.db.errmsg ());
            }

            int timestamp_position = stmt.bind_parameter_index ("$timestamp");
            int path_position = stmt.bind_parameter_index ("$path");
            int scope_position = stmt.bind_parameter_index ("$scope");

            stmt.bind_int64 (timestamp_position, item.timestamp);
            stmt.bind_text (path_position, item.path);
            stmt.bind_text (scope_position, item.scope);

            rc = stmt.step ();
            if (rc != Sqlite.DONE) {
                error (database.db.errmsg ());
            }
        }
        if (item.scope == "REMOTE") {
            string sql = """
            UPDATE archives SET
                timestamp=$timestamp
            WHERE uuid=$uuid AND scope=$scope;
            """;

            rc = database.db.prepare_v2 (sql, -1, out stmt);
            if (rc != Sqlite.OK) {
                error (database.db.errmsg ());
            }

            int timestamp_position = stmt.bind_parameter_index ("$timestamp");
            int uuid_position = stmt.bind_parameter_index ("$uuid");
            int scope_position = stmt.bind_parameter_index ("$scope");

            stmt.bind_int64 (timestamp_position, item.timestamp);
            stmt.bind_text (uuid_position, item.uuid);
            stmt.bind_text (scope_position, item.scope);

            rc = stmt.step ();
            if (rc != Sqlite.DONE) {
                error (database.db.errmsg ());
            }
        }
    }
}
