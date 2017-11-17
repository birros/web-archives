public class WebArchives.MenuButton : Gtk.MenuButton {
    private WebArchives.HeaderBarPopover popover_menu;

    public MenuButton () {
        Gtk.Image menu_image = new Gtk.Image.from_icon_name (
            "open-menu-symbolic",
            Gtk.IconSize.MENU
        );
        set_image (menu_image);

        popover_menu = new WebArchives.HeaderBarPopover ();
        set_popover (popover_menu);
    }

    public void set_context (Context context) {
        popover_menu.set_context (context);
    }
}
