/*
 *  FIXME: ugly object, need to be refactored
 *  features:
 *  - https -> http support
 *  - http digest (md5, sha1, sha256)
 *  - caching
 *  - progress
 *  - cancellable
 *  - async
 *
 *  depends on Soup
 */
public class WebArchives.FileDownloader : Object {
    public double progress {get; private set; default = 0;    }
    public bool checked    {get; private set; default = false;}
    public bool cached     {get; private set; default = false;}
    public signal void complete ();
    public signal void canceled ();

    private uint64 content_length;
    private uint64 current_length;
    private string md5;
    private string sha1;
    private string sha256;
    private DataOutputStream dos;
    private Soup.Session session;
    private Soup.Message msg;
    private string source;
    private string filepath;
    private bool canceled_status;

    public void download_file (string source, string filepath) {
        this.source = source;
        this.filepath = filepath;

        create_dir (filepath);

        progress = 0;
        checked = false;
        content_length = 0;
        current_length = 0;
        md5 = null;
        sha1 = null;
        sha256 = null;
        canceled_status = false;
        session = new Soup.Session ();
        msg = new Soup.Message ("GET", source);

        cleanup ();

        msg.response_body.set_accumulate (false);
        msg.got_headers.connect (got_headers);
        msg.got_chunk.connect (got_chunk);

        session.queue_message (msg, (session, msg) => {
            if (
                !canceled_status &&
                content_length > 0 &&
                current_length == content_length
            ) {
                try {
                    dos.flush ();
                    cached = true;
                    verify ();
                    FileUtils.rename (filepath + ".part", filepath);
                    complete ();
                } catch (Error e) {
                    warning (e.message);
                }
            } else {
                File file = File.new_for_path (filepath);
                if (file.query_exists ()) {
                    cached = true;
                }
                cleanup ();
                canceled ();
            }
        });
    }

    private void create_dir (string filepath) {
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

    private void got_headers () {
        content_length = msg.response_headers.get_content_length ();

        string last_modified_str =
            msg.response_headers.get_one ("Last-Modified");
        if (last_modified_str != null) {
            Soup.Date last_modified_date =
                new Soup.Date.from_string (last_modified_str);
	        uint64 last_modified = (uint64) last_modified_date.to_time_t ();

            uint64 timestamp = get_file_timestamp (filepath);
            if (timestamp < last_modified) {
                try {
                    File file_old = File.new_for_path (filepath);

                    if (file_old.query_exists ()) {
                        file_old.delete ();
                    }
                } catch (Error e) {
                    warning (e.message);
                    cancel ();
                }
            } else {
                cancel ();
            }
        }

        try {
            File file = File.new_for_path (filepath + ".part");
            if (file.query_exists ()) {
                file.delete ();
            }
            dos = new DataOutputStream (
                file.create (FileCreateFlags.REPLACE_DESTINATION)
            );
        } catch (Error e) {
            warning (e.message);
            cancel ();
        }

        string digests_str = msg.response_headers.get_list ("Digest");
        if (digests_str != null) {
            string[] digests = digests_str.split (", ");
            foreach (unowned string digest in digests) {
	            string digest_base64 = "";
	            if (digest.has_prefix ("MD5=")) {
	                digest_base64 = digest.substring ("MD5=".length);
	                md5 = base64_to_hex (digest_base64);
	            } else if (digest.has_prefix ("SHA=")) {
	                digest_base64 = digest.substring ("SHA=".length);
	                sha1 = base64_to_hex (digest_base64);
	            } else if (digest.has_prefix ("SHA-256=")) {
	                digest_base64 = digest.substring ("SHA-256=".length);
	                sha256 = base64_to_hex (digest_base64);
	            }
            }
        }
    }

    public void cancel () {
        canceled_status = true;
        if (session != null && msg != null) {
            session.cancel_message (msg, Soup.Status.CANCELLED);
        }
    }

    private void got_chunk (Soup.Buffer chunk) {
        if (session.would_redirect (msg)) {
            info ("REDIRECT");
            return;
        }

        current_length += chunk.length;

        try {
            dos.write (chunk.data);
        } catch (Error e) {
            warning (e.message);
        }

        if (content_length > 0) {
            progress = (double) (current_length / (double) content_length);
        }
    }

    private void cleanup () {
        try {
            File file = File.new_for_path (filepath + ".part");
            if (file.query_exists ()) {
                file.delete ();
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    private void verify () {
        if (sha256 != null) {
            string sha256_file = get_checksum (
                filepath + ".part", ChecksumType.SHA256
            );
            if (sha256 == sha256_file) {
                checked = true;
            }
        } else if (sha1 != null) {
            string sha1_file = get_checksum (
                filepath + ".part", ChecksumType.SHA1
            );
            if (sha1 == sha1_file) {
                checked = true;
            }
        } else if (md5 != null) {
            string md5_file = get_checksum (
                filepath + ".part", ChecksumType.MD5
            );
            if (md5 == md5_file) {
                checked = true;
            }
        }
    }

    private string base64_to_hex (string base64) {
        uint8[] binary = Base64.decode (base64);
        string hex = "";
        for (uint8 i = 0; i < binary.length; i++) {
            hex += "%02x".printf (binary[i]);
        }
        return hex;
    }

    private uint64 get_file_timestamp (string filepath) {
        File file = File.new_for_path (filepath);
        if (file.query_exists ()) {
            try {
                //FileInfo info = file.query_filesystem_info ("*");
                FileInfo info = file.query_info (
                    "standard::content-type,time::modified", 0, null
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

    private string get_checksum (string filepath, ChecksumType type) {
        Checksum checksum = new Checksum (type);

	    FileStream stream = FileStream.open (filepath, "rb");
	    uint8 fbuf[100];
	    size_t size;

	    while ((size = stream.read (fbuf)) > 0) {
		    checksum.update (fbuf, size);
	    }

	    return checksum.get_string ();
    }
}
