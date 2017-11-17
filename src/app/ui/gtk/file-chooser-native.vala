/**
 *  FIXME: When we run flatpak-builder --run BUILDDIR MANIFEST the
 *  /run/user/$UID/doc/ directory is not present. This seems to be an error
 *  specific to flatpak-builder. When the bug will be fixed this code will be
 *  unecesseraly.
 */
public class WebArchives.FileChooserNative : Object {
    enum Type {
        SANDBOXED,
        UNBOXED
    }

    private Gtk.FileChooserDialog dialog_unboxed;
    private Gtk.FileChooserNative dialog_sandboxed;
    SList<string> filenames;
    Type type;

    public FileChooserNative (
        string                title,
        Gtk.Window            parent,
        Gtk.FileChooserAction action,
        string                accept_label,
        string                cancel_label
    ) {
        Gtk.FileFilter filter_zim = new Gtk.FileFilter ();
        filter_zim.set_name ("Zim files");
        filter_zim.add_mime_type ("application/zim");
        filter_zim.add_pattern ("*.zim");

        Gtk.FileFilter filter_any = new Gtk.FileFilter ();
        filter_any.set_name ("Any files");
        filter_any.add_pattern ("*");

        string runtime_dir = Environment.get_user_runtime_dir ();
        string doc_dir_path = Path.build_filename (runtime_dir, "doc");
        File doc_dir = File.new_for_path (doc_dir_path);

        if (doc_dir.query_exists ()) {
            info ("SANDBOXED");
            type = Type.SANDBOXED;

            dialog_sandboxed = new Gtk.FileChooserNative (
                title,
                parent,
                action,
                accept_label,
                cancel_label
            );

            dialog_sandboxed.set_select_multiple (true);
            dialog_sandboxed.add_filter (filter_zim);
            dialog_sandboxed.add_filter (filter_any);
        } else {
            info ("UNBOXED");
            type = Type.UNBOXED;

            dialog_unboxed = new Gtk.FileChooserDialog (
                title,
                parent,
                action,
                cancel_label,
                Gtk.ResponseType.CANCEL,
                accept_label,
                Gtk.ResponseType.ACCEPT
            );

            dialog_unboxed.set_select_multiple (true);
            dialog_unboxed.add_filter (filter_zim);
            dialog_unboxed.add_filter (filter_any);

            dialog_unboxed.set_default_response (Gtk.ResponseType.ACCEPT);
        }
    }

    public int run () {
        int ret;
        if (type == Type.SANDBOXED) {
            ret = dialog_sandboxed.run ();
            filenames = dialog_sandboxed.get_filenames ();
        } else {
            ret = dialog_unboxed.run ();
            filenames = dialog_unboxed.get_filenames ();
            dialog_unboxed.close ();
        }
        return ret;
    }

    public SList<string> get_filenames () {
        return (owned) filenames;
    }
}
