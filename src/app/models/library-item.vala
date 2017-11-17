public class WebArchives.LibraryItem : Object {
    public string id                {get; set; default = "";}
    public string language          {get; set; default = "";}
    public uint64 article_count     {get; set; default = 0; }
    public uint64 media_count       {get; set; default = 0; }
    public string favicon           {get; set; default = "";}
    public string description       {get; set; default = "";}
    public string name              {get; set; default = "";}
    public string title             {get; set; default = "";}
    public string date              {get; set; default = "";}
    public uint64 size              {get; set; default = 0; }
    public string tags              {get; set; default = "";}
    public string creator           {get; set; default = "";}
    public string publisher         {get; set; default = "";}
    public string favicon_mime_type {get; set; default = "";}
    public string url               {get; set; default = "";}
}
