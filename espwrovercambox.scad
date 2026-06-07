$fn = 64;

// SHELL creation code
wall         = 2.0;
wall_thin    = 1.5;
wall_bottom  = 2.0;
rim_depth    = 1.5;
rim_thick    = 1.0;
lip_height   = 0.5;
lip_depth    = 0.2;
lip_offset   = rim_depth - lip_height;
box_corner_radius = 1.5;

module outer_footprint_2d(bays) {
    union()
        for (b = bays)
            translate([bx(b)-wall, by(b)-wall])
                square([bw(b)+wall*2, bd(b)+wall*2]);
}

function rects_overlap(ax0,ay0,ax1,ay1,bx0,by0,bx1,by1) =
    ax0 < bx1 && ax1 > bx0 && ay0 < by1 && ay1 > by0;

module shell(bays) {
    box_h = max([ for (b = bays) bh(b) ]) + wall_bottom;
    for (i = [0:len(bays)-2])
        for (j = [i+1:len(bays)-1])
            assert(!rects_overlap(
                bx(bays[i]), by(bays[i]),
                bx(bays[i])+bw(bays[i]), by(bays[i])+bd(bays[i]),
                bx(bays[j]), by(bays[j]),
                bx(bays[j])+bw(bays[j]), by(bays[j])+bd(bays[j])),
                str("Bay ", i, " and bay ", j, " overlap!"));

    difference() {
        linear_extrude(box_h)
            offset(r=box_corner_radius) offset(delta=-box_corner_radius)
                outer_footprint_2d(bays);

        translate([0, 0, wall_bottom])
            linear_extrude(box_h)
                offset(delta=-wall)
                    outer_footprint_2d(bays);

        translate([0, 0, box_h - rim_depth])
            rim_ring(bays, rim_depth + 1);

        translate([0, 0, box_h - rim_depth])
            rim_ring(bays, lip_height, extra = lip_depth);
    }
}

module rim_ring(bays, h, extra=0) {
    rt = rim_thick + extra;
    inner_offset = -wall;
    linear_extrude(h)
        difference() {
            offset(delta = inner_offset + rt) outer_footprint_2d(bays);
            offset(delta = inner_offset)      outer_footprint_2d(bays);
        }
}

module shell_lid(bays) {

        lid_h = wall_bottom + rim_depth;
        union() {
            linear_extrude(wall_bottom)
                offset(r=box_corner_radius)
                    offset(delta=-box_corner_radius)
                        outer_footprint_2d(bays);

            translate([0,0,wall_bottom])
                rim_ring(bays, rim_depth);

            translate([0,0,wall_bottom + lip_offset])
                rim_ring(bays, lip_height, extra = lip_depth);
        }
    
}
// END OF SHELL CODE


// START AFTER SHELL CODE

// BAY DEFINITIONS
// [x, y, width, depth, height]
bat  = [0,   0,  55.0, 28.0, 13.0]; // Battery holder
chg  = [-25, 10,  25.0, 30.0, 10.0]; // Charge board (Asymmetric corner)
esp  = [1,  28 + 1.5,  61.0, 31.0, 17.5]; // ESP32 Wrover right next to battery

function bx(b) = b[0];
function by(b) = b[1];
function bw(b) = b[2];
function bd(b) = b[3];
function bh(b) = b[4];

all_bays = [bat, chg, esp];

// GLOBAL CONSTANTS
shelf_ledge  = 3.0;
shelf_z      = wall_bottom + 4.0;
usb_z        = shelf_z + 2.0;
// BASE CUTOUTS
module base_cutouts() {
    // 1. ESP USB Hole (User position fixed)
    usb_w = 10.0;
    usb_h = 6.0;
    usb_xc = bx(esp) + bw(esp);
    translate([usb_xc, by(esp) + bd(esp)/2 - usb_w/2, usb_z])
        cube([wall + 2, usb_w , usb_h]);

    // 2. Charge Chip USB Hole (User position fixed)
    chg_usb_w = 9.0;
    chg_usb_h = 5.0;
    translate([bx(chg) - wall - 1, by(chg) + 2, usb_z])
        cube([wall + 2, chg_usb_w, chg_usb_h]);

    // 3. ESP Pin Header Floor Slots
    pin_l = bw(esp) - 2; 
    pin_w = 3.0;
    pin_x = bx(esp) + (bw(esp) - pin_l) / 2;
    for (dy = [2.0, bd(esp) - pin_w]) {
        translate([pin_x, by(esp) + dy, -1])
            cube([pin_l, pin_w, wall_bottom + 2]);
    }

