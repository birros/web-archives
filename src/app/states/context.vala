public class WebArchives.Context : Object {
    public enum Layer {
        APP,
        WINDOW,
        TAB
    }

    // APP
    public NightModeState night_mode_state       {get; private set;}
    public SearchRecentStore search_recent_store {get; private set;}
    public Server server                         {get; private set;}
    public TrackerService tracker                {get; private set;}
    public ArchiveStore archive_store            {get; private set;}
    public BookmarkStore bookmark_store          {get; private set;}
    public Remote remote                         {get; private set;}
    public LanguageStore language_store          {get; private set;}
    public HistoryStore history_store            {get; private set;}

    // WINDOW
    public NewTabButtonState new_tab_button_state {get; private set;}
    public PopoverMenuState popover_menu_state    {get; private set;}

    // TAB
    public AddArchiveButtonState add_archive_button_state {get; private set;}
    public TitleState title_state                         {get; private set;}
    public RouteState route_state                         {get; private set;}
    public ArchiveState archive_state                     {get; private set;}
    public WebViewState web_view_state                    {get; private set;}
    public NavigationState navigation_state               {get; private set;}
    public SearchState search_state                       {get; private set;}
    public SearchInState search_in_state                  {get; private set;}
    public BookmarkState bookmark_state                   {get; private set;}
    public PrintState print_state                         {get; private set;}
    public RandomPageState random_page_state              {get; private set;}
    public MainPageState main_page_state                  {get; private set;}

    // LOGICS
    private TitleLogic title_logic;
    private NavigationLogic navigation_logic;
    private SearchInLogic search_in_logic;
    private SearchBarLogic search_bar_logic;
    private BookmarkLogic bookmark_logic;
    private LoadUriLogic load_uri_logic;
    private RandomLogic random_logic;
    private HistoryLogic history_logic;
    private MainPageLogic main_page_logic;

    // CONSTRUCTORS
    public Context () {
        init_app ();
        init_window ();
        init_tab ();
    }

    public Context.fork (Context parent, Layer layer) {
        switch (layer) {
            case Layer.APP:
            {
                copy_app (parent);
                init_window ();
                init_tab ();
                break;
            }
            case Layer.WINDOW:
            {
                copy_app (parent);
                copy_window (parent);
                init_tab ();
                break;
            }
            case Layer.TAB:
            {
                copy_app (parent);
                copy_window (parent);
                copy_tab (parent);
                break;
            }
        }
    }

    public Context.merge (Context parent, Context target, Layer layer) {
        switch (layer) {
            case Layer.APP:
            {
                copy_app (parent);
                copy_window (target);
                copy_tab (target);
                break;
            }
            case Layer.WINDOW:
            {
                copy_app (parent);
                copy_window (parent);
                copy_tab (target);
                break;
            }
            case Layer.TAB:
            {
                copy_app (parent);
                copy_window (parent);
                copy_tab (parent);
                break;
            }
        }
    }

    // INITS
    private void copy_app (Context parent) {
        night_mode_state = parent.night_mode_state;
        search_recent_store = parent.search_recent_store;
        server = parent.server;
        archive_store = parent.archive_store;
        tracker = parent.tracker;
        bookmark_store = parent.bookmark_store;
        remote = parent.remote;
        language_store = parent.language_store;
        history_store = parent.history_store;
    }

    private void init_app () {
        night_mode_state = new NightModeState ();
        search_recent_store = new SearchRecentStore ();
        server = new Server ();
        archive_store = new ArchiveStore ();
        tracker = new TrackerService (archive_store);
        bookmark_store = new BookmarkStore ();
        remote = new Remote (archive_store);
        language_store = new LanguageStore (archive_store);
        history_store = new HistoryStore ();
    }

    private void copy_window (Context parent) {
        new_tab_button_state = parent.new_tab_button_state;
        popover_menu_state = parent.popover_menu_state;
    }

    private void init_window () {
        new_tab_button_state = new NewTabButtonState ();
        popover_menu_state = new PopoverMenuState ();
    }

    private void copy_tab (Context parent) {
        add_archive_button_state = parent.add_archive_button_state;
        title_state = parent.title_state;
        route_state = parent.route_state;
        archive_state = parent.archive_state;
        web_view_state = parent.web_view_state;
        navigation_state = parent.navigation_state;
        search_state = parent.search_state;
        search_in_state = parent.search_in_state;
        bookmark_state = parent.bookmark_state;
        print_state = parent.print_state;
        random_page_state = parent.random_page_state;
        main_page_state = parent.main_page_state;
    }

    private void init_tab () {
        add_archive_button_state = new AddArchiveButtonState ();
        title_state = new TitleState ();
        route_state = new RouteState ();
        archive_state = new ArchiveState ();
        web_view_state = new WebViewState ();
        navigation_state = new NavigationState ();
        search_state = new SearchState ();
        search_in_state = new SearchInState ();
        bookmark_state = new BookmarkState ();
        print_state = new PrintState ();
        random_page_state = new RandomPageState ();
        main_page_state = new MainPageState ();

        title_logic = new TitleLogic (this);
        navigation_logic = new NavigationLogic (this);
        search_in_logic = new SearchInLogic (this);
        search_bar_logic = new SearchBarLogic (this);
        bookmark_logic = new BookmarkLogic (this);
        load_uri_logic = new LoadUriLogic (this);
        random_logic = new RandomLogic (this);
        history_logic = new HistoryLogic (this);
        main_page_logic = new MainPageLogic (this);
    }
}
