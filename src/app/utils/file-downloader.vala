/**
 * Requires access to gvfs.
 */
public class WebArchives.FileDownloader : Object {
    public double progress {get; private set; default = 0;}
    public signal void complete ();
    public signal void canceled ();

    private uint64 header_size;
    private uint64 header_modified;

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

        File file = File.new_for_uri (source);
        get_infos.begin (file, () => {
            info ("header_size : %llu", header_size);
            info ("header_modified : %llu", header_modified);

            uint64 local_modified = get_file_timestamp (filepath);
            info ("local_modified : %llu", local_modified);

            if (
                !error &&
                (header_modified == 0 || header_modified > local_modified)
            ) {
                delete_file (filepath);
                DataOutputStream dos = create_part_file (filepath);

                get_file.begin (file, dos, () => {
                    if (!error) {
                        rename_part_file (filepath);
                        complete ();
                    } else {
                        delete_file (filepath + ".part");
                        canceled ();
                    }
                });
            } else {
                canceled ();
            }
        });
    }

    private async void get_infos (File file) {
        try {
            FileInfo info = yield file.query_info_async (
                "standard::size,time::modified", 0
            );
            header_size = info.get_size ();
            TimeVal modification_time = info.get_modification_time ();
            header_modified = modification_time.tv_sec;
        } catch (Error e) {
            warning (e.message);
            error = true;
        }
    }

    private async void get_file (File file, DataOutputStream dos) {
        try {
            FileInputStream inputstream = file.read ();
            DataInputStream dis = new DataInputStream (inputstream);

            uint8[] buffer = new uint8[100];
            ssize_t size;
            while ((size = yield dis.read_async (buffer)) > 0) {
                current_length += size;

                try {
                    dos.write (buffer[0:size]);
                } catch (Error e) {
                    warning (e.message);
                }

                if (header_size > 0) {
                    progress = (double) (current_length / (double) header_size);
                }
            }
            dos.flush ();
        } catch (Error e) {
            warning (e.message);
            error = true;
        }
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
                TimeVal temp_time = info.get_modification_time ();
                long timestamp = temp_time.tv_sec;
                return timestamp;
            } catch (Error e) {
                warning (e.message);
            }
        }
        return 0;
    }
}
