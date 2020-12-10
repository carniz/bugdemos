namespace BugDemos { 

	public class Window : Gtk.ApplicationWindow {

		public Gtk.Stack stack { get; set; }
	
		public Window (Application app) {
			Object (
				application: app
			);
		}
	
		construct {

			set_title ("BugDemo");
			window_position = Gtk.WindowPosition.CENTER;
			set_default_size (480, 320);

			var settings_stack = new Gtk.Stack ();

			for (int i = 0; i < 3; i++) {

				string setting_name = "setting " + i.to_string ();
				string header = (i == 0) ? "Settings" : null;
				
				var settings_view = new SettingsView (
					setting_name, 
					"description " +i.to_string(),
					header
				);
				
				settings_stack.add_named (settings_view, setting_name);
			}			
			
			var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
			var sidebar = new Granite.SettingsSidebar (settings_stack);

			paned.pack1 (sidebar, false, false);
			paned.add (settings_stack);
			paned.show_all();
	
			add (paned);
			show_all ();

			// Here's the bug: the settings page gets selected, but the sidebar isn't synched.
			// (by comparison, a Gtk.StackSwitcher is synched to the stack that it's controlling)
			settings_stack.set_visible_child_name ("setting 1");
			print(settings_stack.get_visible_child_name () + "\n");
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
