/**
 * FIXME: not optimized code.
 * use essentialy the same code than HistoryModel.
 */
public class WebArchives.SearchRecentModel : Object, ListModel {
    private SearchRecentStore store;
    private string name;
    private ListStore items;
    private HashTable<SearchRecentItem, ulong> callbacks;
    public delegate int SortFunc (SearchRecentItem a, SearchRecentItem b);
    private CompareDataFunc sort_func;

    public SearchRecentModel (SearchRecentStore store, string name) {
        this.store = store;
        this.name = name;

        items = new ListStore (typeof (SearchRecentItem));
        callbacks = new HashTable<SearchRecentItem, ulong> (
            direct_hash, direct_equal
        );

        set_sort_func (default_sort);

        store.foreach (on_add);
        store.item_added.connect (on_add);
        store.item_removed.connect (on_remove);

        items.items_changed.connect ((position, removed, added) => {
            items_changed (position, removed, added);
        });
    }

    /**
     * No need to disconnect callbacks, this seems to be automaticly done by
     * GObject system.
     */
    ~SearchRecentModel () {
        info ("destroy");
    }

    public void set_sort_func (SortFunc sort_func) {
        this.sort_func = ((a, b) => {
            var aa = (SearchRecentItem) a;
            var bb = (SearchRecentItem) b;
            return sort_func (aa, bb);
        });
        invalidate_sort ();
    }

    public void invalidate_sort () {
        items.sort (sort_func);
    }

    public Object? get_item (uint index) {
        return items.get_item (index);
    }

    public Type get_item_type () {
        return typeof (SearchRecentItem);
    }

    public uint get_n_items () {
        return items.get_n_items();
    }

    private void on_add (SearchRecentItem item) {
        if (item.name == name) {
            add (item);
        }
    }

    private void on_remove (SearchRecentItem item) {
        if (item.name == name) {
            remove (item);
        }
    }

    private void add (SearchRecentItem item) {
        listen (item);
        items.insert_sorted (item, sort_func);
    }

    private void remove (SearchRecentItem item) {
        for (int i = 0; i < items.get_n_items(); i++) {
            SearchRecentItem result = (SearchRecentItem) items.get_item (i);
            if (item == result) {
                unlisten (item);
                items.remove (i);
            }
        }
    }

    private void listen (SearchRecentItem item) {
        ulong callback = item.notify.connect (() => {
            items.sort (sort_func);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (SearchRecentItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    public int default_sort (SearchRecentItem a, SearchRecentItem b) {
        if (a.timestamp > b.timestamp) {
            return -1;
        } else if (a.timestamp < b.timestamp) {
            return 1;
        } else {
            return 0;
        }
    }
}
