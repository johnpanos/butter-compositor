using Clutter;

public class GameTile : Clutter.Actor {
    private Clutter.Actor background;
    private Clutter.Actor focus_ring;
    private Clutter.Text label;
    private int tile_index;
    private float tile_width;
    private float tile_height;
    private float focus_ring_padding = 5;

    public signal void focused();
    public signal void activated();

    public GameTile(int index, float width = 200, float height = 200) {
        this.tile_index = index;
        this.tile_width = width;
        this.tile_height = height;

        // Set tile size
        this.set_size(tile_width, tile_height);
        this.reactive = true;

        // Background
        background = new Clutter.Actor();
        background.set_size(tile_width, tile_height);
        background.set_background_color(Cogl.Color() {
            red = 60, green = 60, blue = 60, alpha = 255
        });
        this.add_child(background);

        // Focus ring (initially hidden)
        focus_ring = new Clutter.Actor();
        focus_ring.set_size(
                            tile_width + (focus_ring_padding * 2),
                            tile_height + (focus_ring_padding * 2)
        );
        focus_ring.set_position(-focus_ring_padding, -focus_ring_padding);
        focus_ring.set_background_color(Cogl.Color() {
            red = 0, green = 200, blue = 255, alpha = 255
        });
        focus_ring.set_opacity(0);
        this.add_child(focus_ring);

        // Re-add background on top of focus ring
        this.remove_child(background);
        this.add_child(background);

        // Label
        label = new Clutter.Text();
        label.set_text("Game %d".printf(index + 1));
        label.set_color(Cogl.Color() {
            red = 255, green = 255, blue = 255, alpha = 255
        });

        // Scale font size based on tile size
        int font_size = (int) (tile_height * 0.08f).clamp(12, 24);
        label.set_font_name("Sans %d".printf(font_size));
        label.set_position(tile_width * 0.05f, tile_height * 0.05f);
        this.add_child(label);
    }

    public void set_focused(bool focused) {
        if (focused) {
            // Animate focus ring appearance
            focus_ring.save_easing_state();
            focus_ring.set_easing_duration(150);
            focus_ring.set_easing_mode(Clutter.AnimationMode.EASE_OUT_CUBIC);
            focus_ring.set_opacity(255);
            focus_ring.restore_easing_state();

            // Scale up slightly (5% larger)
            this.save_easing_state();
            this.set_easing_duration(150);
            this.set_easing_mode(Clutter.AnimationMode.EASE_OUT_CUBIC);
            this.set_scale(1.05, 1.05);
            this.set_z_position(10);
            this.restore_easing_state();

            this.focused();
        } else {
            // Animate focus ring disappearance
            focus_ring.save_easing_state();
            focus_ring.set_easing_duration(150);
            focus_ring.set_easing_mode(Clutter.AnimationMode.EASE_OUT_CUBIC);
            focus_ring.set_opacity(0);
            focus_ring.restore_easing_state();

            // Scale back to normal
            this.save_easing_state();
            this.set_easing_duration(150);
            this.set_easing_mode(Clutter.AnimationMode.EASE_OUT_CUBIC);
            this.set_scale(1.0, 1.0);
            this.set_z_position(0);
            this.restore_easing_state();
        }
    }

    public int get_index() {
        return tile_index;
    }

    public void set_focus_ring_padding(float padding) {
        this.focus_ring_padding = padding;
        focus_ring.set_size(
                            tile_width + (focus_ring_padding * 2),
                            tile_height + (focus_ring_padding * 2)
        );
        focus_ring.set_position(-focus_ring_padding, -focus_ring_padding);
    }
}

public class SwitchLauncher : Clutter.Actor {
    // Configuration properties
    public struct Config {
        public float tile_width;
        public float tile_height;
        public float tile_spacing;
        public int num_tiles;
        public int num_rows; // Number of rows (0 = auto-calculate)
        public int num_cols; // Number of columns (0 = auto-calculate)
        public float viewport_width;
        public float viewport_height; // 0 = auto-fit to content
        public float buffer_zone_start;
        public float buffer_zone_end;
    }

