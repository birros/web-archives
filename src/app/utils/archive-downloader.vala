public class WebArchives.ArchiveDownloader : Object {
    public enum Type {
        DIRECT,
        TORRENT
    }

    public static void download (string url, Type type) {
        // ensure that https is used
        string archive_url = url.replace ("http://", "https://");

        string[] url_parts = archive_url.split (".");
        string extension = url_parts [url_parts.length - 1];

        // remove meta4 file extension if exists
        if (extension == "meta4") {
            int limit = archive_url.length - "meta4".length - 1;
            archive_url = archive_url.substring (0, limit);
        }

        switch (type) {
            case Type.DIRECT:
            {
                try {
                    AppInfo.launch_default_for_uri (archive_url, null);
                } catch (Error e) {
                    warning (e.message);
                }
                break;
            }
            case Type.TORRENT:
            {
                /**
                 * The Kiwix download server is a MirrorBrain server, so a
                 * torrent file exists for all the files it serves.
                 * Just add a torrent file extension to the url to get it.
                 */
                download_torrent (archive_url + ".torrent");
                break;
            }
        }
    }

    private static void download_torrent (string url) {
        string[] url_parts = url.split ("/");
        string filename = url_parts [url_parts.length - 1];

        // build torrent path
        string cache_dir = Environment.get_user_cache_dir ();
        string files_folder = Path.build_filename (
            cache_dir, "web-archives", "files"
        );
        string torrent_path = Path.build_filename(
            files_folder, filename
        );

        FileDownloader downloader = new FileDownloader ();
        downloader.download_file (url, torrent_path);
        downloader.complete.connect (() => {
            try {
                string torrent_file_uri = Filename.to_uri (torrent_path);
                AppInfo.launch_default_for_uri (torrent_file_uri, null);
            } catch (Error e) {
                warning (e.message);
            }
        });
        downloader.notify["progress"].connect (() => {
            uint8 progress_percent = (uint8) (
                downloader.progress * 100
            );
            info ("%u %%", progress_percent);
        });
    }
}
