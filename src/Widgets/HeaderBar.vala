public class Dbm.HeaderBar : Gtk.Widget {

    public Gtk.HeaderBar header_widget { get; set; }
    public Dbm.Window window { get; construct; }
    public HeaderBar (Dbm.Window main) {
        Object (window: main);
    }

    static construct {
        set_layout_manager_type (typeof(Gtk.BinLayout));
    }

    construct {
        var header_widget = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label ("Dabooma"),
            show_title_buttons = true
        };

        header_widget.set_parent (this);
    }

    ~HeaderBar () {
        while (get_last_child != null) {
            get_last_child ().unparent ();
        }
    }
}
