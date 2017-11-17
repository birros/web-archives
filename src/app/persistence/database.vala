public class WebArchives.Database : Object {
    private Sqlite.Database _db;
    public Sqlite.Database db {
        get {
            return _db;
        }
        private set {}
    }

    public Database () {
        string cache_dir = Environment.get_user_cache_dir ();
        string app_folder = Path.build_filename (cache_dir, "web-archives");
        string db_path = Path.build_filename(app_folder, "db.sqlite3");

        File app_folder_file = File.new_for_path (app_folder);
        if (!app_folder_file.query_exists ()) {
            try {
                app_folder_file.make_directory_with_parents ();
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
