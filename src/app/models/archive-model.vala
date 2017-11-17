/**
 * FIXME: not optimized code.
 */
public class WebArchives.ArchiveModel : Object, ListModel {
    private ArchiveStore store;
    private string scope;
    private string lang;
    private ListStore items;
    private GenericSet<ArchiveItem> items_set;
    private HashTable<ArchiveItem, ulong> callbacks;
    public delegate int SortFunc (ArchiveItem a, ArchiveItem b);
    private CompareDataFunc sort_func;
    public delegate bool FilterFunc (ArchiveItem a);
    private FilterFunc filter_func;

    public ArchiveModel (
        ArchiveStore store,
        string scope,
        string? lang = null
    ) {
        this.store = store;
        this.scope = scope;
        this.lang = lang;

        items = new ListStore (typeof (ArchiveItem));
        items_set = new GenericSet<ArchiveItem> (direct_hash, direct_equal);
        callbacks = new HashTable<ArchiveItem, ulong> (
            direct_hash, direct_equal
        );

        set_sort_func (default_sort);
        set_filter_func (default_filter);

        store.foreach (on_add);
        store.item_added.connect (on_add);
        store.item_removed.connect (on_remove);

        items.items_changed.connect ((position, removed, added) => {
            items_changed (position, removed, added);
        });
    }

    public void set_sort_func (SortFunc sort_func) {
        this.sort_func = ((a, b) => {
            var aa = (ArchiveItem) a;
            var bb = (ArchiveItem) b;
            return sort_func (aa, bb);
        });
        invalidate_sort ();
    }

    public void set_filter_func (FilterFunc filter_func) {
        this.filter_func = ((a) => {
            return filter_func (a);
        });
        invalidate_filter ();
    }

    public void invalidate_sort () {
        items.sort (sort_func);
    }

    public void invalidate_filter () {
        store.foreach ((item) => {
            if (item.scope != scope) {
                return;
            }

            if (lang == null) {
                filter (item);
            } if (lang == "" && item.lang == "") {
                filter (item);
            } else {
                var langs = item.lang.split (",");
                foreach (var l in langs) {
                    if (l == lang) {
                        filter (item);
                    }
                }
            }
        });
    }

    private void filter (ArchiveItem item) {
        if (filter_func (item)) {
            add (item);
        } else {
            remove (item);
        }
    }

    /**
     * No need to disconnect callbacks, this seems to be automaticly done by
     * GObject system.
     */
    ~ArchiveModel () {
        info ("destroy");
    }

    public Object? get_item (uint index) {
        return items.get_item (index);
    }

    public Type get_item_type () {
        return typeof (ArchiveItem);
    }

    public uint get_n_items () {
        return items.get_n_items();
    }

    private void on_add (ArchiveItem item) {
        if (item.scope != scope) {
            return;
        }

        if (lang == null) {
            add (item);
        } if (lang == "" && item.lang == "") {
            add (item);
        } else {
            var langs = item.lang.split (",");
            foreach (var l in langs) {
                if (l == lang) {
                    add (item);
                }
            }
        }
    }

    private void on_remove (ArchiveItem item) {
        if (item.scope != scope) {
            return;
        }

        if (lang == null) {
            remove (item);
        } if (lang == "" && item.lang == "") {
            remove (item);
        } else {
            var langs = item.lang.split (",");
            foreach (var l in langs) {
                if (l == lang) {
                    remove (item);
                }
            }
        }
    }

    private void add (ArchiveItem item) {
        if (!items_set.contains (item)) {
            listen (item);
            items.insert_sorted (item, sort_func);
            items_set.add (item);
        }
    }

    private void remove (ArchiveItem item) {
        for (int i = 0; i < items.get_n_items(); i++) {
            ArchiveItem result = (ArchiveItem) items.get_item (i);
            if (item == result) {
                unlisten (item);
                items.remove (i);
                items_set.remove (item);
            }
        }
    }

    private void listen (ArchiveItem item) {
        ulong callback = item.notify.connect (() => {
            items.sort (sort_func);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (ArchiveItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    public int default_sort (ArchiveItem a, ArchiveItem b) {
        if (a.title > b.title) {
            return 1;
        } else if (a.title < b.title) {
            return -1;
        } else {
            return 0;
        }
    }

    public bool default_filter (ArchiveItem item) {
        return true;
    }
}