    // 4. Charge Chip Pin Holes (Full length of section, parallel to Y axis)
    chg_pin_w = 2.5;
    chg_pin_l = bd(chg) - 4.0; 
    translate([bx(chg) + 3, by(chg) + 2, -1])
        cube([chg_pin_w, chg_pin_l, wall_bottom + 2]);
    translate([bx(chg) + bw(chg) - chg_pin_w - 3, by(chg) + 2, -1])
        cube([chg_pin_w, chg_pin_l, wall_bottom + 2]);
}

// LID CUTOUTS
module lid_cutouts() {
    // 1. Ventilation grid pattern over battery area
    margin = 4.0;
    hole_d = 3.0;
    step   = 6.0;
    
    start_x = bx(bat) + margin;
    end_x   = bx(bat) + bw(bat) - margin;
    start_y = by(bat) + margin;
    end_y   = by(bat) + bd(bat) - margin;
    
    for (x = [start_x : step : end_x]) {
        for (y = [start_y : step : end_y]) {
            translate([x, y, -1])
                cylinder(d = hole_d, h = wall_bottom + 2, $fn = 16);
        }
    }

    // 2. Camera Module Hole (Enlarged to 14mm to clear OV2640 sensor housing/PCB base)
    cam_d = 12.0;
    translate([bx(esp) + bw(esp)/2, by(esp) + bd(esp)/2, -1])
        cylinder(d = cam_d, h = wall_bottom + 2, $fn = 32);

    // 3. ESP Pin Header Ceiling Slots (Mirrored from floor logic)
    pin_l = bw(esp) - 2; 
    pin_w = 3.0;
    pin_x = bx(esp) + (bw(esp) - pin_l) / 2;
    for (dy = [2.0, bd(esp) - pin_w]) {
        translate([pin_x, by(esp) + dy, -1])
            cube([pin_l, pin_w, wall_bottom + 2]);
    }

    // 4. Charge Chip Pin Ceiling Slots (Mirrored from floor logic)
    chg_pin_w = 2.5;
    chg_pin_l = bd(chg) - 4.0; 
    translate([bx(chg) + 3, by(chg) + 2, -1])
        cube([chg_pin_w, chg_pin_l, wall_bottom + 2]);
    translate([bx(chg) + bw(chg) - chg_pin_w - 3, by(chg) + 2, -1])
        cube([chg_pin_w, chg_pin_l, wall_bottom + 2]);
}

// INTERNAL FEATURES
module internal_features() {
// Triangle profile support ledges (Eliminates flat horizontal 3D print overhangs)
    
    // Less steep triangle support ledges (Wider base for gentler printing angle)
    
    // ESP board ledges
    translate([bx(esp), by(esp), shelf_z])
        rotate([-90, 0, 0])
        linear_extrude(height = bd(esp))
            polygon(points = [[0, 0], [shelf_ledge, 0], [0, 3.0]]); // 3.0 base width
            
    translate([bx(esp) + bw(esp), by(esp), shelf_z])
        rotate([-90, 0, 0])
        linear_extrude(height = bd(esp))
            polygon(points = [[0, 0], [-shelf_ledge, 0], [0, 3.0]]);
        
    // Charge board ledges
    translate([bx(chg), by(chg), shelf_z])
        rotate([0, 90, 0])
        linear_extrude(height = bw(chg))
            polygon(points = [[0, 0], [3.0, 0], [0, shelf_ledge]]); // 3.0 base height in extrusion space
            
    translate([bx(chg), by(chg) + bd(chg), shelf_z])
        rotate([0, 90, 0])
        linear_extrude(height = bw(chg))
            polygon(points = [[0, 0], [3.0, 0], [0, -shelf_ledge]]);

    // Short internal partition wall between battery and ESP
    box_h = max([ for (b = all_bays) bh(b) ]) + wall_bottom;
    translate([bx(bat), by(bat) + bd(bat), wall_bottom])
        cube([bw(bat), 1.5, box_h / 1.5 - wall_bottom - rim_depth]);

    // Full internal partition wall between CHARGE board and ESP (Separates X axis intersection)
    // Wall runs along the right edge of the charge board (X = bx(chg) + bw(chg))
    translate([bx(chg) + bw(chg) - 1.5, by(chg) + bd(chg)/2, wall_bottom])
        cube([2.5, bd(chg)/2, box_h / 1.5 - wall_bottom - rim_depth]);
}
// BASE ASSEMBLY
module combined_base() {
    difference() {
        union() {
            shell(all_bays);
            internal_features();
        }
        base_cutouts();
    }
}

// LID ASSEMBLY
module combined_lid() {
    translate([0, 100, 50]) {
        mirror([1,0,0]){
            difference() {
                shell_lid(all_bays);
                lid_cutouts();
            }
        }
    }
}

// RENDER CALLS
combined_base();
combined_lid(); // Uncommented to show lid changes alongside base