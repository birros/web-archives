public class WebArchives.ArchiveRow : Gtk.ListBoxRow {
    public ArchiveItem archive;
    public signal void search ();
    public signal void bookmark ();
    public signal void history ();
    public signal void eject ();
    public signal void details ();
    public signal void download ();

    public ArchiveRow (ArchiveItem archive) {
        this.archive = archive;

        Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
        // box.margin = 6;
        set_child (box);

        Gdk.Pixbuf pixbuf;
        Gtk.Image image = new Gtk.Image.from_icon_name ("image-missing");
        try {
            pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                archive.favicon, 32, 32, true
            );
            image = new Gtk.Image.from_pixbuf (pixbuf);
        } catch (Error error) {
            warning (error.message);
        }
        image.set_margin_end (6);
        box.append (image);

        Gtk.Box text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        text_box.set_hexpand (true);
        box.append (text_box);

        Pango.AttrList attr_list = new Pango.AttrList ();
        Pango.Attribute attr = Pango.attr_scale_new (Pango.Scale.SMALL);
        attr_list.insert ((owned) attr);

        Gtk.Label title_label = new Gtk.Label (archive.title);
        title_label.set_vexpand (true);
        title_label.xalign = 0;
        title_label.set_ellipsize (Pango.EllipsizeMode.END);
        text_box.append (title_label);


        Array<string> subtitle_infos = new Array<string> ();
        subtitle_infos.append_val (archive.date);

        string language = LanguageFormater.format_language (archive.lang);
        subtitle_infos.append_val (language);

        string size = format_size (archive.size * 1000);
        subtitle_infos.append_val (size);

        Array<string> tags = TagParser.parse_tags (archive.tags);
        for (int i = 0; i < tags.length; i++) {
            string tag = tags.index (i);
            subtitle_infos.append_val (tag);
        }

        string subtitle_text = string.joinv (" ⋅ ", subtitle_infos.data);

        Gtk.Label subtitle_label = new Gtk.Label (subtitle_text);
        subtitle_label.set_vexpand (true);
        subtitle_label.xalign = 0;
        subtitle_label.set_ellipsize (Pango.EllipsizeMode.END);
        subtitle_label.get_style_context().add_class ("dim-label");
        subtitle_label.set_attributes (attr_list);
        text_box.append (subtitle_label);

        if (archive.scope == "RECENTS" || archive.scope == "LOCAL") {
            Gtk.Button search_button =
                new Gtk.Button.from_icon_name ("edit-find-symbolic");
            search_button.tooltip_text = _("Search");
            search_button.get_style_context().add_class ("image-button");
            search_button.get_style_context().add_class ("flat");
            search_button.get_style_context().add_class ("circular");
            search_button.clicked.connect (() => {
                search ();
            });
            box.append (search_button);

            Gtk.Button bookmark_button =
                new Gtk.Button.from_icon_name ("ephy-bookmarks-symbolic");
            bookmark_button.tooltip_text = _("Bookmarks");
            bookmark_button.get_style_context().add_class ("image-button");
            bookmark_button.get_style_context().add_class ("flat");
            bookmark_button.get_style_context().add_class ("circular");
            bookmark_button.clicked.connect (() => {
                bookmark ();
            });
            box.append (bookmark_button);

            Gtk.Button history_button =
                new Gtk.Button.from_icon_name (
                    "elementary-document-open-recent-symbolic"
                );
            history_button.tooltip_text = _("History");
            history_button.get_style_context().add_class ("image-button");
            history_button.get_style_context().add_class ("flat");
            history_button.get_style_context().add_class ("circular");
            history_button.clicked.connect (() => {
                history ();
            });
            box.append (history_button);
        }

        if (archive.scope == "REMOTE") {
            Gtk.Button download_button =
                new Gtk.Button.from_icon_name ("document-save-symbolic");
            download_button.tooltip_text = _("Download");
            download_button.get_style_context().add_class ("image-button");
            download_button.get_style_context().add_class ("flat");
            download_button.get_style_context().add_class ("circular");
            download_button.clicked.connect (() => {
                download ();
            });
            box.append (download_button);
        }

        Gtk.MenuButton more_button = new Gtk.MenuButton ();
        more_button.set_icon_name ("view-more-symbolic");
        more_button.get_style_context().add_class ("image-button");
        more_button.get_style_context().add_class ("flat");
        more_button.get_style_context().add_class ("circular");
        box.append (more_button);

        Gtk.Popover popover = new Gtk.Popover ();
        more_button.set_popover (popover);

        Gtk.Box popover_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        // popover_box.margin = 10;
        popover.set_child (popover_box);

        Gtk.Button details_button = new Gtk.Button.with_label (_("Details"));
        popover_box.append (details_button);
        details_button.clicked.connect (() => {
            details ();
        });

        if (archive.scope == "RECENTS") {
            Gtk.Button remove_button = new Gtk.Button.with_label (_("Remove"));
            popover_box.append (remove_button);
            remove_button.clicked.connect (() => {
                eject ();
            });
        }
    }
}

