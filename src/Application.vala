public class Mink.Application : Gtk.Application {

    public Application () {
        Object (
            application_id: "com.github.zenitsudev.mink",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var app_window = new Mink.Window (this);
        app_window.present ();
    }
}
