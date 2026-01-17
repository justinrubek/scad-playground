// PMAG Speedloader - Magazine Interface Section
// All dimensions in mm

// === PARAMETERS ===

// Wall thickness and rim
wall_thickness = 3.5;
rim_width = 5;  // Width of rim beyond notches
outer_bevel = 2.5;       // Bevel size on outer corners

// Rectangular notch (at one end) - centered on cavity edge
rect_notch_width = 12;        // Width of notch across the opening
rect_notch_thickness = 6;     // Thickness along length (half in rim, half in cavity)
rect_notch_corner_radius = 1.5; // Radius for rounded corners on the rectangle itself

// Circular notch (at other end) - centered on opposite cavity edge, offset along length
circ_notch_diameter = 9;
circ_notch_length_offset = 2;  // Offset from cavity edge along length direction (inward)

// Inner cavity dimensions (the main magazine opening)
inner_length = 90;       // Length of cavity
inner_width = 28;        // Width of cavity
inner_depth = 17;        // Depth from bottom to top of cavity
inner_corner_radius = 3;  // Radius for rounded inside edges

// Calculated outer dimensions (ensures rim_width beyond all features)
outer_width = max(inner_width + 2*rim_width, rect_notch_width + 2*rim_width, circ_notch_diameter + 2*rim_width);
outer_length = inner_length + rect_notch_thickness/2 + (circ_notch_diameter/2 - circ_notch_length_offset) + 2*rim_width;
outer_height = inner_depth + wall_thickness;
inner_height = inner_depth + 1;  // Slightly taller to cut through cleanly

// === MODULES ===

module beveled_cube(size, bevel) {
    // Create a cube with beveled/chamfered edges
    hull() {
        translate([bevel, bevel, 0])
            cube([size[0] - 2*bevel, size[1] - 2*bevel, size[2]]);
        translate([0, bevel, bevel])
            cube([size[0], size[1] - 2*bevel, size[2] - 2*bevel]);
        translate([bevel, 0, bevel])
            cube([size[0] - 2*bevel, size[1], size[2] - 2*bevel]);
    }
}

module internal_corner_fillet(r, h) {
    // Creates a quarter-round fillet cutter for internal corners
    // Cylinder at origin (0,0)
    difference() {
        cube([r, r, h]);
        cylinder(r=r, h=h);
    }
}

module internal_corner_fillet_right(r, h) {
    // Creates a quarter-round fillet cutter for right side corner
    // Cylinder at (r, 0) - cube extends in -X, +Y from corner
    difference() {
        cube([r, r, h]);
        translate([r, 0, 0])
            cylinder(r=r, h=h);
    }
}

// === MAIN MODEL ===

$fn = 64;  // Resolution for curves

difference() {
    // Outer shell with beveled edges
    beveled_cube([outer_width, outer_length, outer_height], outer_bevel);

    // Inner cavity with rounded edges
    // Positioned so there's rim_width + rect_notch_thickness/2 from front edge
    translate([(outer_width - inner_width)/2,
               rim_width + rect_notch_thickness/2,
               wall_thickness]) {
        hull() {
            // Create rounded corners using cylinders at each corner
            for(x = [inner_corner_radius, inner_width - inner_corner_radius]) {
                for(y = [inner_corner_radius, inner_length - inner_corner_radius]) {
                    translate([x, y, 0])
                        cylinder(r=inner_corner_radius, h=inner_height);
                }
            }
        }
    }

    // Rectangular notch at one end - centered on cavity front edge (half in rim, half in cavity)
    translate([outer_width/2 - rect_notch_width/2,
               rim_width,  // Centered on cavity front edge
               wall_thickness]) {
        hull() {
            // Create rounded corners with cylinders at each corner
            for(x = [rect_notch_corner_radius, rect_notch_width - rect_notch_corner_radius]) {
                for(y = [rect_notch_corner_radius, rect_notch_thickness - rect_notch_corner_radius]) {
                    translate([x, y, 0])
                        cylinder(r=rect_notch_corner_radius, h=inner_height);
                }
            }
        }
    }

    // Circular notch at other end - on opposite cavity edge, offset inward along length
    translate([outer_width/2,  // Centered along width
               rim_width + rect_notch_thickness/2 + inner_length - circ_notch_length_offset,  // On cavity back edge, offset inward
               wall_thickness]) {
        cylinder(d=circ_notch_diameter, h=inner_height);
    }

    // Internal corner fillets where rectangular notch side walls meet cavity front edge
    // Left corner
    translate([outer_width/2 - rect_notch_width/2 - rect_notch_corner_radius,
               rim_width + rect_notch_thickness/2 - rect_notch_corner_radius,
               wall_thickness]) {
        rotate([0, 0, 0])
            internal_corner_fillet(rect_notch_corner_radius, inner_height);
    }

    // Right corner
    translate([outer_width/2 + rect_notch_width/2,
               rim_width + rect_notch_thickness/2 - rect_notch_corner_radius,
               wall_thickness]) {
        internal_corner_fillet_right(rect_notch_corner_radius, inner_height);
    }
}
