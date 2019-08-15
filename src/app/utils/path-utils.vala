public class WebArchives.PathUtils : Object {
    public static string file_is_compressed(string filename) {
        string[] compressions = { ".gz", ".bz2", ".Z", ".lz", ".xz" };
        foreach (string extension in compressions) {
            if (filename.has_suffix(extension)) {
                return extension;
            }
        }
        return "";
    }

    public static string parse_extension(string filename) {
        string compression = file_is_compressed(filename);

        if (compression != "") {
            string[] extensions = { "tar", "ps", "xcf", "dvi", "txt", "text" };
            foreach (string extension in extensions) {
                string suffix = extension + compression;
                string suffix_bis = "." + suffix;
                if (
                    filename.has_suffix(suffix_bis) &&
                    filename.length > suffix_bis.length
                ) {
                    return suffix;
                }
            }
        }

        string[] parts = filename.split(".");
        if (parts.length == 1) {
            return "";
        }

        return parts[parts.length - 1];
    }

    public static string parse_filename(string filename) {
        string extension = parse_extension(filename);

        if (extension == "") {
            return filename;
        }

        return filename.substring(0, filename.length - extension.length - 1);
    }

    public static string build_destination(
        string suggested_filename,
        int count
    ) {
        string extension = parse_extension(suggested_filename);
        string filename = parse_filename(suggested_filename);

        if (count == 0) {
            return suggested_filename;
        }

        string filename_bis = filename + @"($count)";
        if (extension == "") {
            return filename_bis;
        }

        return string.join(".", filename_bis, extension);
    }
}