public class WebArchives.ArchiveDownloader : Object {
    public static void download (string url) {
        string[] url_parts = url.split (".");
        string extension = url_parts [url_parts.length - 1];

        if (extension == "meta4") {
            download_metalink (url);
        }
    }

    private static void download_metalink (string metalink_url) {
        string[] url_parts = metalink_url.split ("/");
        string metalink_filename = url_parts [url_parts.length - 1];

        // build metalink path
        string cache_dir = Environment.get_user_cache_dir ();
        string files_folder = Path.build_filename (
            cache_dir, "web-archives", "files"
        );
        string metalink_path = Path.build_filename(
            files_folder, metalink_filename
        );

        FileDownloader metalink_downloader = new FileDownloader ();
        metalink_downloader.download_file (metalink_url, metalink_path);
        metalink_downloader.complete.connect (() => {
            info ("COMPLETE");

            // parse metalink
            MetalinkParser metalink_parser = new MetalinkParser ();
            Metalink metalink = metalink_parser.parse_file (metalink_path);

            // download first https
            unowned SList<string> urls = metalink.urls;
            while (urls != null) {
                if (urls.data.has_prefix ("https://")) {
                    info ("download: %s", urls.data);
                    try {
                        AppInfo.launch_default_for_uri (urls.data, null);
                    } catch (Error e) {
                        warning (e.message);
                    }
                    return;
                }
                urls = urls.next;
            }
        });
        metalink_downloader.notify["progress"].connect (() => {
            uint8 progress_percent = (uint8) (
                metalink_downloader.progress * 100
            );
            info ("%u %%", progress_percent);
        });
    }
}
