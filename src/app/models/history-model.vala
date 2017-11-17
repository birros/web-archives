/**
 * FIXME: not optimized code.
 * use essentialy the same code than SearchRecentModel.
 */
public class WebArchives.HistoryModel : Object, ListModel {
    private HistoryStore store;
    private string name;
    private ListStore items;
    private HashTable<HistoryItem, ulong> callbacks;
    public delegate int SortFunc (HistoryItem a, HistoryItem b);
    private CompareDataFunc sort_func;

    public HistoryModel (HistoryStore store, string name) {
        this.store = store;
        this.name = name;

        items = new ListStore (typeof (HistoryItem));
        callbacks = new HashTable<HistoryItem, ulong> (
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
    ~HistoryModel () {
        info ("destroy");
    }

    public void set_sort_func (SortFunc sort_func) {
        this.sort_func = ((a, b) => {
            var aa = (HistoryItem) a;
            var bb = (HistoryItem) b;
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
        return typeof (HistoryItem);
    }

    public uint get_n_items () {
        return items.get_n_items();
    }

    private void on_add (HistoryItem item) {
        if (item.name == name) {
            add (item);
        }
    }

    private void on_remove (HistoryItem item) {
        if (item.name == name) {
            remove (item);
        }
    }

    private void add (HistoryItem item) {
        listen (item);
        items.insert_sorted (item, sort_func);
    }

    private void remove (HistoryItem item) {
        for (int i = 0; i < items.get_n_items(); i++) {
            HistoryItem result = (HistoryItem) items.get_item (i);
            if (item == result) {
                unlisten (item);
                items.remove (i);
            }
        }
    }

    private void listen (HistoryItem item) {
        ulong callback = item.notify.connect (() => {
            items.sort (sort_func);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (HistoryItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    public int default_sort (HistoryItem a, HistoryItem b) {
        if (a.timestamp > b.timestamp) {
            return -1;
        } else if (a.timestamp < b.timestamp) {
            return 1;
        } else {
            return 0;
        }
    }
}