    private GameTile[] tiles;
    private int current_focus = 0; // Start at first tile
    private int cols;
    private int rows;
    private Config config;
    private Clutter.Actor container; // Container for tiles that we'll scroll

    public SwitchLauncher(Config? custom_config = null) {
        // Use custom config or defaults
        if (custom_config != null) {
            config = custom_config;
        } else {
            // Default Nintendo Switch-like configuration (single row)
            config = Config() {
                tile_width = 200,
                tile_height = 200,
                tile_spacing = 20,
                num_tiles = 20,
                num_rows = 1,
                num_cols = 0, // Auto-calculate
                viewport_width = 1280,
                viewport_height = 0, // Auto-fit
                buffer_zone_start = 0.3f,
                buffer_zone_end = 0.7f
            };
        }

        // Calculate rows and columns
        if (config.num_rows > 0 && config.num_cols > 0) {
            // Both specified
            rows = config.num_rows;
            cols = config.num_cols;
        } else if (config.num_rows > 0) {
            // Rows specified, calculate columns
            rows = config.num_rows;
            cols = (int) Math.ceil((double) config.num_tiles / rows);
        } else if (config.num_cols > 0) {
            // Columns specified, calculate rows
            cols = config.num_cols;
            rows = (int) Math.ceil((double) config.num_tiles / cols);
        } else {
            // Neither specified, default to single row
            rows = 1;
            cols = config.num_tiles;
        }

        // Calculate viewport height if not specified
        float viewport_height = config.viewport_height;
        if (viewport_height <= 0) {
            viewport_height = rows * config.tile_height + (rows - 1) * config.tile_spacing + 100;
        }

        // Set the launcher size to viewport
        this.set_size(config.viewport_width, viewport_height);
        this.set_clip_to_allocation(true); // Clip content outside bounds

        // Optional: Add subtle visual indicators for buffer zone (remove in production)
        /*
           var buffer_indicator = new Clutter.Actor();
           buffer_indicator.set_size(
            config.viewport_width * (config.buffer_zone_end - config.buffer_zone_start),
            viewport_height
           );
           buffer_indicator.set_position(config.viewport_width * config.buffer_zone_start, 0);
           buffer_indicator.set_background_color(Cogl.Color() {
            red = 40, green = 40, blue = 40, alpha = 128
           });
           this.add_child(buffer_indicator);
         */

        // Create scrollable container
        container = new Clutter.Actor();
        container.set_background_color(Cogl.Color() {
            red = 30, green = 30, blue = 30, alpha = 255
        });
        this.add_child(container);

        // Center container vertically if single row
        if (rows == 1) {
            container.set_y((viewport_height - config.tile_height) / 2);
        } else {
            container.set_y(50); // Top padding for multiple rows
        }

        // Create container with grid layout
        var layout = new Clutter.GridLayout();
        layout.set_column_spacing((int) config.tile_spacing);
        layout.set_row_spacing((int) config.tile_spacing);
        container.set_layout_manager(layout);

        tiles = new GameTile[config.num_tiles];

        // Create tiles and add them to the grid
        for (int i = 0; i < config.num_tiles; i++) {
            tiles[i] = new GameTile(i, config.tile_width, config.tile_height);
            int row = i / cols;
            int col = i % cols;
            layout.attach(tiles[i], col, row, 1, 1);

            // Connect tile signals
            int tile_index = i; // Capture value for closure
            tiles[i].focused.connect(() => {
                // Handle tile focus event if needed
            });

            tiles[i].activated.connect(() => {
                print("Game %d activated!\n", tile_index + 1);
            });
        }

        // Ensure initial focus is within bounds and set smart default
        if (rows == 1 && cols > 5) {
            // For single row, start at position 5 to show buffer zone effect
            current_focus = 5;
        } else {
            // For multi-row, start at center
            current_focus = (rows / 2) * cols + (cols / 2);
        }

        if (current_focus >= config.num_tiles) {
            current_focus = 0;
        }

        // Set initial focus
        tiles[current_focus].set_focused(true);

        // Initial scroll position
        update_scroll_position();
    }

