namespace BugDemos {

	public class HeaderBar : Gtk.HeaderBar {

		public Window main_window { get; construct; }

		public HeaderBar (Window window) {
			Object (
				main_window: window
			);
		}

		construct {
			show_close_button = true;

			var stack_switcher = new Gtk.StackSwitcher ();
			stack_switcher.stack = main_window.main_stack;

			set_custom_title (stack_switcher);
		}
	}

	public class Window : Gtk.ApplicationWindow {

		public Gtk.Stack main_stack { get; set; }

		public Window (Application app) {
			Object (
				application: app
			);
		}

		construct {

			set_title ("BugDemo");
			window_position = Gtk.WindowPosition.CENTER;
			set_default_size (480, 320);

			main_stack = new Gtk.Stack ();
			main_stack.expand = true;

			var dummy_grid = new Gtk.Grid ();
			dummy_grid.add (new Gtk.Label ("Dummy page"));

			var settings_stack = new Gtk.Stack ();

			for (int i = 0; i < 3; i++) {

				string setting_name = "setting " + i.to_string ();
				string header = (i == 0) ? "Settings" : null;

				var settings_view = new SettingsView (
					setting_name, 
					"description " + i.to_string(),
					header
				);

				settings_stack.add_named (settings_view, setting_name);
			}

			var sidebar = new Granite.SettingsSidebar (settings_stack);

			var settings_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

			settings_pane.pack1 (sidebar, false, false);
			settings_pane.add (settings_stack);

			main_stack.add_titled (dummy_grid, "dummy_grid", "Dummy grid");
			main_stack.add_titled (settings_pane, "settings_pane", "Settings");

			add (main_stack);

			var headerbar = new HeaderBar (this);
			set_titlebar (headerbar);

			show_all ();

			// This will switch to the settings_pane AND update the StackSwitcher
			main_stack.set_visible_child_name("settings_pane");

			// Here's the bug: the settings page gets selected, but the sidebar isn't synched.
			settings_stack.set_visible_child_name ("setting 1");
			debug(settings_stack.get_visible_child_name () + "\n");

		}

	}

	public class SettingsView : Granite.SimpleSettingsPage {

		public SettingsView (string setting_name, string setting_description, string? header) {
			Object (
				header: header,
				title: setting_name,
				description: setting_description,
				activatable: true
			);
			this.status_switch.active = true;
		}

	}

	public class Application : Gtk.Application {

		public Application () {
			Object (
				application_id: "com.github.carniz.bugdemos.settingssidebar.1",
				flags: ApplicationFlags.FLAGS_NONE
			);
		}

		protected override void activate () {

			var window = new Window (this);
			add_window (window);

		}
	}

	public static int main (string[] args) {

		var app = new Application ();
		return app.run (args);

	}

}
