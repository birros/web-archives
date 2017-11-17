/**
 * FIXME: not optimized code.
 */
public class WebArchives.LanguageModel : Object, ListModel {
    private LanguageStore language_store;
    private ListStore items;
    private GenericSet<LanguageItem> items_set;
    public delegate int SortFunc (LanguageItem a, LanguageItem b);
    private CompareDataFunc sort_func;
    public delegate bool FilterFunc (LanguageItem a);
    private FilterFunc filter_func;

    public LanguageModel (LanguageStore language_store) {
        this.language_store = language_store;

        items = new ListStore (typeof (LanguageItem));
        items_set = new GenericSet<LanguageItem> (direct_hash, direct_equal);

        set_sort_func (default_sort);
        set_filter_func (default_filter);

        language_store.foreach (add);
        language_store.item_added.connect (add);
        language_store.item_removed.connect (remove);

        items.items_changed.connect ((position, removed, added) => {
            items_changed (position, removed, added);
        });
    }

    public void set_filter_func (FilterFunc filter_func) {
        this.filter_func = ((a) => {
            return filter_func (a);
        });
        invalidate_filter ();
    }

    public void set_sort_func (SortFunc sort_func) {
        this.sort_func = ((a, b) => {
            var aa = (LanguageItem) a;
            var bb = (LanguageItem) b;
            return sort_func (aa, bb);
        });
        invalidate_sort ();
    }

    public void invalidate_filter () {
        language_store.foreach ((item) => {
            if (filter_func (item)) {
                add (item);
            } else {
                remove (item);
            }
        });
    }

    public void invalidate_sort () {
        items.sort (sort_func);
    }

    public Object? get_item (uint index) {
        return items.get_item (index);
    }

    public Type get_item_type () {
        return typeof (LanguageItem);
    }

    public uint get_n_items () {
        return items.get_n_items();
    }

    private void add (LanguageItem item) {
        if (!items_set.contains (item)) {
            items.insert_sorted (item, sort_func);
            items_set.add (item);
        }
    }

    private void remove (LanguageItem item) {
        for (int i = 0; i < items.get_n_items(); i++) {
            LanguageItem result = (LanguageItem) items.get_item (i);
            if (item == result) {
                items.remove (i);
                items_set.remove (item);
            }
        }
    }

    public int default_sort (LanguageItem a, LanguageItem b) {
        if (a.language > b.language) {
            return 1;
        } else if (a.language < b.language) {
            return -1;
        } else {
            return 0;
        }
    }

    public bool default_filter (LanguageItem item) {
        return true;
    }
}