    private void update_scroll_position() {
        var tile_width = config.tile_width;
        var tile_height = config.tile_height;
        var viewport_width = config.viewport_width;
        var tile_spacing = config.tile_spacing;
        var buffer_zone_start = config.buffer_zone_start;
        var buffer_zone_end = config.buffer_zone_end;

        // Buffer Zone Concept:
        // The viewport has an invisible "buffer zone" in the center (30% to 70% of width)
        // When navigating, tiles can move freely within this zone without scrolling
        // Scrolling only happens when a tile would move outside the buffer zone
        // This creates a more stable, Switch-like navigation experience

        // Calculate the position of the focused tile
        float tile_total_width = tile_width + tile_spacing;
        float focused_tile_x = current_focus * tile_total_width;
        float focused_tile_left = focused_tile_x;
        float focused_tile_right = focused_tile_x + tile_width;

        // Define the buffer zone (central area where focus can move without scrolling)
        float buffer_left = viewport_width * buffer_zone_start;
        float buffer_right = viewport_width * buffer_zone_end;

        // Get current container position
        float current_x = container.get_x();

        // Calculate the focused tile's position relative to viewport
        float tile_viewport_left = focused_tile_left + current_x;
        float tile_viewport_right = focused_tile_right + current_x;

        float target_x = current_x;

        // Check if we need to scroll
        if (tile_viewport_left < buffer_left) {
            // Tile is too far left, scroll right
            target_x = buffer_left - focused_tile_left;
        } else if (tile_viewport_right > buffer_right) {
            // Tile is too far right, scroll left
            target_x = buffer_right - focused_tile_right;
        }

        // Calculate bounds to prevent scrolling too far
        float total_width = cols * tile_total_width - tile_spacing;
        float min_x = viewport_width - total_width;
        float max_x = 0;

        // Clamp the target position
        if (target_x > max_x)target_x = max_x;
        if (target_x < min_x)target_x = min_x;

        // Special handling for very first and last tiles
        if (current_focus == 0) {
            // First tile - align to left edge
            target_x = 0;
        } else if (current_focus == cols - 1 && total_width > viewport_width) {
            // Last tile - show end of list
            target_x = min_x;
        }

        // Only animate if position actually changes
        if (target_x != current_x) {
            container.save_easing_state();
            container.set_easing_duration(300);
            container.set_easing_mode(Clutter.AnimationMode.EASE_OUT_CUBIC);
            container.set_x(target_x);
            container.restore_easing_state();
        }
    }

    public void move_focus(int dx, int dy) {
        int old_focus = current_focus;
        int new_col = current_focus % cols + dx;
        int new_row = current_focus / cols + dy;

        // Boundary checking
        if (new_col < 0)new_col = 0;
        /*
           if (new_col >= cols)new_col = cols - 1;
           if (new_row < 0)new_row = 0;
           if (new_row >= rows)new_row = rows - 1;
         */

        int new_focus = new_row * cols + new_col;


        if (new_focus != old_focus) {
            tiles[old_focus].set_focused(false);
            tiles[new_focus].set_focused(true);
            current_focus = new_focus;

            // Update scroll position when focus changes
            update_scroll_position();
        }
    }

    public void activate_current() {
        tiles[current_focus].activated();
    }

    // Method to adjust buffer zone if needed
    public void set_buffer_zone(float start_percent, float end_percent) {
        config.buffer_zone_start = start_percent.clamp(0.0f, 1.0f);
        config.buffer_zone_end = end_percent.clamp(0.0f, 1.0f);
        if (config.buffer_zone_start >= config.buffer_zone_end) {
            warning("Invalid buffer zone: start must be less than end");
            config.buffer_zone_start = 0.3f;
            config.buffer_zone_end = 0.7f;
        }
        update_scroll_position();
    }

