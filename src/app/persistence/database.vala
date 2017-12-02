public class WebArchives.Database : Object {
    public enum Type {
        CACHE,
        CONFIG,
        DATA
    }
    private Sqlite.Database _db;
    public Sqlite.Database db {
        get {
            return _db;
        }
        private set {}
    }

    public Database (Type type) {
        string parent_dir;
        switch (type) {
            case Type.CACHE:
            {
                parent_dir = Environment.get_user_cache_dir ();
                break;
            }
            case Type.CONFIG:
            {
                parent_dir = Environment.get_user_config_dir ();
                break;
            }
            case Type.DATA:
            {
                parent_dir = Environment.get_user_data_dir ();
                break;
            }
            /**
             * This is used to prevent possible unset parent_dir variable
             * warning.
             */
            default:
            {
                parent_dir = "/tmp";
                break;
            }
        }
        string database_dir = Path.build_filename (parent_dir, "web-archives");
        string db_path = Path.build_filename (database_dir, "db.sqlite3");

        File database_dir_file = File.new_for_path (database_dir);
        if (!database_dir_file.query_exists ()) {
            try {
                database_dir_file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }

        int rc = Sqlite.Database.open (db_path, out _db);
        if (rc != Sqlite.OK) {
            warning (db.errmsg ());
            _db = null;
        }
    }
}
