public class Dbm.Application : Gtk.Application {

    public Application () {
        Object (
            application_id: "com.github.zenitsudev.dabooma",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var app_window = new Dbm.Window (this);
        app_window.present ();
    }
}
