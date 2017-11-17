public class WebArchives.SearchRecentDatabase : Object {
    private Database database;
    private SearchRecentStore recent_store;
    private HashTable<SearchRecentItem, ulong> callbacks;

    public SearchRecentDatabase (
        Database          database,
        SearchRecentStore recent_store
    ) {
        this.database = database;
        this.recent_store = recent_store;

        callbacks = new HashTable<SearchRecentItem, ulong> (
            direct_hash, direct_equal
        );

        if (database.db != null) {
            create_table ();
            fetch_table ();

            recent_store.foreach (listen);
            recent_store.item_added.connect (on_item_added);
            recent_store.item_removed.connect (on_item_removed);
        }
    }

    private void listen (SearchRecentItem item) {
        ulong callback = item.notify.connect (() => {
            on_item_updated (item);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (SearchRecentItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    private void on_item_added (SearchRecentItem item) {
        insert (item);
        listen (item);
    }

    private void on_item_removed (SearchRecentItem item) {
        delete_item (item);
        unlisten (item);
    }

    private void on_item_updated (SearchRecentItem item) {
        update (item);
    }

    private void create_table () {
        string sql = """
        CREATE TABLE IF NOT EXISTS recents (
            text TEXT,
            name TEXT,
            timestamp INTEGER
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
            text,
            name,
            timestamp
        FROM recents
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        do {
            rc = stmt.step();
            switch (rc) {
                case Sqlite.DONE:
                {
                    break;
                }
                case Sqlite.ROW:
                {
                    SearchRecentItem item = new SearchRecentItem (
                        stmt.column_text  (0), // text
                        stmt.column_text  (1), // name
                        stmt.column_int64 (2)  // timestamp
                    );
                    recent_store.add (item);
                    break;
                }
                default:
                {
                    error (database.db.errmsg ());
                }
            }
        } while (rc == Sqlite.ROW);
    }

    private void insert (SearchRecentItem item) {
        string sql = """
        INSERT INTO recents (
            text,
            name,
            timestamp
        ) VALUES (
            $text,
            $name,
            $timestamp
        );
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int text_position = stmt.bind_parameter_index ("$text");
        int name_position = stmt.bind_parameter_index ("$name");
        int timestamp_position = stmt.bind_parameter_index ("$timestamp");

        stmt.bind_text (text_position, item.text);
        stmt.bind_text (name_position, item.name);
        stmt.bind_int64 (timestamp_position, item.timestamp);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }

    private void delete_item (SearchRecentItem item) {
        string sql = """
        DELETE FROM recents
        WHERE text=$text AND name=$name;
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int text_position = stmt.bind_parameter_index ("$text");
        int name_position = stmt.bind_parameter_index ("$name");

        stmt.bind_text (text_position, item.text);
        stmt.bind_text (name_position, item.name);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }

    private void update (SearchRecentItem item) {
        string sql = """
        UPDATE recents SET
            timestamp=$timestamp
        WHERE text=$text AND name=$name;
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int timestamp_position = stmt.bind_parameter_index ("$timestamp");
        int text_position = stmt.bind_parameter_index ("$text");
        int name_position = stmt.bind_parameter_index ("$name");

        stmt.bind_int64 (timestamp_position, item.timestamp);
        stmt.bind_text (text_position, item.text);
        stmt.bind_text (name_position, item.name);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }
}
