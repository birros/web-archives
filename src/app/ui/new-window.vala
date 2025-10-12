public class WebArchives.NewWindow : Adw.Window {
    private Adw.TabView view;
    private Adw.TabOverview tab_overview;
    private Adw.ToolbarView toolbar_view;
    private Adw.TabBar tab_bar;
    private Gtk.Button overview_btn;
    private Gtk.Button new_tab_btn;
    private Adw.TabButton narrow_overview_btn;

    private Context context;

    public NewWindow (Adw.Application app, Context context) {
        Object (
            application: app,
            title: _("Web Archives"),
            default_width: 800,
            default_height: 600
        );

        this.context = context;
        view = new Adw.TabView ();
        // view.create_window.connect (create_window); TODO: Some unowned/owned mess that i'll have to deal with later

        var header = new Adw.HeaderBar (); // TODO: Reuse header-bar.vala, ... or just rewrite it

        var new_window_btn = new Gtk.Button.from_icon_name ("window-new-symbolic");
        new_window_btn.tooltip_text = _("New Window");
        header.pack_start (new_window_btn);

        narrow_overview_btn = new Adw.TabButton ();
        narrow_overview_btn.view = view;
        narrow_overview_btn.action_name = "overview.open";
        narrow_overview_btn.visible = false;
        header.pack_end (narrow_overview_btn);

        overview_btn = new Gtk.Button.from_icon_name ("view-grid-symbolic");
        overview_btn.tooltip_text = _("View Open Tabs");
        overview_btn.action_name = "overview.open";
        header.pack_end (overview_btn);

        new_tab_btn = new Gtk.Button.from_icon_name ("tab-new-symbolic");
        new_tab_btn.tooltip_text = _("New Tab");
        new_tab_btn.clicked.connect (() => {add_tab ();});

        header.pack_end (new_tab_btn);

        tab_bar = new Adw.TabBar ();
        tab_bar.view = view;

        toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (header);
        toolbar_view.add_top_bar (tab_bar);
        toolbar_view.content = view;

        tab_overview = new Adw.TabOverview ();
        tab_overview.view = view;
        tab_overview.enable_new_tab = false; // TODO: Some unowned/owned mess that i'll have to deal with later
        // tab_overview.create_tab.connect (on_overview_new_tab);

        tab_overview.child = toolbar_view;
        this.set_content (tab_overview);

        var bp = new Adw.Breakpoint (Adw.BreakpointCondition.parse ("max-width: 500sp"));
        bp.add_setter (narrow_overview_btn, "visible", true);
        bp.add_setter (overview_btn, "visible", false);
        bp.add_setter (new_tab_btn, "visible", false);
        bp.add_setter (tab_bar, "visible", false);
        this.add_breakpoint (bp);

        add_tab ();
    }

    private Adw.TabPage add_tab () {
        Context tab_context = new Context.fork (context, Context.Layer.WINDOW);
        Content content = new Content(tab_context);

        var page = view.append (content);
        page.title = "Tab";

        view.set_selected_page (page);

        return page;
    }

}

