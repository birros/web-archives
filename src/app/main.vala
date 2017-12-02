int main (string[] args) {
    Intl.bindtextdomain (
        WebArchives.Config.GETTEXT_PACKAGE, WebArchives.Config.LOCALEDIR
    );
    Intl.bind_textdomain_codeset (WebArchives.Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (WebArchives.Config.GETTEXT_PACKAGE);

    Application app = new WebArchives.Application ();
    int result = app.run (args);

    return result;
}
