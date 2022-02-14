public class Mink.Options : Gtk.Widget {
    public Gtk.ScrolledWindow scrolled;
    public Mink.Window window { get; construct; }
    public Options (Mink.Window win) {
        Object (window: win);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        margin_start = 20;
        margin_end = 20;
        margin_top = 20;
        margin_bottom = 20;

        var monday = new Mink.DailySchedules (window, "Monday");
        var tuesday = new Mink.DailySchedules (window, "Tuesday");
        var wednesday = new Mink.DailySchedules (window, "Wednesday");
        var thursday = new Mink.DailySchedules (window, "Thursday");
        var friday = new Mink.DailySchedules (window, "Friday");
        var saturday = new Mink.DailySchedules (window, "Saturday");
        var sunday = new Mink.DailySchedules (window, "Sunday");

        var grid = new Gtk.Grid ();
        grid.attach (monday, 0, 0);
        grid.attach (tuesday, 0, 1);
        grid.attach (wednesday, 0, 2);
        grid.attach (thursday, 0, 3);
        grid.attach (friday, 0, 4);
        grid.attach (saturday, 0, 5);
        grid.attach (sunday, 0, 6);

        scrolled = new Gtk.ScrolledWindow () {
            child = grid,
            vexpand = true
        };
        scrolled.set_parent (this);
    }

    ~Options () {
        while (get_last_child () != null) {
            get_last_child ().unparent ();
        }
    }
}

public class Mink.DailySchedules : Gtk.Grid {
    public string weekday { get; construct; }
    public Mink.Window window { get; construct; }
    public string starting_hour { get; set; }
    public string ending_hour { get; set; }

    public DailySchedules (Mink.Window window, string weekday) {
        Object (
            window: window,
            weekday: weekday
        );
    }

    construct {
        var add_dialog = new Granite.Dialog () {
            transient_for = window
        };

        var content_area = add_dialog.get_content_area ();
        content_area.orientation = Gtk.Orientation.VERTICAL;
        content_area.spacing = 12;

        var focus_controller_title = new Gtk.EventControllerFocus ();
        var title_entry = new Gtk.Entry () {
            hexpand = true,
            height_request = 20,
            placeholder_text = "Short title e.g. 'Onikabuto'"
        };
        title_entry.add_controller (focus_controller_title);

        content_area.append (new Gtk.Label ("<b>Meeting Title</b>") {
            hexpand = true,
            xalign = -1,
            use_markup = true
        });
        content_area.append (title_entry);

        var start_time_picker = new Granite.TimePicker () {
            hexpand = true,
            height_request = 20
        };

        var end_time_picker = new Granite.TimePicker () {
            hexpand = true,
            height_request = 20
        };

        var time_picker = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        time_picker.append (start_time_picker);
        time_picker.append (new Gtk.Label ("    to  "));
        time_picker.append (end_time_picker);

        content_area.append (new Gtk.Label ("<b>Meeting Time</b>") {
            hexpand = true,
            xalign = -1,
            use_markup = true
        });
        content_area.append (time_picker);

        var focus_controller_link = new Gtk.EventControllerFocus ();
        var link_entry = new Gtk.Entry () {
            hexpand = true,
            height_request = 20,
            placeholder_text = "Link of Meeting e.g. 'zoommtg://us.zoom.link'"
        };
        link_entry.add_controller (focus_controller_link);

        content_area.append (new Gtk.Label ("<b>Meeting Link</b>") {
            hexpand = true,
            xalign = -1,
            use_markup = true
        });
        content_area.append (link_entry);

        add_dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL);
        add_dialog.add_button ("Add", Gtk.ResponseType.ACCEPT);

        var add_button = new Gtk.Button.with_label ("+") {
            hexpand = true
        };
        add_button.clicked.connect (() => {
            add_dialog.show ();
        });

        var listbox = new Gtk.ListBox ();

        var main_grid = new Gtk.Grid ();
        main_grid.attach (listbox, 0, 0);
        main_grid.attach (add_button, 0, 1);

        var revealer = new Gtk.Revealer () {
            child = main_grid,
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        };
        var label = new Gtk.Label ("<b>" + weekday + "</b>") {
            xalign = -1,
            use_markup = true
        };

        var button = new Gtk.ToggleButton () {
            child = label,
            hexpand = true
        };

        attach (button, 0, 0);
        attach (revealer, 0, 1);

        can_focus = false;

        button.toggled.connect (() => {
            revealer.reveal_child = button.active;
            add_button.margin_bottom = (int) button.active * 10;
        });

        var can_proceed = 0;
        add_dialog.response.connect ((response) => {
            if (response == Gtk.ResponseType.CANCEL) {
                add_dialog.hide ();
            } else if (response == Gtk.ResponseType.ACCEPT) {
                if (can_proceed >= 3) {
                    listbox.append (new Item (title_entry.text, start_time_picker.text, end_time_picker.text, link_entry.text));
                    add_dialog.hide ();
                }
                print (can_proceed.to_string());
            }
        });

        focus_controller_title.leave.connect (() => {
            if (title_entry.text == "") {
                title_entry.add_css_class ("reject_entry");
                can_proceed -= 1;
            } else {
                title_entry.remove_css_class ("reject_entry");
                can_proceed += 1;
            }
        });

        end_time_picker.time_changed.connect (() => {
            if (start_time_picker.text == end_time_picker.text) {
                start_time_picker.add_css_class ("reject_entry");
                end_time_picker.add_css_class ("reject_entry");
                can_proceed -= 1;
            } else {
                start_time_picker.remove_css_class ("reject_entry");
                end_time_picker.remove_css_class ("reject_entry");
                can_proceed += 1;
            }
        });

        focus_controller_link.leave.connect (() => {
            if (link_entry.text == "") {
                link_entry.add_css_class ("reject_entry");
                can_proceed -= 1;
            } else {
                link_entry.remove_css_class ("reject_entry");
                can_proceed += 1;
            }
        });
    }

    public class Item : Gtk.Box {
        public string title { get; set construct; }
        public string starting_time { get; set construct; }
        public string ending_time { get; set construct; }
        public string link { get; set construct; }

        public Item (string title, string starting_time, string ending_time, string link) {
            Object (
                title: title,
                starting_time: starting_time,
                ending_time: ending_time,
                link: link
            );
        }

        construct {
            var label = new Gtk.Label (title) {
                hexpand = true,
                vexpand = true,
                xalign = -1,
                margin_start = 10
            };

            var time = new Gtk.Label (starting_time) {
                halign = Gtk.Align.END,
                margin_end = 5
            };

            append (label);
            append (time);

            var controller = new Gtk.GestureClick ();
            label.add_controller (controller);

            controller.pressed.connect (() => {
                print ("Title: " + title + "\nStarting Time: " + starting_time + "\nEnding Time: " + ending_time +"\nLink: " + link + "\n\n\n");
            });
        }
    }
}
