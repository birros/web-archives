public class WebArchives.SearchResultModel : Object, ListModel {
    private ListStore items;

    public SearchResultModel () {
        items = new ListStore (typeof (SearchResultItem));

        items.items_changed.connect ((position, removed, added) => {
            items_changed (position, removed, added);
        });
    }

    public Object? get_item (uint index) {
        return items.get_item (index);
    }

    public Type get_item_type () {
        return typeof (SearchResultItem);
    }

    public uint get_n_items () {
        return items.get_n_items();
    }

    public void append (SearchResultItem item) {
        items.append (item);
    }
}
