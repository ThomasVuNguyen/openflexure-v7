// NB this file has been edited from the auto-generated version
// to wrap it in a module, for ease of re-use

module sangaboard_v0_5_cc_led_board() {
    // We shift the board so the centre of the circle is [0,0] and
    // the board sits on the z=0 plane.
    translate([-1.35, 0, 0.5]) {
        scale(2.54) { // I think KiCAD exports in 1/10-inch units
            color("#CAD1EE") import("./led_board_colors/led_board_CAD1EE.stl");
            color("#FFFFFF") import("./led_board_colors/led_board_FFFFFF.stl");
            color("#262525") import("./led_board_colors/led_board_262525.stl");
            color("#DBBC7E") import("./led_board_colors/led_board_DBBC7E.stl");
            color("#F5F5F5") import("./led_board_colors/led_board_F5F5F5.stl");
            color("#000000") import("./led_board_colors/led_board_000000.stl");
            color("#BF9C3B") import("./led_board_colors/led_board_BF9C3B.stl");
            color("#808080") import("./led_board_colors/led_board_808080.stl");
            color("#200235D4") import("./led_board_colors/led_board_200235D4.stl");
        }
    }
}
