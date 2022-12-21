public class WebArchives.FileDownloader : Object {
    public double progress {get; private set; default = 0;}
    public signal void complete ();
    public signal void canceled ();

    private uint64 header_size;
    private uint64 header_modified;

    private uint64 local_modified;

    private uint64 current_length;
    private bool error;
    private string source;
    private string filepath;

    public void download_file (string source, string filepath) {
        this.source = source;
        this.filepath = filepath;

        header_size = 0;
        header_modified = 0;

        progress = 0;
        current_length = 0;
        error = false;

        create_dir (filepath);
        delete_file (filepath + ".part");
        local_modified = get_file_timestamp (filepath);

        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", source);

        message.got_headers.connect((message) => {
            if (message.status_code != 200) {
                return;
            }

            // header_size
            header_size = message.response_headers.get_content_length();

            // header_modified
            var last_modified = message.response_headers.get_one("Last-Modified");
            DateTime modification_time = parse_modification_date_time(last_modified);
            header_modified = modification_time.to_unix ();

            // debug
            info ("header_size : %llu", header_size);
            info ("header_modified : %llu", header_modified);
            info ("local_modified : %llu", local_modified);

            // stop if no header_modified or if local is more recent than remote
            if (header_modified == 0 || local_modified > header_modified) {
                session.abort();
                canceled();
            }
        });

        // FIXME: progress code removed due to `got_chunk` depreciation
        
        // send message asynchronously
        session.send_async.begin (message, 0, null, (obj, res) => {
            try {
                InputStream? stream = session.send_async.end (res);

                // cancel if stream is null
                if (stream == null) {
                    canceled();
                    return;
                }

                // delete previous file
                delete_file (filepath);

                // write data
                DataOutputStream dos = create_part_file (filepath);
                dos.splice (stream, GLib.OutputStreamSpliceFlags.CLOSE_SOURCE);
                dos.flush ();

                // rename file & complete
                rename_part_file (filepath);
                complete ();
            } catch (Error e) {
                warning (e.message);
                canceled ();
            }
        });
    }

    private DateTime parse_modification_date_time (string? last_modified_full) {
        if (last_modified_full != null) {
            var parts = last_modified_full.split(", ");
            if (parts.length > 1) {
                var last_modified = parts[1];
                var time = Time();
                var res = time.strptime(last_modified, "%d %b %Y %H:%M:%S GMT");
                if (res != null) {
                    var last_modified_iso = time.format("%Y-%m-%dT%H:%M:%SZ");
                    return new DateTime.from_iso8601 (last_modified_iso, null);
                }
            }
        }
        return new DateTime.now_utc();
    }

    private static void rename_part_file (string filepath) {
        FileUtils.rename (filepath + ".part", filepath);
    }

    private static DataOutputStream? create_part_file (string filepath) {
        try {
            File file = File.new_for_path (filepath + ".part");
            if (file.query_exists ()) {
                file.delete ();
            }
            DataOutputStream dos = new DataOutputStream (
                file.create (FileCreateFlags.REPLACE_DESTINATION)
            );
            return dos;
        } catch (Error e) {
            warning (e.message);
            return null;
        }
    }

    private static void create_dir (string filepath) {
        string parent_dir = Path.get_dirname (filepath);
        File parent_dir_file = File.new_for_path (parent_dir);
        if (!parent_dir_file.query_exists ()) {
            try {
                parent_dir_file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    private static void delete_file (string filepath) {
        try {
            File file = File.new_for_path (filepath);
            if (file.query_exists ()) {
                file.delete ();
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    private static uint64 get_file_timestamp (string filepath) {
        File file = File.new_for_path (filepath);
        if (file.query_exists ()) {
            try {
                FileInfo info = file.query_info (
                    "time::modified", 0, null
                );
                DateTime temp_time = info.get_modification_date_time ();
                uint64 timestamp = temp_time.to_unix ();
                return timestamp;
            } catch (Error e) {
                warning (e.message);
            }
        }
        return 0;
    }
}
