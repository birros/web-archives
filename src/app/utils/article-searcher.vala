public class WebArchives.ArticleSearcher : Object {
    private const uint SEARCH_LIMIT = 100;
    private Kiwix.Reader reader;

    public ArticleSearcher (ArchiveItem archive) {
        reader = null;
        try {
            reader = new Kiwix.Reader (archive.path);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public SearchResultModel search_text (string text) {
        SearchResultModel model = new SearchResultModel ();

        if (reader == null) {
            return model;
        }
        reader.search_suggestions_smart (text, SEARCH_LIMIT);

        string suggestion;
        string suggestion_url;
        while (
            reader.get_next_suggestion (out suggestion, out suggestion_url)
        ) {
            SearchResultItem item = new SearchResultItem (
                suggestion, suggestion_url
            );
            model.append (item);
        }

        return model;
    }
}
