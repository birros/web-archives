public class WebArchives.DetailsView : Gtk.Box {
    private Context context;
    private Gtk.Box box;

    public DetailsView (Context context) {
        this.context = context;
        set_homogeneous (true);

        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (
            null, null
        );
        add (scrolled_window);

        Hdy.Column max_width_bin = new Hdy.Column ();
        max_width_bin.set_maximum_width (500);
        scrolled_window.add (max_width_bin);

        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        box.margin = 6;
        max_width_bin.add (box);

        context.archive_state.notify["archive"].connect (on_archive);
    }

    private void show_text (string label, string content) {
        Gtk.Box subbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.add (subbox);

        Gtk.Label label_widget = create_label (label);
        subbox.add (label_widget);

        Gtk.Label title_value = new Gtk.Label (content);
        title_value.selectable = true;
        title_value.ellipsize = Pango.EllipsizeMode.MIDDLE;
        title_value.halign = Gtk.Align.START;
        title_value.get_style_context().add_class ("dim-label");
        subbox.add (title_value);
    }

    private void show_link (string label, string link, string content) {
        Gtk.Box subbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.add (subbox);

        Gtk.Label label_widget = create_label (label);
        subbox.add (label_widget);

        Gtk.Label title_value = new Gtk.Label (
            "<a href=\"" + link + "\">" + content + "</a>"
        );
        title_value.use_markup = true;
        title_value.wrap = true;
        title_value.wrap_mode = Pango.WrapMode.CHAR;
        title_value.selectable = true;
        title_value.halign = Gtk.Align.START;
        title_value.get_style_context().add_class ("dim-label");
        subbox.add (title_value);
    }

    private void show_image (string label, string image_path) {
        Gtk.Box subbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.add (subbox);

        Gtk.Label label_widget = create_label (label);
        subbox.add (label_widget);

        Gtk.Image image = new Gtk.Image.from_icon_name (
            "image-missing", Gtk.IconSize.DND
        );
        try {
            Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                image_path, 48, 48, true
            );
            image = new Gtk.Image.from_pixbuf (pixbuf);
        } catch (Error error) {
            warning ("%s\n", error.message);
        }
        image.halign = Gtk.Align.START;
        image.show ();
        subbox.add (image);
    }

    private Gtk.Label create_label (string label) {
        Pango.AttrList attr_list = new Pango.AttrList();
        Pango.Attribute attr = Pango.attr_weight_new (Pango.Weight.BOLD);
        attr_list.insert ((owned) attr);

        Gtk.Label label_widget = new Gtk.Label (label);
        label_widget.ellipsize = Pango.EllipsizeMode.MIDDLE;
        label_widget.halign = Gtk.Align.START;
        label_widget.set_attributes (attr_list);
        return label_widget;
    }

    private void on_archive () {
        if (context.archive_state.archive == null) {
            return;
        }

        ArchiveItem archive = context.archive_state.archive;

        box.forall ((element) => box.remove (element));

        string folder_uri = "";
        string folder_path = "";
        if (archive.path != "") {
            File archive_file = File.new_for_path (archive.path);
            File parent = archive_file.get_parent ();
            folder_uri = parent.get_uri ();
            folder_path = parent.get_path ();
        }

        show_image (_("Favicon"), archive.favicon);
        show_text (_("Title"), archive.title);
        if (folder_uri != "" && folder_path != "") {
            show_link (_("Location"), folder_uri, folder_path);
        }
        show_text (_("Date"), archive.date);
        show_text (_("Lang"), archive.lang);
        string size = format_size (archive.size * 1000);
        show_text (_("Size"), size);
        show_text (_("Name"), archive.name);
        show_text (_("Id"), archive.uuid);
        show_text (_("Description"), archive.description);
        show_text (_("Article count"), archive.article_count.to_string ());
        show_text (_("Media count"), archive.media_count.to_string ());
        show_text (_("Creator"), archive.creator);
        show_text (_("Publisher"), archive.publisher);

        Array<string> tags = TagParser.parse_tags (archive.tags);
        string tags_text = string.joinv (" ⋅ ", tags.data);
        show_text (_("Tags"), tags_text);

        show_text (_("Url"), archive.url.to_string ());

        show_all ();
    }
}
