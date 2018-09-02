public class WebArchives.Remote : Object {
    private const string LIBRARY_URL =
        "https://download.kiwix.org/library/library_zim.xml";
    private ArchiveStore archive_store;
    private string library_path;
    public int64 timestamp  {get; set;         default = 0;    }
    public bool downloading {get; private set; default = false;}
    public double progress  {get; private set; default = 0;    }
    public bool enabled     {get; private set; default = false;}

    public Remote (ArchiveStore archive_store) {
        this.archive_store = archive_store;

        if (
            DBusUtils.is_name_activatable ("org.gtk.vfs.Daemon") &&
            DBusUtils.is_gvfs_backend_supported ("http")
        ) {
            enabled = true;
            info ("HTTP GVFS backend is present");
        } else {
            enabled = false;
            info ("HTTP GVFS backend is not present");
        }

        // build library path
        string cache_dir = Environment.get_user_cache_dir ();
        string files_folder = Path.build_filename (
            cache_dir, "web-archives", "files"
        );
        library_path = Path.build_filename(files_folder, "library_zim.xml");
    }

    public void refresh () {
        if (!enabled) {
            return;
        }

        FileDownloader library_downloader = new FileDownloader ();
        library_downloader.download_file (LIBRARY_URL, library_path);
        library_downloader.complete.connect (() => {
            parse_library ();
            update_timestamp ();
        });
        library_downloader.notify["progress"].connect (() => {
            progress = library_downloader.progress;
        });
    }

    private void parse_library () {
        // parse library
        LibraryParser library_parser = new LibraryParser ();
        LibraryModel library_model = library_parser.parse_file (library_path);

        // add library items into archive store
        library_model.foreach ((library_item) => {
            bool contains = archive_store.contains_by_scope_and_uuid (
                "REMOTE", library_item.id
            );
            if (!contains) {
                ArchiveItem archive_item =
                    ArchiveUtils.archive_from_library_item (library_item);
                archive_item.scope = "REMOTE";
                archive_store.add (archive_item);
                info ("REMOTE ARCHIVE ADDED: %s", archive_item.uuid);
            }
        });

        // remove old library archive
        archive_store.foreach ((archive) => {
            bool contains = library_model.contains_by_id (archive.uuid);
            if (archive.scope == "REMOTE" && !contains) {
                archive_store.remove (archive);
                info ("REMOTE ARCHIVE REMOVED: %s", archive.uuid);
            }
        });
    }

    private void update_timestamp () {
        DateTime time = new DateTime.now_utc ();
        timestamp = time.to_unix ();
    }
}
