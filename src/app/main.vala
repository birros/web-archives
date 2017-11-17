private extern const string GETTEXT_PACKAGE;
private extern const string LOCALEDIR;

int main (string[] args) {
    Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
    Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (GETTEXT_PACKAGE);

    Application app = new WebArchives.Application ();
    int result = app.run (args);

    return result;
}
