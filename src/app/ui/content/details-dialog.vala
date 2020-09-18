public class WebArchives.DetailsDialog : Gtk.Dialog {
    private Gtk.Grid grid;

    public DetailsDialog (ArchiveItem archive) {
        GLib.Object (
            use_header_bar: 1
        );

        Gtk.HeaderBar header_bar = (Gtk.HeaderBar) get_header_bar ();
        header_bar.show_close_button = true;
        header_bar.title = _("Details");
        header_bar.subtitle = archive.title;

        Gtk.Box content_area = get_content_area ();
        content_area.set_homogeneous (true);

        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (
            null, null
        );
        content_area.add (scrolled_window);

        Hdy.Clamp max_width_bin = new Hdy.Clamp ();
        max_width_bin.set_maximum_size (900);
        scrolled_window.add (max_width_bin);

        grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.column_homogeneous = true;
        grid.margin_top = 12;
        grid.margin_bottom = 12;
        grid.column_spacing = 24;
        grid.row_spacing = 12;
        max_width_bin.add (grid);

        show_infos (archive);
    }

    private void show_text (string label, string content) {
        Gtk.Label label_widget = create_label (label);
        grid.add (label_widget);

        Gtk.Label title_value = new Gtk.Label (content);
        title_value.wrap = true;
        title_value.wrap_mode = Pango.WrapMode.WORD_CHAR;
        title_value.justify = Gtk.Justification.LEFT;
        title_value.xalign = 0.0f;
        title_value.halign = Gtk.Align.START;
        grid.attach_next_to (
            title_value, label_widget, Gtk.PositionType.RIGHT, 2, 1
        );
    }

    private void show_link (string label, string link, string content) {
        Gtk.Label label_widget = create_label (label);
        grid.add (label_widget);

        Gtk.Label title_value = new Gtk.Label (
            "<a href=\"" + link + "\">" + content + "</a>"
        );
        title_value.use_markup = true;
        title_value.wrap = true;
        title_value.wrap_mode = Pango.WrapMode.WORD_CHAR;
        title_value.justify = Gtk.Justification.LEFT;
        title_value.xalign = 0.0f;
        title_value.halign = Gtk.Align.START;
        grid.attach_next_to (
            title_value, label_widget, Gtk.PositionType.RIGHT, 2, 1
        );
    }

    private void show_image (string label, string image_path) {
        Gtk.Label label_widget = create_label (label);
        grid.add (label_widget);

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
        grid.attach_next_to (image, label_widget, Gtk.PositionType.RIGHT, 2, 1);
    }

    private Gtk.Label create_label (string label) {
        Gtk.Label label_widget = new Gtk.Label (label);
        label_widget.wrap = true;
        label_widget.wrap_mode = Pango.WrapMode.WORD_CHAR;
        label_widget.justify = Gtk.Justification.RIGHT;
        label_widget.xalign = 1.0f;
        label_widget.halign = Gtk.Align.END;
        label_widget.get_style_context().add_class ("dim-label");
        return label_widget;
    }

    private void show_infos (ArchiveItem archive) {
        string folder_uri = "";
        string folder_path = "";
        if (archive.path != "") {
            File archive_file = File.new_for_path (archive.path);
            File parent = archive_file.get_parent ();
            folder_uri = parent.get_uri ();
            folder_path = parent.get_path ();
        }

        string language = LanguageFormater.format_language (archive.lang);
        string size = format_size (archive.size * 1000);

        Array<string> tags = TagParser.parse_tags (archive.tags);
        string tags_text = string.joinv (" ⋅ ", tags.data);


        show_image (_("Favicon"), archive.favicon);
        show_text (_("Title"), archive.title);
        if (folder_uri != "" && folder_path != "") {
            show_link (_("Location"), folder_uri, folder_path);
        }
        show_text (_("Date"), archive.date);
        show_text (_("Lang"), language);
        show_text (_("Size"), size);
        show_text (_("Name"), archive.name);
        show_text (_("Id"), archive.uuid);
        show_text (_("Description"), archive.description);
        show_text (_("Article count"), archive.article_count.to_string ());
        show_text (_("Media count"), archive.media_count.to_string ());
        show_text (_("Creator"), archive.creator);
        show_text (_("Publisher"), archive.publisher);
        if (tags.length > 0) {
            show_text (_("Tags"), tags_text);
        }
    }
}
