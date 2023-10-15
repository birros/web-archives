public class WebArchives.ArticleSearcher : Object {
    private const uint SEARCH_LIMIT = 100;
    private WebArchives.ZimReader reader;

    public ArticleSearcher (ArchiveItem archive) {
        reader = null;
        try {
            Zim.Archive zim_archive = new Zim.Archive (archive.path);
            reader = new WebArchives.ZimReader (zim_archive);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public SearchResultModel search_text (string text) {
        SearchResultModel model = new SearchResultModel ();
        if (reader == null) {
            return model;
        }

        List<Suggestion> suggestions = reader.search_suggestions (text, SEARCH_LIMIT);
        suggestions.foreach ((suggestion) => {
            SearchResultItem item = new SearchResultItem (
                suggestion.title, suggestion.path
            );
            model.append (item);
        });

        return model;
    }
}
