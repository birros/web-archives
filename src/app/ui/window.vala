public class WebArchives.Window : Gtk.ApplicationWindow {
    private Context context;
    private Gtk.Notebook notebook;
    private HeaderBar header_bar;

    private ulong external_callback;
    private ulong add_archive_callback;

    private const GLib.ActionEntry[] action_entries = {
        { "new-tab",            new_tab            },
        { "close-tab",          close_tab          },
        { "new-window",         new_window         },
        { "tab-next",           tab_next           },
        { "tab-previous",       tab_previous       },
        { "search",             search             },
        { "go-back",            go_back            },
        { "go-forward",         go_forward         },
        { "tab-one",            tab_one            },
        { "tab-two",            tab_two            },
        { "tab-three",          tab_three          },
        { "tab-four",           tab_four           },
        { "tab-five",           tab_five           },
        { "tab-six",            tab_six            },
        { "tab-seven",          tab_seven          },
        { "tab-eight",          tab_eight          },
        { "tab-nine",           tab_nine           },
        { "tab-zero",           tab_zero           },
        { "open-archive",       open_archive       },
        { "night-mode",         night_mode         },
        { "zoom-in",            zoom_in            },
        { "zoom-out",           zoom_out           },
        { "zoom-reset",         zoom_reset         },
        { "search-in",          search_in          },
        { "search-in-next",     search_in_next     },
        { "search-in-previous", search_in_previous },
        { "bookmark",           bookmark           },
        { "bookmark-toggle",    bookmark_toggle    },
        { "print",              print              },
        { "random",             random             },
        { "history",            history            },
        { "main-page",          main_page          }
    };

    public Window (
        Gtk.Application application,
        Context         context,
        Gtk.Widget?     label = null,
        Gtk.Widget?     page = null
    ) {
        GLib.Object (
            application: application
        );

        this.context = context;

        set_default_size (900, 600);

        header_bar = new HeaderBar ();
        header_bar.set_context (context);
        set_titlebar (header_bar);

        notebook = new Notebook ();
        notebook.switch_page.connect (on_notebook_switch_page);
        notebook.page_removed.connect (on_notebook_page_removed);
        notebook.create_window.connect (on_notebook_create_window);
        add (notebook);

        add_tab (label, page);

        add_action_entries (action_entries, this);
        application.set_accels_for_action ("win.new-tab", {"<Primary>t"});
        application.set_accels_for_action ("win.close-tab", {"<Primary>w"});
        application.set_accels_for_action ("win.new-window", {"<Primary>n"});
        application.set_accels_for_action ("win.tab-next",
            {"<Primary>Page_Down", "<Primary>KP_3", "<Primary>Tab"}
        );
        application.set_accels_for_action ("win.tab-previous",
            {"<Primary>Page_Up", "<Primary>KP_9", "<Primary><shift>Tab"}
        );
        application.set_accels_for_action ("win.search", {"<Primary>l"});
        application.set_accels_for_action ("win.go-back", {"<Alt>Left"});
        application.set_accels_for_action ("win.go-forward", {"<Alt>Right"});
        application.set_accels_for_action ("win.tab-one", {"<Alt>1"});
        application.set_accels_for_action ("win.tab-two", {"<Alt>2"});
        application.set_accels_for_action ("win.tab-three", {"<Alt>3"});
        application.set_accels_for_action ("win.tab-four", {"<Alt>4"});
        application.set_accels_for_action ("win.tab-five", {"<Alt>5"});
        application.set_accels_for_action ("win.tab-six", {"<Alt>6"});
        application.set_accels_for_action ("win.tab-seven", {"<Alt>7"});
        application.set_accels_for_action ("win.tab-eight", {"<Alt>8"});
        application.set_accels_for_action ("win.tab-nine", {"<Alt>9"});
        application.set_accels_for_action ("win.tab-zero", {"<Alt>0"});
        application.set_accels_for_action ("win.open-archive", {"<Primary>o"});
        application.set_accels_for_action ("win.night-mode", {"<Primary>i"});
        application.set_accels_for_action ("win.zoom-in",
            {"<Primary>plus", "<Primary>KP_Add", "<Primary>equal", "ZoomIn"}
        );
        application.set_accels_for_action ("win.zoom-out",
            {"<Primary>minus", "<Primary>KP_Subtract", "ZoomOut"}
        );
        application.set_accels_for_action ("win.zoom-reset",
            {"<Primary>0", "<Primary>KP_0"}
        );
        application.set_accels_for_action ("win.search-in", {"<Primary>f"});
        application.set_accels_for_action ("win.search-in-previous",
            {"<Primary><shift>g"}
        );
        application.set_accels_for_action ("win.search-in-next",
            {"<Primary>g"}
        );
        application.set_accels_for_action ("win.bookmark",
            {"<Primary><shift>o"}
        );
        application.set_accels_for_action ("win.bookmark-toggle",
            {"<Primary>d"}
        );
        application.set_accels_for_action ("win.print", {"<Primary>p"});
        application.set_accels_for_action ("win.random", {"<Primary>r"});
        application.set_accels_for_action ("win.main-page", {"<Primary>m"});
        application.set_accels_for_action ("win.history", {"<Primary>h"});
        application.set_accels_for_action ("win.show-help-overlay",
            {"<Primary>question"}
        );

        show_all ();

        context.new_tab_button_state.clicked.connect (new_tab);
        context.popover_menu_state.new_window.connect (new_window);
    }

    private void zoom_in () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.web_view_state.zoom_in ();
        }
    }

    private void zoom_out () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.web_view_state.zoom_out ();
        }
    }

    private void zoom_reset () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.web_view_state.zoom_reset ();
        }
    }

    private void night_mode () {
        context.night_mode_state.active = !context.night_mode_state.active;
    }

    private void open_archive () {
        if (context.route_state.route == RouteState.Route.HOME) {
            on_add_archive ();
        }
    }

    private void tab_one () {
        notebook.set_current_page (0);
    }

    private void tab_two () {
        notebook.set_current_page (1);
    }

    private void tab_three () {
        notebook.set_current_page (2);
    }

    private void tab_four () {
        notebook.set_current_page (3);
    }

    private void tab_five () {
        notebook.set_current_page (4);
    }

    private void tab_six () {
        notebook.set_current_page (5);
    }

    private void tab_seven () {
        notebook.set_current_page (6);
    }

    private void tab_eight () {
        notebook.set_current_page (7);
    }

    private void tab_nine () {
        notebook.set_current_page (8);
    }

    private void tab_zero () {
        notebook.set_current_page (9);
    }

    private void go_back () {
        context.navigation_state.go_back ();
    }

    private void go_forward () {
        context.navigation_state.go_forward ();
    }

    private void search () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.route_state.route = RouteState.Route.SEARCH;
        }
    }

    private void bookmark () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.route_state.route = RouteState.Route.BOOKMARK;
        }
    }

    private void bookmark_toggle () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.bookmark_state.toggle ();
        }
    }

    private void history () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.route_state.route = RouteState.Route.HISTORY;
        }
    }

    private void print () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.print_state.print ();
        }
    }

    private void random () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.random_page_state.random ();
        }
    }

    private void main_page () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.main_page_state.main_page ();
        }
    }

    private void search_in () {
        if (context.route_state.route == RouteState.Route.WEB) {
            context.route_state.route = RouteState.Route.SEARCHIN;
        } else if (context.route_state.route == RouteState.Route.SEARCHIN) {
            context.search_in_state.focus ();
        }
    }

    private void search_in_previous () {
        if (context.route_state.route == RouteState.Route.SEARCHIN) {
            context.search_in_state.previous ();
        }
    }

    private void search_in_next () {
        if (context.route_state.route == RouteState.Route.SEARCHIN) {
            context.search_in_state.next ();
        }
    }

    private void new_tab () {
        add_tab ();
        notebook.set_current_page (notebook.get_n_pages () - 1);
    }

    private void close_tab () {
        int page_num = notebook.get_current_page ();
        notebook.remove_page (page_num);
    }

    private void new_window () {
        Context window_context = new Context.fork (context, Context.Layer.APP);
        new Window (application, window_context);
    }

    private void tab_next () {
        if (notebook.get_current_page () == notebook.get_n_pages () - 1) {
            notebook.set_current_page (0);
        } else {
            notebook.next_page ();
        }
    }

    private void tab_previous () {
        if (notebook.get_current_page () == 0) {
            notebook.set_current_page (notebook.get_n_pages () - 1);
        } else {
            notebook.prev_page ();
        }
    }

    private void add_tab (Gtk.Widget? label = null, Gtk.Widget? page = null) {
        Gtk.Widget label_new;
        Gtk.Widget page_new;

        if (label != null && page != null) {
            label_new = label;
            page_new = page;

            Content content = (Content) page;
            NotebookTabLabelWithState content_label =
                (NotebookTabLabelWithState) label;

            Context tab_context = content.get_context ();
            Context new_tab_context = new Context.merge (
                context, tab_context, Context.Layer.WINDOW
            );

            content_label.set_context (new_tab_context);
            content.set_context (new_tab_context);
        } else {
            Context tab_context = new Context.fork (
                context, Context.Layer.WINDOW
            );
            label_new = new NotebookTabLabelWithState (tab_context);
            page_new = new Content (tab_context);
        }

        notebook.append_page (page_new, label_new);
        notebook.show_all ();
    }

    private void on_notebook_switch_page (Gtk.Widget page, uint page_num) {
        info ("switch-page");
        Content content = (Content) page;
        Context tab_context = content.get_context ();
        header_bar.set_context (tab_context);
        set_context (tab_context);
    }

    private void on_notebook_page_removed (Gtk.Widget page, uint page_num) {
        info ("page-removed");
        if (notebook.get_n_pages () == 0) {
            close ();
        }
    }

    private unowned Gtk.Notebook on_notebook_create_window (
        Gtk.Widget page, int x, int y
    ) {
        info ("create-window");

        int page_num = notebook.page_num (page);
        Gtk.Widget label = notebook.get_tab_label (page);
        notebook.remove_page (page_num);

        Context window_context = new Context.fork (context, Context.Layer.APP);
        new Window (
            application, window_context, label, page
        );

        return (Gtk.Notebook) null;
    }

    private void on_add_archive () {
        /**
         * FIXME: We use temporarly a fake FileChooserNative while a bug in
         * flatpak is not fixed.
         * See src/app/ui/gtk/file-chooser-native.vala for more details.
         */
        FileChooserNative dialog = new FileChooserNative (
            _("Please choose a file"),
            this,
            Gtk.FileChooserAction.OPEN,
            "_Open",
            "_Cancel"
        );

        int response = dialog.run ();
        switch(response) {
            case(Gtk.ResponseType.ACCEPT):
            {
                SList<string> filenames = dialog.get_filenames ();
                foreach (unowned string filename in filenames) {
                    info (filename);
                    ArchiveItem archive = ArchiveUtils.archive_from_file (
                        filename
                    );
                    archive.scope = "RECENTS";
                    archive.update_timestamp ();
                    context.archive_store.add (archive);
                }

                break;
            }
            case(Gtk.ResponseType.CANCEL):
            {
                info ("Cancel clicked");
                break;
            }
            default:
            {
                info ("Unexpected button clicked");
                break;
            }
        }
    }

    public void set_context (Context context) {
        bool external_connected = SignalHandler.is_connected (
            this.context.web_view_state, external_callback
        );
        bool add_archive_connected = SignalHandler.is_connected (
            this.context.add_archive_button_state, add_archive_callback
        );

        if (external_connected) {
            this.context.web_view_state.disconnect (external_callback);
        }
        if (add_archive_connected) {
            this.context.add_archive_button_state.disconnect (
                add_archive_callback
            );
        }

        this.context = context;

        external_callback = context.web_view_state.open_external.connect (
            on_open_external
        );
        add_archive_callback =
            context.add_archive_button_state.clicked.connect (on_add_archive);
    }

    private void on_open_external (string uri) {
        Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (
            this,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.QUESTION,
            Gtk.ButtonsType.OK_CANCEL,
            """<span font_weight="bold" size="large">%s</span>""",
            _("Are you sure to open external link ?")
        );
        message_dialog.use_markup = true;
        message_dialog.secondary_text = uri;

        Gtk.Widget ok_button =
            message_dialog.get_widget_for_response (Gtk.ResponseType.OK);
        ok_button.get_style_context().add_class ("suggested-action");

        message_dialog.response.connect ((response_type) => {
            switch (response_type) {
                case Gtk.ResponseType.OK:
                {
                    try {
                        AppInfo.launch_default_for_uri (uri, null);
                    } catch (Error e) {
                        warning (e.message);
                    }
                    break;
                }
            }
            message_dialog.close ();
        });

        message_dialog.show ();
    }
}
