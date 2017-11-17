public class WebArchives.MaxWidthBin : Gtk.Bin {
    private Gtk.Widget _child;
    private uint       max_width;
    private uint       space_around;

    public MaxWidthBin (uint max_width, uint space_around = 0) {
        base.set_redraw_on_allocate (false);

        _child            = null;
        this.max_width    = max_width;
        this.space_around = space_around;
    }

    public override void add (Gtk.Widget widget) {
        if ( _child == null ) {
            widget.set_parent (this);
            _child = widget;
        }
    }

    public override void remove (Gtk.Widget widget) {
        if (_child == widget) {
            widget.unparent ();
            _child = null;
            if (get_visible () && widget.get_visible ()) {
                queue_resize_no_redraw ();
            }
        }
    }

    public override void forall_internal (
        bool         include_internals,
        Gtk.Callback callback
    ) {
        if (_child != null) {
            callback (_child);
        }
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    public override void size_allocate (Gtk.Allocation allocation) {
        Gtk.Allocation  child_allocation;
        uint            border_width;
        int             original_x;
        int             original_y;
        int             available_width;
        int             available_height;
        int             x;
        int             y;
        int             width;
        int             height;
        Gtk.Requisition child_minimum_size;
        Gtk.Requisition child_natural_size;

        child_allocation   = Gtk.Allocation ();
        border_width       = get_border_width ();
        child_minimum_size = {0, 0};
        child_natural_size = {0, 0};

        if (_child != null && _child.get_visible ()) {
            _child.get_preferred_size (
                out child_minimum_size, out child_natural_size
            );
        }

        original_x       = allocation.x + (int) border_width;
        original_y       = allocation.y + (int) border_width;
        available_width  = allocation.width - 2 * (int) border_width;
        available_height = allocation.height - 2 * (int) border_width;

        x      = original_x;
        y      = original_y;
        width  = available_width;
        height = available_height;

        if (available_width > max_width + 2 * space_around) {
            x     = original_x + (available_width - (int) max_width)/2;
            width = (int) max_width;
        } else {
            x     = original_x + (int) space_around;
            width = available_width - 2 * (int) space_around;
        }

        width  = int.max (width, child_minimum_size.width);
        height = int.max (height, child_minimum_size.height);

        if (_child != null && _child.get_visible ()) {
            child_allocation.x      = x;
            child_allocation.y      = y;
            child_allocation.width  = width;
            child_allocation.height = height;
            _child.size_allocate (child_allocation);
            if (get_realized ()) {
                _child.show ();
            }
        }
        if (this.get_realized ()) {
            if (_child != null) {
                _child.set_child_visible (true);
            }
        }
        base.size_allocate (allocation);
    }

    public override void get_preferred_height_for_width (
        int     width,
        out int minimum_height,
        out int natural_height
    ) {
        Gtk.Requisition child_minimum_size = {0, 0};
        Gtk.Requisition child_natural_size = {0, 0};

        if (_child != null && _child.get_visible ()) {
            _child.get_preferred_size (
                out child_minimum_size, out child_natural_size
            );
        }

        minimum_height = child_minimum_size.height;
        natural_height = child_natural_size.height;
    }
}