    // Get current configuration
    public Config get_config() {
        return config;
    }
}

public class SwitchLauncherApp {
    private SwitchLauncher launcher;

    public SwitchLauncherApp(Clutter.Stage stage) {
        // Example configurations:

        // 1. Default configuration (single row, 200x200 tiles)
        // launcher = new SwitchLauncher();

        // 3. Large tiles in 2x10 grid
        var large_grid_config = SwitchLauncher.Config() {
            tile_width = 250,
            tile_height = 250,
            tile_spacing = 25,
            num_tiles = 200,
            num_rows = 6,
            num_cols = 0, // Auto-calculate
            viewport_width = 1280,
            viewport_height = 0, // Auto-fit
            buffer_zone_start = 0.3f,
            buffer_zone_end = 0.7f
        };
        launcher = new SwitchLauncher(large_grid_config);

        // 4. Portrait tiles in 3x7 grid (like movie posters)
        /*
           var portrait_config = SwitchLauncher.Config() {
            tile_width = 160,
            tile_height = 240,
            tile_spacing = 20,
            num_tiles = 21,
            num_rows = 3,
            num_cols = 0,  // Auto-calculate
            viewport_width = 1280,
            viewport_height = 0,  // Auto-fit
            buffer_zone_start = 0.2f,
            buffer_zone_end = 0.8f
           };
           launcher = new SwitchLauncher(portrait_config);
         */

        // 5. Square grid 5x5
        /*
           var square_grid_config = SwitchLauncher.Config() {
            tile_width = 150,
            tile_height = 150,
            tile_spacing = 20,
            num_tiles = 25,
            num_rows = 5,
            num_cols = 5,
            viewport_width = 900,
            viewport_height = 900,
            buffer_zone_start = 0.2f,
            buffer_zone_end = 0.8f
           };
           launcher = new SwitchLauncher(square_grid_config);
         */

        // Center the launcher
        launcher.set_position(
                              (stage.get_width() - launcher.get_width()) / 2,
                              (stage.get_height() - launcher.get_height()) / 2
        );
        stage.add_child(launcher);

        // Handle keyboard events
        stage.key_press_event.connect(on_key_press);

        // Make the launcher focusable
        launcher.set_reactive(true);
        launcher.grab_key_focus();

        stage.show();
    }

    private bool on_key_press(Clutter.Event event) {
        uint keyval = event.get_key_symbol();

        switch (keyval) {
        case Clutter.Key.Left :
            launcher.move_focus(-1, 0);
            return true;
        case Clutter.Key.Right:
            launcher.move_focus(1, 0);
            return true;
        case Clutter.Key.Up:
            launcher.move_focus(0, -1);
            return true;
        case Clutter.Key.Down:
            launcher.move_focus(0, 1);
            return true;
        case Clutter.Key.Return:
        case Clutter.Key.space:
            launcher.activate_current();
            return true;
        }

        return false;
    }
}

// Example usage in main:
/*
   int main(string[] args) {
    // Initialize Clutter
    var result = Clutter.init(ref args);
    if (result != Clutter.InitError.SUCCESS) {
        error("Failed to initialize Clutter");
    }

    var stage = Clutter.Stage.get_default() as Clutter.Stage;
    stage.set_title("Switch Launcher UI");
    stage.set_background_color(Cogl.Color() {
        red = 20, green = 20, blue = 20, alpha = 255
    });
    stage.set_size(1280, 720);

    // Handle stage destroy
    stage.destroy.connect(() => {
        Clutter.main_quit();
    });

    // Create app with custom configuration
    var app = new SwitchLauncherApp(stage);

    Clutter.main();
    return 0;
   }
 */