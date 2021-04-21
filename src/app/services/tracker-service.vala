public class WebArchives.TrackerService : Object {
    private ArchiveStore archive_store;
    public int64 timestamp {get; set; default = 0;}
    public bool enabled {get; set; default = false;}

    public TrackerService (ArchiveStore archive_store) {
        this.archive_store = archive_store;

        if (DBusUtils.is_name_activatable (
            "org.freedesktop.Tracker3.Miner.Files"
        )) {
            enabled = true;
            info ("Tracker is present");
        } else {
            enabled = false;
            info ("Tracker is not present");
        }
    }

    public void refresh () {
        if (enabled) {
            new Thread<bool> ("_refresh", this._refresh);
        }
    }

    private bool _refresh () {
        GenericSet<string> tracker_list =
            new GenericSet<string> (str_hash, str_equal);

        // build tracker list
        try {
            Tracker.Sparql.Connection connection =
                Tracker.Sparql.Connection.bus_new(
                    "org.freedesktop.Tracker3.Miner.Files",
                    null,
                    null
                );
            Tracker.Sparql.Cursor cursor = connection.query (
                """
                SELECT nie:url(?f)
                WHERE {
                    ?f a nfo:FileDataObject
                    FILTER regex(nie:url(?f), '[.]zim$')
                }"""
            );
            while (cursor.next ()) {
                string uri = cursor.get_string (0);
                string path = Filename.from_uri (uri);

                tracker_list.add (path);
            }
        } catch (Error e) {
            warning (e.message);
        }

        // add new local archive
        tracker_list.foreach ((path) => {
            if (!archive_store.contains_by_scope_and_path ("LOCAL", path)) {
                ArchiveItem archive = ArchiveUtils.archive_from_file (path);
                archive.scope = "LOCAL";
                archive_store.add (archive);
                info ("LOCAL ARCHIVE ADDED: %s", path);
            }
        });

        // remove old local archive
        archive_store.foreach ((archive) => {
            bool contains = tracker_list.contains (archive.path);
            if (archive.scope == "LOCAL" && !contains) {
                archive_store.remove (archive);
                info ("LOCAL ARCHIVE REMOVED: %s", archive.path);
            }
        });

        update_timestamp ();

        // This return is just to comply with the Thread policy
        return true;
    }

    private void update_timestamp () {
        DateTime time = new DateTime.now_utc ();
        timestamp = time.to_unix ();
    }
}
