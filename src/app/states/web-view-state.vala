public class WebArchives.WebViewState : Object {
    public string title        {get; set; default = null; }
    public string url          {get; set; default = "";   }
    public bool can_go_back    {get; set; default = false;}
    public bool can_go_forward {get; set; default = false;}
    public double zoom_level   {get; set; default = 1.0;  }
    public bool can_zoom_out   {get; set; default = false;}
    public bool can_zoom_in    {get; set; default = false;}
    public bool can_zoom_reset {get; set; default = false;}

    public signal void go_home ();
    public signal void go_back ();
    public signal void go_forward ();
    public signal void load_uri (string uri);
    public signal void open_external (string uri);
    public signal void zoom_out ();
    public signal void zoom_in ();
    public signal void zoom_reset ();
}
