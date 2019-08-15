class WebArchives.WebView : Gtk.Overlay {
    private Context context;
    private Gtk.Revealer revealer;
    private NotificationBar notification_bar;
    private WebKit.WebView web_view;
    private ArchiveItem archive;
    private WebKit.UserContentManager user_content_manager;
    private WebKit.FindController find_controller;

    /**
     *  FIXME:
     *  The RATIO constant is set to 1.25 until the WebKit defined value is
     *  found.
     */
    private const string JAVASCRIPT = """
    var key = "%s";
    var RATIO = 1.25;
    var PAGE_SIZE = window.innerHeight/RATIO;
    var scroll = document.body.scrollTop;
    switch (key)
    {
        case "down":
        {
            scroll += 40;
            break;
        }
        case "up":
        {
            scroll -= 40;
            break;
        }
        case "page-down":
        {
            scroll += PAGE_SIZE;
            break;
        }
        case "page-up":
        {
            scroll -= PAGE_SIZE;
            break;
        }
    }
    document.body.scrollTop = scroll;
    """;
    /**
     * The backaground-color value depends on config passed to
     * createOrUpdateDynamicTheme in the script.
     */
    private const string DARKREADER_CSS = """
    html {
        background-color: #212127;
    }
    """;

    public WebView (Context context) {
        this.context = context;

        // notification_bar
        revealer = new Gtk.Revealer ();
        revealer.valign = Gtk.Align.START;
        add_overlay (revealer);

        Hdy.Column notification_bar_max = new Hdy.Column ();
        notification_bar_max.set_maximum_width (500);
        revealer.add (notification_bar_max);

        notification_bar = new NotificationBar ("");
        notification_bar.close.connect (() => {
            revealer.reveal_child = false;
        });
        notification_bar_max.add (notification_bar);

        show_all ();
        
        // ...
        context.archive_state.notify["archive"].connect (on_archive);

        context.web_view_state.go_home.connect (on_go_home);
        context.web_view_state.go_back.connect (on_go_back);
        context.web_view_state.go_forward.connect (on_go_forward);
        context.web_view_state.load_uri.connect (on_load_uri);
        context.web_view_state.zoom_out.connect (on_zoom_out);
        context.web_view_state.zoom_in.connect (on_zoom_in);
        context.web_view_state.zoom_reset.connect (on_zoom_reset);

        context.night_mode_state.notify["active"].connect (on_night_mode);

        context.search_in_state.key.connect (on_search_in_key);
        context.search_in_state.notify["text"].connect (on_search_in_text);
        context.search_in_state.previous.connect (on_search_in_previous);
        context.search_in_state.next.connect (on_search_in_next);

        context.print_state.print.connect (on_print);

        /**
         * FIXME : A bug that occurs during the initialization of the
         * WebExtension requires to immediately create and delete a WebView in
         * order to fix it.
         */
        create_web_view ();
        remove (web_view);
        destroy_web_view ();
    }

    private void on_print () {
        WebKit.PrintOperation foo = new WebKit.PrintOperation (web_view);
        Gtk.Window win = (Gtk.Window) web_view.get_toplevel ();
        if (win.is_toplevel ()) {
            foo.run_dialog (win);
        }
    }

    private void on_search_in_previous () {
        find_controller.search_previous ();
    }

    private void on_search_in_next () {
        find_controller.search_next ();
    }

    private void on_search_in_text () {
        if (context.search_in_state.text == "") {
            find_controller.search_finish ();
        } else {
            find_controller.search (
                context.search_in_state.text,
                WebKit.FindOptions.WRAP_AROUND |
                WebKit.FindOptions.CASE_INSENSITIVE,
                9999
            );
        }
    }

    private void on_search_in_key (SearchInState.Key key) {
        switch (key) {
            case SearchInState.Key.UP:
            {
                web_view.run_javascript.begin (
                    JAVASCRIPT.printf ("up"), null
                );
                break;
            }
            case SearchInState.Key.DOWN:
            {
                web_view.run_javascript.begin (
                    JAVASCRIPT.printf ("down"), null
                );
                break;
            }
            case SearchInState.Key.PAGE_UP:
            {
                web_view.run_javascript.begin (
                    JAVASCRIPT.printf ("page-up"), null
                );
                break;
            }
            case SearchInState.Key.PAGE_DOWN:
            {
                web_view.run_javascript.begin (
                    JAVASCRIPT.printf ("page-down"), null
                );
                break;
            }
        }
    }

    private void on_night_mode () {
        if (user_content_manager == null) {
            return;
        }

        inject_darkreader_css ();
        inject_darkreader_js ();

        if (context.night_mode_state.active) {
            web_view.run_javascript.begin (
                """
                setTimeout (function() {
                    darkreader.enable();
                }, 1);
                """, null
            );
        } else {
            web_view.run_javascript.begin (
                """
                setTimeout (function() {
                    darkreader.disable();
                }, 1);
                """, null
            );
        }
    }

    private void inject_darkreader_css () {
        string style_content = "";
        if (context.night_mode_state.active) {
            style_content = DARKREADER_CSS;
        }

        WebKit.UserStyleSheet style = new WebKit.UserStyleSheet (
            style_content,
            WebKit.UserContentInjectedFrames.ALL_FRAMES,
            WebKit.UserStyleLevel.USER,
            null,
            null
        );
        user_content_manager.remove_all_style_sheets ();
        user_content_manager.add_style_sheet (style);
    }

    private void inject_darkreader_js () {
        string default_str = "";
        if (context.night_mode_state.active) {
            default_str = """
            const darkreader_default = true;
            """;
        } else {
            default_str = """
            const darkreader_default = false;
            """;
        }


        File darkreader_file = File.new_for_uri (
            "resource:///com/github/birros/WebArchives/js/darkreader.js"
        );
        uint8[] darkreader_data;
        try {
            darkreader_file.load_contents(null, out darkreader_data, null);
        } catch (Error e) {
            warning (e.message);
        }
        string darkreader_str = (string) darkreader_data;

        WebKit.UserScript script = new WebKit.UserScript (
            default_str + darkreader_str,
            WebKit.UserContentInjectedFrames.ALL_FRAMES,
            WebKit.UserScriptInjectionTime.START,
            null,
            null
        );
        user_content_manager.remove_all_scripts ();
        user_content_manager.add_script (script);
    }

    private void on_zoom_level () {
        context.web_view_state.zoom_level = web_view.zoom_level;
        if (web_view.zoom_level <= 0.5) {
            context.web_view_state.can_zoom_out = false;
        } else {
            context.web_view_state.can_zoom_out = true;
        }

        if (web_view.zoom_level >= 4.0) {
            context.web_view_state.can_zoom_in = false;
        } else {
            context.web_view_state.can_zoom_in = true;
        }

        if (web_view.zoom_level == 1.0) {
            context.web_view_state.can_zoom_reset = false;
        } else {
            context.web_view_state.can_zoom_reset = true;
        }
    }

    private void on_zoom_reset () {
        web_view.zoom_level = 1.0;
    }

    private void on_zoom_out () {
        if (web_view.zoom_level > 2.0) {
            web_view.zoom_level -= 1.0;
        } else if (web_view.zoom_level > 0.5) {
            web_view.zoom_level -= 0.25;
        }
    }

    private void on_zoom_in () {
        if (web_view.zoom_level < 2.0) {
            web_view.zoom_level += 0.25;
        } else if (web_view.zoom_level < 4.0) {
            web_view.zoom_level += 1.0;
        }
    }

    private void on_load_uri (string uri) {
        web_view.load_uri (
            context.server.url +
            context.archive_state.archive.uuid +
            uri
        );
    }

    private void create_web_view () {
        user_content_manager = new WebKit.UserContentManager ();
        web_view = new WebKit.WebView.with_user_content_manager (
            user_content_manager
        );

        find_controller = web_view.get_find_controller ();

        WebKit.WebContext web_view_context = web_view.get_context ();
        web_view_context.initialize_web_extensions.connect (
            on_initialize_web_extensions
        );
        web_view_context.download_started.connect(on_download_started);

        web_view_context.set_cache_model (WebKit.CacheModel.DOCUMENT_BROWSER);

        web_view.load_changed.connect (on_load_changed);
        web_view.decide_policy.connect (on_decide_policy);
        web_view.zoom_level = context.web_view_state.zoom_level;
        web_view.notify["zoom-level"].connect (on_zoom_level);
        on_zoom_level ();
        add (web_view);

        show_all ();
    }

    ~WebView () {
        info ("destroy");
        destroy_web_view ();
    }

    private void destroy_web_view () {
        find_controller = null;
        user_content_manager = null;
        web_view = null;
        context.web_view_state.url = "";

        if (archive != null) {
            context.server.remove_archive (archive);
            archive = null;
        }
    }

    private void on_archive () {
        if (web_view != null) {
            remove (web_view);
            destroy_web_view ();
        }
        if (
            context.archive_state.archive != null &&
            context.archive_state.archive.path != ""
        ) {
            archive = context.archive_state.archive;
            context.server.add_archive (archive);

            create_web_view ();
            web_view.load_uri (
                context.server.url +
                context.archive_state.archive.uuid +
                "/"
            );
            context.web_view_state.title =
                context.archive_state.archive.title;
            on_night_mode ();
        }
    }

    private void on_download_started(WebKit.Download download) {
        download.decide_destination.connect ((suggested_filename) => {
            return on_decide_destination(suggested_filename, download);
        });
        download.finished.connect (() => {
            File file = File.new_for_uri(download.destination);
            string filename = file.get_basename();

            string text = _("File downloaded: %s").printf (filename);
            notification_bar.set_text(text);
            revealer.reveal_child = true;
        });
    }

    private bool on_decide_destination (
        string          suggested_filename,
        WebKit.Download download
    ) {
        string download_dir = Environment.get_user_special_dir(
            UserDirectory.DOWNLOAD
        );

        int count = 0;
        File download_file = null;
        do {
            string filename = PathUtils.build_destination(
                suggested_filename, count
            );
            string path = Path.build_filename (download_dir, filename);
            download_file = File.new_for_path (path);
            count++;
        } while(download_file.query_exists ());

        string destination = download_file.get_uri();
        download.set_destination(destination);

        return false;
    }

    private void on_load_changed (WebKit.LoadEvent load_event) {
        switch (load_event) {
            case WebKit.LoadEvent.FINISHED:
            {
                string url = web_view.uri.substring (
                    context.server.url.length +
                    context.archive_state.archive.uuid.length
                );

                revealer.reveal_child = false;
                on_night_mode ();
                context.web_view_state.title = web_view.title;
                context.web_view_state.url = url;
                context.web_view_state.can_go_back =
                    web_view.can_go_back ();
                context.web_view_state.can_go_forward =
                    web_view.can_go_forward ();
                break;
            }
        }
    }

    private bool on_decide_policy (
        WebKit.PolicyDecision     decision,
        WebKit.PolicyDecisionType type
    ) {
        switch (type) {
            case WebKit.PolicyDecisionType.NAVIGATION_ACTION:
            {
                info ("policy decision navigation");
                WebKit.NavigationPolicyDecision navigation_decision =
                    (WebKit.NavigationPolicyDecision) decision;
                decide_navigation (navigation_decision);
                break;
            }
            case WebKit.PolicyDecisionType.NEW_WINDOW_ACTION:
            {
                info ("policy decision new_window");
                break;
            }
            case WebKit.PolicyDecisionType.RESPONSE:
            {
                info ("policy decision response");
                WebKit.ResponsePolicyDecision response_decision =
                    (WebKit.ResponsePolicyDecision) decision;

                if (!response_decision.is_mime_type_supported ()) {
                    decision.download();
                }
                break;
            }
            default:
            {
                decision.ignore ();
                break;
            }
        }
        return true;
    }

    private void decide_navigation (WebKit.NavigationPolicyDecision decision) {
        WebKit.NavigationAction action = decision.get_navigation_action ();
        WebKit.URIRequest request = action.get_request ();
        string uri = request.get_uri ();

        string prefix = context.server.url;
        if (uri.has_prefix (prefix)) {
            decision.use();
        } else {
            decision.ignore();
            context.web_view_state.open_external (uri);
        }
    }

    private void on_go_home () {
        WebKit.BackForwardList list = web_view.get_back_forward_list ();
        List<weak WebKit.BackForwardListItem> back_list = list.get_back_list ();

        uint length = back_list.length ();
        int index = -1 * (int) length;

        WebKit.BackForwardListItem first_page = list.get_nth_item (index);
        web_view.go_to_back_forward_list_item (first_page);
    }

    private void on_go_back () {
        web_view.go_back ();
    }

    private void on_go_forward () {
        web_view.go_forward ();
    }

    private void on_initialize_web_extensions (
        WebKit.WebContext web_view_context
    ) {
        info ("on_initialize_web_extensions");
        Variant prefix = new Variant.string (context.server.url);
        web_view_context.set_web_extensions_directory (
            WebArchives.Config.WEB_EXTENSIONS_DIRECTORY
        );
        web_view_context.set_web_extensions_initialization_user_data (prefix);
    }
}
