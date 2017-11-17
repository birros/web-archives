/**
 * FIXME: not optimized code.
 */
public class WebArchives.BookmarkModel : Object, ListModel {
    private BookmarkStore store;
    private string name;
    private ListStore items;
    public delegate int SortFunc (BookmarkItem a, BookmarkItem b);
    private CompareDataFunc sort_func;

    public BookmarkModel (BookmarkStore store, string name) {
        this.store = store;
        this.name = name;

        items = new ListStore (typeof (BookmarkItem));

        set_sort_func (default_sort);

        store.foreach (on_add);
        store.item_added.connect (on_add);
        store.item_removed.connect (on_remove);

        items.items_changed.connect ((position, removed, added) => {
            items_changed (position, removed, added);
        });
    }

    public void set_sort_func (SortFunc sort_func) {
        this.sort_func = ((a, b) => {
            var aa = (BookmarkItem) a;
            var bb = (BookmarkItem) b;
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
        return typeof (BookmarkItem);
    }

    public uint get_n_items () {
        return items.get_n_items();
    }

    private void on_add (BookmarkItem item) {
        if (item.name == name) {
            add (item);
        }
    }

    private void on_remove (BookmarkItem item) {
        if (item.name == name) {
            remove (item);
        }
    }

    private void add (BookmarkItem item) {
        items.insert_sorted (item, sort_func);
    }

    private void remove (BookmarkItem item) {
        for (int i = 0; i < items.get_n_items(); i++) {
            BookmarkItem result = (BookmarkItem) items.get_item (i);
            if (item == result) {
                items.remove (i);
            }
        }
    }

    public int default_sort (BookmarkItem a, BookmarkItem b) {
        if (a.title > b.title) {
            return 1;
        } else if (a.title < b.title) {
            return -1;
        } else {
            return 0;
        }
    }
}
