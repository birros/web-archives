public class WebArchives.ArchiveUtils : Object {
    public static string get_random_page_url (ArchiveItem archive) {
        try {
            Zim.Archive zim = new Zim.Archive (archive.path);
            WebArchives.ZimReader reader = new WebArchives.ZimReader (zim);
            string url = reader.get_random_page_url ();
            /*
             * Fix missing slash.
             */
            if (url.length > 0 && url[0] != '/') {
                url = "/" + url;
            }
    
            return url;
        } catch (Error err) {
            warning(err.message);
            return "C/";
        }
    }

    public static ArchiveItem? archive_from_file (string path) {
        try {
            Zim.Archive zim_archive = new Zim.Archive (path);
            WebArchives.ZimReader reader = new WebArchives.ZimReader (zim_archive);

            string uuid = reader.get_id ();

            uint8[]? data;
            string mime_type;
            reader.get_faveicon (out data, out mime_type);
            string favicon = save_favicon (uuid ,data);

            ArchiveItem archive = new ArchiveItem (
                path,
                favicon,
                reader.get_title (),
                reader.get_date (),
                reader.get_language (), //lang
                reader.get_file_size (),
                reader.get_name (),
                uuid,
                reader.get_tags (),
                reader.get_description (),
                reader.get_article_count (),
                reader.get_media_count (),
                reader.get_creator (),
                reader.get_publisher (),
                "" //url
            );
            return archive;
        } catch (Error e) {
            warning (e.message);
        }

        return null;
    }

    public static ArchiveItem archive_from_library_item (
        LibraryItem library_item
    ) {
        uint8[] favicon_data = (uint8[]) Base64.decode (library_item.favicon);
        string favicon = save_favicon (library_item.id, favicon_data);

        ArchiveItem archive = new ArchiveItem (
            "", //path
            favicon,
            library_item.title,
            library_item.date,
            library_item.language, //lang
            (int64) library_item.size,
            library_item.name,
            library_item.id, //uuid
            library_item.tags,
            library_item.description,
            (int64) library_item.article_count,
            (int64) library_item.media_count,
            library_item.creator,
            library_item.publisher,
            library_item.url
        );

        return archive;
    }

    private static string save_favicon (string filename, uint8[]? data) {
        string cache_dir = Environment.get_user_cache_dir ();
        string favicons_folder = Path.build_filename (
            cache_dir, "web-archives", "favicons"
        );
        string favicon_path = Path.build_filename(favicons_folder, filename);

        File favicons_folder_file = File.new_for_path (favicons_folder);
        if (!favicons_folder_file.query_exists ()) {
            try {
                favicons_folder_file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }

        FileStream file = FileStream.open (favicon_path, "wb");
        file.write (data);
        file.flush ();

        return favicon_path;
    }
}
