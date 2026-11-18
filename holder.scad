// Badge holder - recreation v2, matched to reference photos in photos/
// Measured (caliper):  length 97.0 (3.82in) | width 58.9 (2.32in)
//                      thickness 7.9 (0.31in) | slider window 18.3 (0.72in)
// Everything else scaled off the photos. X = length (clip end at x=0),
// Y = width, Z = height (floor on the bed).

/* [Render] */
part = "all";            // [all, base, slider, assembled]

/* [Body] */
L        = 97.0;
W        = 58.9;
H        = 7.9;
corner_r = 4.0;
floor_t  = 2.0;
rim      = 3.0;          // perimeter wall
step_w   = 1.0;          // stepped edge on the inside top of the rim
step_d   = 1.0;
lip_d    = 0.8;          // card-retention undercut along both long walls
lip_h    = 1.0;

/* [Clip end] */
end_block   = 9.5;       // solid raised band at the clip end
finger_w    = 11.0;
finger_y    = 4.5;       // finger distance from each long edge
finger_len  = 25.0;      // from rim to root
slit        = 1.0;
catch_len   = 6.0;       // raised catch block on each finger tip
catch_h     = H - 1.0;
lanyard_l   = 14.7;
lanyard_w   = 4.5;
lanyard_x   = 1.6;       // distance of slot from the end

/* [Slider window] */
win_w      = 18.3;       // measured
win_cx     = 78.0;       // window centre along length
win_y0     = 5.5;        // rounded end
win_y1     = 47.0;       // square end
thru_w     = 15.0;       // through-cut (leaves a ledge for the slider)
ledge_z    = 1.0;
rail_t     = 1.6;        // flexing side rails
rail_slit  = 1.0;
rail_free  = 24.0;       // free (flexing) length of each rail
knob_d     = 3.4;        // detent knob at each rail tip
groove     = 0.6;        // groove in rails the slider tongues ride in
side_win_w = 14.0;       // window in the long wall at the slider end
side_win_h = 3.0;

/* [Slider] */
clr      = 0.25;
sl_len   = 22.0;
sl_t     = 2.4;
sl_hole  = 13.0;

$fn = 72;

module rrect(x, y, h, r) linear_extrude(h) offset(r) offset(-r) square([x, y]);

module stadium2d(w, y0, y1) {          // rounded at y0, square at y1
    hull() {
        translate([0, y0 + w/2]) circle(d = w);
        translate([-w/2, y1 - 0.01]) square([w, 0.01]);
    }
}

module finger_ys() {
    for (y = [finger_y, W - finger_y - finger_w]) translate([0, y, 0]) children();
}

module base() {
    rx0 = win_cx - win_w/2 - rail_t;           // rail outer edges
    rx1 = win_cx + win_w/2 + rail_t;
    difference() {
        union() {
            difference() {
                rrect(L, W, H, corner_r);
                // card pocket
                translate([rim, rim, floor_t]) rrect(L - 2*rim, W - 2*rim, H, corner_r - 2);
                // stepped top edge
                translate([rim - step_w, rim - step_w, H - step_d])
                    rrect(L - 2*(rim - step_w), W - 2*(rim - step_w), H, corner_r - 1.5);
                // card-retention undercut on long walls
                for (y = [rim - lip_d, W - rim])
                    translate([end_block, y, H - step_d - lip_h - 0.6]) cube([L - end_block - rim, lip_d, lip_h]);
            }
            // raised end band
            translate([rim - 0.01, rim - 0.01, 0]) cube([end_block - rim, W - 2*rim + 0.02, H - step_d]);
            // U frame + rails around the slider window
            translate([win_cx, 0, floor_t - 0.01])
                linear_extrude(H - floor_t - step_d - 1.2)
                    difference() {
                        offset(rail_t) stadium2d(win_w, win_y0, win_y1);
                        stadium2d(win_w, win_y0, win_y1 + 1);
                    }
        }

        // fingers: U-slit round each tongue so the tip flexes
        finger_ys() translate([rim, -slit, -1]) difference() {
            cube([finger_len + slit, finger_w + 2*slit, H + 2]);
            translate([slit, slit, -1]) cube([finger_len + 1, finger_w, H + 4]);
        }
        // clear the end band above each tongue, then the catch is added back
        finger_ys() translate([rim + slit, 0, floor_t]) cube([finger_len, finger_w, H]);

        // lanyard slot through the end band
        translate([lanyard_x + lanyard_w/2, W/2, -1])
            hull() for (s = [-1, 1]) translate([0, s*(lanyard_l - lanyard_w)/2, 0]) cylinder(d = lanyard_w, h = H + 2);

        // slider window: ledge recess + through-cut
        translate([win_cx, 0, ledge_z]) linear_extrude(H) stadium2d(win_w, win_y0, win_y1);
        translate([win_cx, 0, -1]) linear_extrude(H) stadium2d(thru_w, win_y0 + (win_w - thru_w)/2, win_y1);
        // let the slider run up to the wall
        translate([win_cx - win_w/2, win_y1 - 0.5, ledge_z]) cube([win_w, W - rim - win_y1 + 0.5, H]);

        // slits that free the rails
        for (x = [rx0 - rail_slit, rx1])
            translate([x, win_y1 - rail_free, -1]) cube([rail_slit, rail_free + 0.01, H + 2]);
        // groove in rails for slider tongues
        translate([win_cx - win_w/2 - groove, win_y0 + win_w/2, ledge_z + 0.6]) cube([win_w + 2*groove, W, sl_t - 1.0]);

        // side window in long wall
        translate([win_cx - side_win_w/2, W - rim - 1, floor_t + 0.8]) cube([side_win_w, rim + 2, side_win_h]);
    }

    // catch blocks on the finger tips
    finger_ys() translate([rim + slit, 0, floor_t - 0.01]) cube([catch_len, finger_w, catch_h - floor_t]);

    // detent knobs on rail tips
    for (s = [-1, 1])
        translate([win_cx + s*(win_w/2), win_y1 - knob_d/2 - 0.5, floor_t])
            cylinder(d = knob_d, h = H - floor_t - step_d - 1.2);
}

module slider() {
    w = win_w - 2*clr;
    difference() {
        union() {
            translate([-w/2, 0, 0]) cube([w, sl_len, sl_t]);
            // side tongues ride in the rail grooves
            translate([-w/2 - groove + clr, 1, 0.6]) cube([w + 2*groove - 2*clr, sl_len - 2, sl_t - 1.0 - 2*clr]);
        }
        translate([0, sl_len/2, -1]) cylinder(d = sl_hole, h = sl_t + 2);
        // notches for detent knobs
        for (s = [-1, 1]) translate([s*w/2, sl_len - knob_d/2 - 1, -1]) cylinder(d = knob_d + 0.4, h = sl_t + 2);
    }
}

if (part == "base"   || part == "all") base();
if (part == "slider")                  slider();
if (part == "all") translate([L + 12, 0, 0]) slider();
if (part == "assembled") {
    base();
    color("dimgray") translate([win_cx, win_y1 - sl_len + 3, ledge_z]) slider();
}
