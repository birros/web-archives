public class WebArchives.HistoryDatabase : Object {
    private Database database;
    private HistoryStore history_store;
    private HashTable<HistoryItem, ulong> callbacks;

    public HistoryDatabase (Database database, HistoryStore history_store) {
        this.database = database;
        this.history_store = history_store;

        callbacks = new HashTable<HistoryItem, ulong> (
            direct_hash, direct_equal
        );

        if (database.db != null) {
            create_table ();
            fetch_table ();

            history_store.foreach (listen);
            history_store.item_added.connect (on_item_added);
            history_store.item_removed.connect (on_item_removed);
        }
    }

    private void listen (HistoryItem item) {
        ulong callback = item.notify.connect (() => {
            on_item_updated (item);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (HistoryItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    private void on_item_added (HistoryItem item) {
        insert (item);
        listen (item);
    }

    private void on_item_removed (HistoryItem item) {
        delete_item (item);
        unlisten (item);
    }

    private void on_item_updated (HistoryItem item) {
        update (item);
    }

    private void create_table () {
        string sql = """
        CREATE TABLE IF NOT EXISTS history (
            title TEXT,
            url TEXT,
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
            title,
            url,
            name,
            timestamp
        FROM history
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
                    HistoryItem item = new HistoryItem (
                        stmt.column_text  (0), //title
                        stmt.column_text  (1), //url
                        stmt.column_text  (2), //name
                        stmt.column_int64 (3)  //timestamp
                    );

                    history_store.add (item);
                    break;
                }
                default:
                {
                    error (database.db.errmsg ());
                }
            }
        } while (rc == Sqlite.ROW);
    }

    private void insert (HistoryItem item) {
        string sql = """
        INSERT INTO history (
            title,
            url,
            name,
            timestamp
        ) VALUES (
            $title,
            $url,
            $name,
            $timestamp
        );
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int title_position = stmt.bind_parameter_index ("$title");
        int url_position = stmt.bind_parameter_index ("$url");
        int name_position = stmt.bind_parameter_index ("$name");
        int timestamp_position = stmt.bind_parameter_index ("$timestamp");

        stmt.bind_text (title_position, item.title);
        stmt.bind_text (url_position, item.url);
        stmt.bind_text (name_position, item.name);
        stmt.bind_int64 (timestamp_position, item.timestamp);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }

    private void delete_item (HistoryItem item) {
        string sql = """
        DELETE FROM history
        WHERE url=$url AND name=$name;
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int url_position = stmt.bind_parameter_index ("$url");
        int name_position = stmt.bind_parameter_index ("$name");

        stmt.bind_text (url_position, item.url);
        stmt.bind_text (name_position, item.name);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }

    private void update (HistoryItem item) {
        string sql = """
        UPDATE history SET
            timestamp=$timestamp
        WHERE url=$url AND name=$name;
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int timestamp_position = stmt.bind_parameter_index ("$timestamp");
        int url_position = stmt.bind_parameter_index ("$url");
        int name_position = stmt.bind_parameter_index ("$name");

        stmt.bind_int64 (timestamp_position, item.timestamp);
        stmt.bind_text (url_position, item.url);
        stmt.bind_text (name_position, item.name);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }
}
