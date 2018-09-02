public class WebArchives.HomeView : Gtk.Overlay {
    private Context context;
    private Gtk.Revealer revealer;
    private Gtk.ListBox local_list_box;
    private Gtk.ListBox remote_list_box;
    private ComboBoxText remote_header_comboboxtext;
    private ArchiveModel remote_model;
    private ArchiveModel local_model;
    private ulong remote_model_callback;
    private const int DIRECT_DOWNLOAD = 14;
    private const int TORRENT_DOWNLOAD = 15;

    private const string TRACKER_INFO_MESSAGE = _(
"""No archive automaticly detected on your system. <b>Please download one from the following section.</b>"""
    );

    private const string TRACKER_WARNING_MESSAGE = _(
"""<span weight="bold" foreground="#f57900">It seems Tracker is not installed on your system.</span> WebArchives can't automatically list the archives present on your disk.

<b>Please install Tracker using your package manager and then restart your session.</b>

&#8226; Debian or Ubuntu:
   <tt>apt install tracker</tt>

&#8226; Fedora:
   <tt>dnf install tracker</tt>"""
   );

    public HomeView (Context context) {
        this.context = context;

        // notification_bar
        revealer = new Gtk.Revealer ();
        revealer.valign = Gtk.Align.START;
        add_overlay (revealer);

        Hdy.Column notification_bar_max = new Hdy.Column ();
        notification_bar_max.set_maximum_width (500);
        revealer.add (notification_bar_max);

        NotificationBar notification_bar = new NotificationBar (
            _("Cannot open the archive file")
        );
        notification_bar.close.connect (() => {
            revealer.reveal_child = false;
        });
        notification_bar_max.add (notification_bar);

        // archives
        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (
            null, null
        );
        add (scrolled_window);

        Hdy.Column max_width_bin = new Hdy.Column ();
        max_width_bin.set_maximum_width (500);
        max_width_bin.margin_top = 6;
        max_width_bin.margin_bottom = 6;
        max_width_bin.margin_start = 6;
        max_width_bin.margin_end = 6;
        scrolled_window.add (max_width_bin);

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        max_width_bin.add (box);

        Gtk.Box recents_header_box = new Gtk.Box (
            Gtk.Orientation.HORIZONTAL, 6
        );
        box.add (recents_header_box);

        Pango.AttrList attr_list = new Pango.AttrList ();
        Pango.Attribute attr = Pango.attr_weight_new (Pango.Weight.BOLD);
        attr_list.insert ((owned) attr);

        // RECENTS
        Gtk.Label recents_header_label = new Gtk.Label (_("Recents"));
        recents_header_label.set_attributes (attr_list);
        recents_header_label.hexpand = true;
        recents_header_label.xalign = 0;
        recents_header_box.add (recents_header_label);

        Gtk.Button recents_header_button = new Gtk.Button.from_icon_name (
            "list-add-symbolic"
        );
        recents_header_button.tooltip_text = _("Open a web archive");
        recents_header_button.relief = Gtk.ReliefStyle.NONE;
        recents_header_button.clicked.connect (() => {
            context.add_archive_button_state.clicked ();
        });
        recents_header_box.add (recents_header_button);

        Gtk.Frame recents_frame = new Gtk.Frame (null);
        recents_frame.shadow_type = Gtk.ShadowType.IN;
        box.add (recents_frame);

        Gtk.ListBox recents_list_box = new Gtk.ListBox ();
        recents_list_box.set_selection_mode (Gtk.SelectionMode.NONE);
        recents_list_box.row_activated.connect (on_row_activated);
        recents_list_box.set_header_func (update_header);
        recents_frame.add (recents_list_box);

        Gtk.Label recents_placeholder = new Gtk.Label (
            _("No archive recently opened.")
        );
        recents_placeholder.margin = 12;
        recents_placeholder.ellipsize = Pango.EllipsizeMode.END;
        recents_placeholder.show_all ();
        recents_list_box.set_placeholder (recents_placeholder);

        ArchiveModel recents_model = new ArchiveModel (
            context.archive_store, "RECENTS"
        );
        recents_model.set_sort_func (sort_by_timestamp);
        recents_list_box.bind_model (recents_model, list_box_create_row);
        recents_model.items_changed.connect (() => {
            local_model.invalidate_filter ();
            remote_model.invalidate_filter ();
            show_all ();
        });

        // LOCAL
        Gtk.Box local_header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.add (local_header_box);

        Gtk.Label local_header_label = new Gtk.Label (_("Local"));
        local_header_label.set_attributes (attr_list);
        local_header_label.hexpand = true;
        local_header_label.xalign = 0;
        local_header_box.add (local_header_label);

        StatusLabel local_last_refreshed = new StatusLabel ();
        local_last_refreshed.hexpand = true;
        local_last_refreshed.halign = Gtk.Align.END;
        local_header_box.add (local_last_refreshed);
        context.tracker.notify["timestamp"].connect (() => {
            local_last_refreshed.timestamp = context.tracker.timestamp;
        });
        local_last_refreshed.timestamp = context.tracker.timestamp;

        Gtk.Button local_header_button = new Gtk.Button.from_icon_name (
            "view-refresh-symbolic"
        );
        local_header_button.tooltip_text = _("Refresh");
        local_header_button.relief = Gtk.ReliefStyle.NONE;
        local_header_button.clicked.connect (() => {
            context.tracker.refresh ();
        });
        if (!context.tracker.enabled) {
            local_header_button.sensitive = false;
        }
        local_header_box.add (local_header_button);

        Gtk.Frame local_frame = new Gtk.Frame (null);
        local_frame.shadow_type = Gtk.ShadowType.IN;
        box.add (local_frame);

        local_list_box = new Gtk.ListBox ();
        local_list_box.set_selection_mode (Gtk.SelectionMode.NONE);
        local_list_box.row_activated.connect (on_row_activated);
        local_list_box.set_header_func (update_header);
        local_frame.add (local_list_box);

        Gtk.Label local_placeholder;
        if (context.tracker.enabled) {
            local_placeholder = new Gtk.Label (TRACKER_INFO_MESSAGE);
        } else {
            local_placeholder = new Gtk.Label (TRACKER_WARNING_MESSAGE);
            local_placeholder.selectable = true;
        }
        local_placeholder.use_markup = true;
        local_placeholder.margin = 12;
        local_placeholder.wrap = true;
        local_placeholder.show_all ();
        local_list_box.set_placeholder (local_placeholder);

        if (context.tracker.enabled) {
            local_model = new ArchiveModel (context.archive_store, "LOCAL");
            local_model.set_filter_func (local_filter);
            local_model.set_sort_func (sort_by_title);
            local_list_box.bind_model (local_model, list_box_create_row);
            local_model.items_changed.connect (() => {
                remote_model.invalidate_filter ();
                show_all ();
            });
        }

        // REMOTE
        Gtk.Box remote_header_box = new Gtk.Box (
            Gtk.Orientation.HORIZONTAL, 6
        );
        box.add (remote_header_box);

        Gtk.Label remote_header_label = new Gtk.Label (_("Remote"));
        remote_header_label.set_attributes (attr_list);
        remote_header_label.xalign = 0;
        remote_header_box.add (remote_header_label);

        LanguageModel language_model = new LanguageModel (
            context.language_store
        );
        language_model.set_sort_func (sort_by_language_formated);
        remote_header_comboboxtext = new ComboBoxText ();
        remote_header_comboboxtext.bind_model (language_model);
        remote_header_comboboxtext.relief = Gtk.ReliefStyle.NONE;
        remote_header_comboboxtext.changed.connect (() => {
	        language_changed ();
        });
        remote_header_box.add (remote_header_comboboxtext);

        StatusLabel remote_last_refreshed = new StatusLabel ();
        remote_last_refreshed.hexpand = true;
        remote_last_refreshed.halign = Gtk.Align.END;
        remote_header_box.add (remote_last_refreshed);
        context.remote.notify["timestamp"].connect (() => {
            remote_last_refreshed.timestamp = context.remote.timestamp;
        });
        context.remote.notify["downloading"].connect (() => {
            remote_last_refreshed.progress_enabled = context.remote.downloading;
        });
        context.remote.notify["progress"].connect (() => {
            remote_last_refreshed.progress = context.remote.progress;
        });
        remote_last_refreshed.timestamp = context.remote.timestamp;
        remote_last_refreshed.progress_label = _("Downloading");

        Gtk.Button remote_header_button = new Gtk.Button.from_icon_name (
            "view-refresh-symbolic"
        );
        remote_header_button.tooltip_text = _("Refresh");
        remote_header_button.relief = Gtk.ReliefStyle.NONE;
        remote_header_button.clicked.connect (() => {
            context.remote.refresh ();
        });
        remote_header_box.add (remote_header_button);

        Gtk.Frame remote_frame = new Gtk.Frame (null);
        remote_frame.shadow_type = Gtk.ShadowType.IN;
        box.add (remote_frame);

        remote_list_box = new Gtk.ListBox ();
        remote_list_box.set_selection_mode (Gtk.SelectionMode.NONE);
        remote_list_box.row_activated.connect (on_row_activated);
        remote_list_box.set_header_func (update_header);
        remote_frame.add (remote_list_box);

        Gtk.Label remote_placeholder = new Gtk.Label (
            _("No archive available for download.")
        );
        remote_placeholder.margin = 12;
        remote_placeholder.ellipsize = Pango.EllipsizeMode.END;
        remote_placeholder.show_all ();
        remote_list_box.set_placeholder (remote_placeholder);

        /**
         *  Set default language depending on locale.
         */
        string locale = Intl.get_language_names ()[0];
        string iso_639_1 = locale.split ("_")[0];
        string? iso_639_3 = LanguageFormater.iso_639_1_to_iso_639_3 (iso_639_1);
        if (iso_639_3 != null) {
            remote_header_comboboxtext.active_text = iso_639_3;
        }

        remote_model = null;
        language_changed ();

        show_all ();
    }

    private void language_changed () {
        if (remote_model != null) {
            bool remote_model_connected = SignalHandler.is_connected (
                remote_model, remote_model_callback
            );
            if (remote_model_connected) {
                remote_model.disconnect (remote_model_callback);
            }
        }

        string lang = remote_header_comboboxtext.active_text;
        remote_model = new ArchiveModel (context.archive_store, "REMOTE", lang);
        remote_model.set_filter_func (remote_filter);
        remote_model.set_sort_func (sort_by_title);

        remote_list_box.bind_model (remote_model, list_box_create_row);
        remote_model_callback = remote_model.items_changed.connect (() => {
            show_all ();
        });

        show_all ();
    }

    private bool local_filter (ArchiveItem archive) {
        bool contains = context.archive_store.contains_by_scope_and_path (
            "RECENTS", archive.path
        );
        if (contains) {
            return false;
        } else {
            return true;
        }
    }

    private bool remote_filter (ArchiveItem archive) {
        bool in_recents = context.archive_store.contains_by_scope_and_uuid (
            "RECENTS", archive.uuid
        );
        bool in_local = context.archive_store.contains_by_scope_and_uuid (
            "LOCAL", archive.uuid
        );
        if (in_recents || in_local) {
            return false;
        } else {
            return true;
        }
    }

    private int sort_by_timestamp (ArchiveItem a, ArchiveItem b) {
        if (a.timestamp > b.timestamp) {
            return -1;
        } else if (a.timestamp < b.timestamp) {
            return 1;
        } else {
            return 0;
        }
    }

    private int sort_by_title (ArchiveItem a, ArchiveItem b) {
        if (a.title.down () > b.title.down ()) {
            return 1;
        } else if (a.title.down () < b.title.down ()) {
            return -1;
        } else {
            return 0;
        }
    }

    private int sort_by_language_formated (LanguageItem a, LanguageItem b) {
        string a_language = LanguageFormater.format_language (
            a.language
        );
        string b_language = LanguageFormater.format_language (
            b.language
        );

        if (a_language.down () > b_language.down ()) {
            return 1;
        } else if (a_language.down () < b_language.down ()) {
            return -1;
        } else {
            return 0;
        }
    }

    private void update_header (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        if (before == null) {
            return;
        }

        Gtk.Separator separator;
        separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        row.set_header (separator);
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        ArchiveRow archive_row = (ArchiveRow) row;
        ArchiveItem archive = archive_row.archive;
        if (archive.scope == "RECENTS" || archive.scope == "LOCAL") {
            if (select_archive (archive)) {
                context.route_state.route = RouteState.Route.WEB;
            }
        }
    }

    private bool select_archive (ArchiveItem archive) {
        ArchiveItem archive_copy = archive;

        if (archive.scope == "LOCAL") {
            archive_copy = new ArchiveItem.copy (archive);
            archive_copy.scope = "RECENTS";
            context.archive_store.add (archive_copy);
        }
        archive_copy.update_timestamp ();

        File archive_file = File.new_for_path (archive_copy.path);
        if (archive_file.query_exists ()) {
            context.archive_state.archive = archive_copy;
            revealer.reveal_child = false;
            return true;
        } else {
            revealer.reveal_child = true;
        }
        return false;
    }

    private Gtk.Widget list_box_create_row (Object item) {
        ArchiveItem archive = (ArchiveItem) item;
        ArchiveRow row = new ArchiveRow (archive);
        row.eject.connect (() => {
            context.archive_store.remove (archive);
            if (context.archive_state.archive == archive) {
                context.archive_state.archive = null;
            }
        });
        row.bookmark.connect (() => {
            if (select_archive (archive)) {
                context.route_state.route = RouteState.Route.BOOKMARK;
            }
        });
        row.search.connect (() => {
            if (select_archive (archive)) {
                context.route_state.route = RouteState.Route.SEARCH;
            }
        });
        row.history.connect (() => {
            if (select_archive (archive)) {
                context.route_state.route = RouteState.Route.HISTORY;
            }
        });
        row.details.connect (() => {
            revealer.reveal_child = false;
            show_details (archive);
        });
        row.download.connect (() => {
            ask_for_downloading (archive);
        });
        return row;
    }

    private void show_details (ArchiveItem archive) {
        Gtk.Window win = (Gtk.Window) this.get_toplevel ();
        DetailsDialog details_dialog = new DetailsDialog (archive);
        details_dialog.modal = true;
        details_dialog.set_transient_for (win);
        details_dialog.default_width = 600;
        details_dialog.default_height = 530;
        details_dialog.show_all ();
    }

    private void ask_for_downloading (ArchiveItem archive) {
        Gtk.Window win = (Gtk.Window) this.get_toplevel ();
        string espaced_title = Markup.escape_text (archive.title);

        Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (
            win,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.QUESTION,
            Gtk.ButtonsType.CANCEL,
            """<span font_weight="bold" size="large">%s</span>""",
            _("How would you like to download %s ?").printf (espaced_title)
        );
        message_dialog.use_markup = true;
        message_dialog.secondary_text =
        _("This will open a third-party application to download the archive.");

        message_dialog.add_button (_("From a server"), DIRECT_DOWNLOAD);
        message_dialog.add_button (_("Peer-to-peer network"), TORRENT_DOWNLOAD);
        Gtk.Widget torrent_button =
            message_dialog.get_widget_for_response (TORRENT_DOWNLOAD);
        torrent_button.get_style_context().add_class ("suggested-action");

        message_dialog.response.connect ((response_type) => {
            switch (response_type) {
                case DIRECT_DOWNLOAD:
                {
                    ArchiveDownloader.download (
                        archive.url, ArchiveDownloader.Type.DIRECT
                    );
                    break;
                }
                case TORRENT_DOWNLOAD:
                {
                    ArchiveDownloader.download (
                        archive.url, ArchiveDownloader.Type.TORRENT
                    );
                    break;
                }
            }
            message_dialog.close ();
        });

        message_dialog.show ();
    }
}
