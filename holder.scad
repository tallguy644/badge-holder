// Recreated clip-in tray with cross slider
// Dimensions from caliper photos (inches -> mm):
//   overall length 3.82 in = 97.0   | width 2.32 in = 58.9
//   thickness      0.31 in =  7.9   | slider channel 0.72 in = 18.3
//   pocket length  3.63 in = 92.2 (approx, inner)
// Everything else is estimated from the photos - tweak below.

/* [Render] */
part = "all";          // [all, base, slider]

/* [Body] */
L        = 97.0;
W        = 58.9;
H        = 7.9;
corner_r = 3.0;
floor_t  = 1.6;
wall_t   = 2.4;
rim_w    = 1.2;   // stepped inner rim at the top edge
rim_d    = 1.0;

/* [Clip end (x = 0)] */
finger_w     = 11.0;
finger_len   = 26.0;
finger_gap   = 1.0;   // slot width around each finger
finger_inset = 6.0;   // distance from side wall to finger
hook_out     = 1.6;   // how far the hook sticks out past the end
hook_h       = 2.2;
end_gap_w    = 20.0;  // open notch in the end wall between fingers

/* [Slider channel (near x = L)] */
ch_w        = 18.3;   // measured
ch_x        = L - wall_t - 4.0 - ch_w/2;   // channel centre line
ch_wall     = 1.2;
groove_d    = 0.8;    // retention groove the slider rides in
slot_w      = 12.0;   // stadium window through the floor
slot_len    = 38.0;
side_win_h  = 4.0;    // window in the side wall the slider pokes out of
side_win_w  = 14.0;

/* [Slider] */
clr        = 0.3;     // fit clearance per side
sl_len     = 22.0;
sl_t       = 2.0;
hole_d     = 11.0;    // round hole / magnet seat
knob_d     = 6.0;
knob_h     = 2.0;

$fn = 64;

module rrect(x, y, h, r) {
    linear_extrude(h)
        offset(r) offset(-r) square([x, y]);
}

module stadium(len, w, h) {
    hull() {
        translate([0, w/2, 0])       cylinder(d = w, h = h);
        translate([0, len - w/2, 0]) cylinder(d = w, h = h);
    }
}

module base() {
    difference() {
        rrect(L, W, H, corner_r);

        // main pocket
        translate([wall_t, wall_t, floor_t])
            rrect(L - 2*wall_t, W - 2*wall_t, H, corner_r - 1);

        // stepped top rim
        translate([wall_t - rim_w, wall_t - rim_w, H - rim_d])
            rrect(L - 2*(wall_t - rim_w), W - 2*(wall_t - rim_w), H, corner_r - 0.5);

        // finger slots (U-cut around each finger)
        for (y0 = [finger_inset + wall_t, W - wall_t - finger_inset - finger_w])
            translate([-1, y0 - finger_gap, -1])
                difference() {
                    cube([finger_len + finger_gap + 1, finger_w + 2*finger_gap, floor_t + 2]);
                    translate([-1, finger_gap, -1])
                        cube([finger_len + 1, finger_w, floor_t + 4]);
                }

        // notch in end wall between fingers
        translate([-1, (W - end_gap_w)/2, floor_t])
            cube([wall_t + 2, end_gap_w, H]);

        // floor stadium window under the slider
        translate([ch_x, (W - slot_len)/2, -1])
            stadium(slot_len, slot_w, floor_t + 2);

        // side-wall window where the slider exits
        translate([ch_x - side_win_w/2, -1, floor_t + 0.6])
            cube([side_win_w, wall_t + 2, side_win_h]);

        // retention grooves inside the channel walls
        for (s = [-1, 1])
            translate([ch_x + s*(ch_w/2) - (s > 0 ? 0 : groove_d), wall_t, floor_t + 0.4])
                cube([groove_d, W - 2*wall_t, sl_t + 2*clr]);
    }

    // channel side walls
    for (s = [-1, 1])
        translate([ch_x + s*(ch_w/2) + (s > 0 ? 0 : -ch_wall), wall_t, floor_t])
            difference() {
                cube([ch_wall, W - 2*wall_t, H - floor_t - rim_d]);
                translate([s > 0 ? -0.01 : ch_wall - groove_d + 0.01, -1, 0.4])
                    cube([groove_d, W, sl_t + 2*clr]);
            }

    // hooks on the finger tips
    for (y0 = [finger_inset + wall_t, W - wall_t - finger_inset - finger_w])
        translate([0, y0, 0])
            hull() {
                translate([-hook_out, 0, floor_t]) cube([0.01, finger_w, 0.6]);
                translate([0, 0, floor_t]) cube([wall_t, finger_w, hook_h]);
            }
}

module slider() {
    w = ch_w + 2*groove_d - 2*clr;
    difference() {
        union() {
            translate([-w/2, 0, 0]) cube([w, sl_len, sl_t]);
            // thumb knob that pokes up for sliding
            translate([0, sl_len - knob_d/2 - 1.5, 0]) cylinder(d = knob_d, h = sl_t + knob_h);
        }
        translate([0, hole_d/2 + 2, -1]) cylinder(d = hole_d, h = sl_t + 2);
    }
}

if (part == "base" || part == "all") base();
if (part == "slider")                slider();
if (part == "all")
    translate([L + 10, 0, 0]) slider();
