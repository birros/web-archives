public class WebArchives.BookmarkDatabase : Object {
    private Database database;
    private BookmarkStore bookmark_store;

    public BookmarkDatabase (Database database, BookmarkStore bookmark_store) {
        this.database = database;
        this.bookmark_store = bookmark_store;

        if (database.db != null) {
            create_table ();
            fetch_table ();

            bookmark_store.item_added.connect (on_item_added);
            bookmark_store.item_removed.connect (on_item_removed);
        }
    }

    private void on_item_added (BookmarkItem item) {
        insert (item);
    }

    private void on_item_removed (BookmarkItem item) {
        delete_item (item);
    }

    private void create_table () {
        string sql = """
        CREATE TABLE IF NOT EXISTS bookmarks (
            title TEXT,
            url TEXT,
            name TEXT
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
            name
        FROM bookmarks
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
                    BookmarkItem bookmark = new BookmarkItem (
                        stmt.column_text (0), //title
                        stmt.column_text (1), //url
                        stmt.column_text (2)  //name
                    );
                    bookmark_store.add (bookmark);
                    break;
                }
                default:
                {
                    error (database.db.errmsg ());
                }
            }
        } while (rc == Sqlite.ROW);
    }

    private void insert (BookmarkItem item) {
        string sql = """
        INSERT INTO bookmarks (
            title,
            url,
            name
        ) VALUES (
            $title,
            $url,
            $name
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

        stmt.bind_text (title_position, item.title);
        stmt.bind_text (url_position, item.url);
        stmt.bind_text (name_position, item.name);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }

    private void delete_item (BookmarkItem item) {
        string sql = """
        DELETE FROM bookmarks
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
}
