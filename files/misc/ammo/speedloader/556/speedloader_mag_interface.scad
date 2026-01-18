// PMAG Speedloader - Magazine Interface Section
// All dimensions in mm

// === PARAMETERS ===

// Wall thickness and rim
wall_thickness = 3.5;
rim_width = 3.048;  // Width of rim beyond notches
outer_bevel = 2.5;       // Bevel size on outer corners

// Rectangular notch (at one end) - centered on cavity edge
rect_notch_width = 12;        // Width of notch across the opening
rect_notch_thickness = 7.9;     // Thickness along length (half in rim, half in cavity)
rect_notch_corner_radius = 1.575; // Radius for rounded corners on the rectangle itself

// Circular notch (at other end) - centered on opposite cavity edge, offset along length
circ_notch_diameter = 8;
circ_notch_length_offset = 2.4;  // Offset from cavity edge along length direction (inward)

// Inner cavity dimensions (the main magazine opening)
inner_length = 60.909;       // Length of cavity
inner_width = 23.698;        // Width of cavity
inner_depth = 38.1;        // Depth from bottom to top of cavity
inner_corner_radius = 1.575;  // Radius for rounded inside edges
bottom_edge_radius = 2;      // Radius for rounded edges at bottom of cavity (left/right sides)

// Round cutout dimensions (for ammunition)
casing_base = 10;            // Width of rectangular base
casing_height = 43;          // Height of rectangular base
base_chamfer_size = 0.635;   // Base length of equilateral triangle chamfer at bottom corners
trap_short_base = 3;         // Short base of trapezoid (point)
trap_long_base = 10;         // Long base of trapezoid (lines up with casing)
trap_leg_length = 16.06;        // Length of trapezoid leg
trap_angle = 77.5;           // Angle of trapezoid

// Round cutout position offsets
round_offset_x = 0;          // X offset from center (positive = right, negative = left)
round_offset_y = -1;          // Y offset along length (positive = toward circular notch, negative = toward rect notch)
round_offset_z = 0;          // Z offset (positive = higher/up, negative = lower/down)

// Pickup clip cutout (for loading tool)
clip_width = 13.109;         // Width of clip cutout
clip_height = 7.62;          // Height (depth in Z) of clip cutout
clip_overlap = -2.851;       // Overlap with round cutout (negative = extends below round cutout)
clip_rim_thickness = 3;      // Thickness of rim left between clip cutout and inner cavity

// Speedloader extension
speedloader_depth = 336;     // Total depth of speedloader below mag interface
trap_height = trap_leg_length * sin(trap_angle);  // Calculated trapezoid height
entrance_chamfer = 8;        // Depth of chamfer at bottom entrance (softens edges for insertion)
entrance_flare = 1.8;        // Scale factor for entrance flare (how much wider the opening gets)

// Calculated outer dimensions (ensures rim_width beyond all features)
outer_width = max(inner_width + 2*rim_width, rect_notch_width + 2*rim_width, circ_notch_diameter + 2*rim_width);
outer_length = inner_length + rect_notch_thickness/2 + (circ_notch_diameter/2 - circ_notch_length_offset) + 2*rim_width;
outer_height = inner_depth + wall_thickness;
inner_height = inner_depth + 1;  // Slightly taller to cut through cleanly

// === MODULES ===

module beveled_cube(size, bevel) {
    // Create a cube with chamfered vertical corners only - diagonal cuts at corners
    hull() {
        // Place cylinders at each corner
        for(x = [bevel, size[0] - bevel]) {
            for(y = [bevel, size[1] - bevel]) {
                translate([x, y, 0])
                    cylinder(r=bevel, h=size[2], $fn=4);  // $fn=4 makes it diamond-shaped for chamfer
            }
        }
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

module bottom_edge_fillet_left(r, l) {
    // Creates a quarter-round concave fillet for left bottom edge
    // Curved surface faces right (into cavity)
    difference() {
        cube([r, l, r]);
        translate([r, 0, r])
            rotate([-90, 0, 0])
                cylinder(r=r, h=l);
    }
}

module bottom_edge_fillet_right(r, l) {
    // Creates a quarter-round concave fillet for right bottom edge
    // Curved surface faces left (into cavity)
    difference() {
        cube([r, l, r]);
        translate([0, 0, r])
            rotate([-90, 0, 0])
                cylinder(r=r, h=l);
    }
}

module round_profile() {
    // Creates 2D profile of a round (ammunition)
    // Rectangle base with chamfered bottom corners + trapezoid point

    // Calculate chamfer height for equilateral triangle
    chamfer_height = base_chamfer_size * sqrt(3) / 2;

    union() {
        // Rectangle base with chamfered bottom corners
        polygon([
            // Bottom left, chamfered
            [-casing_base/2 + base_chamfer_size, -casing_height/2],
            [-casing_base/2, -casing_height/2 + chamfer_height],
            // Left side
            [-casing_base/2, casing_height/2],
            // Top left
            [-casing_base/2, casing_height/2],
            // Top right
            [casing_base/2, casing_height/2],
            // Right side
            [casing_base/2, -casing_height/2 + chamfer_height],
            // Bottom right, chamfered
            [casing_base/2 - base_chamfer_size, -casing_height/2]
        ]);

        // Trapezoid point on top
        translate([0, casing_height/2 + trap_height/2, 0])
        polygon([
            [-trap_long_base/2, -trap_height/2],
            [trap_long_base/2, -trap_height/2],
            [trap_short_base/2, trap_height/2],
            [-trap_short_base/2, trap_height/2]
        ]);
    }
}

// === MAIN MODEL ===

$fn = 64;  // Resolution for curves

union() {
    difference() {
        // Outer shell with beveled edges + extension below
        union() {
            beveled_cube([outer_width, outer_length, outer_height], outer_bevel);
            translate([0, 0, -speedloader_depth])
                beveled_cube([outer_width, outer_length, speedloader_depth], outer_bevel);
        }

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

    // Round cutout hole going down through entire speedloader
    // Centered in cavity, rectangle base at rectangular notch side, trapezoid at circular notch side
    translate([outer_width/2 + round_offset_x,
               rim_width + rect_notch_thickness/2 + inner_length/2 - trap_height/2 + round_offset_y,
               outer_height + round_offset_z]) {
        scale([1, 1, -1])
            linear_extrude(height = speedloader_depth + outer_height+0.01)
                round_profile();
    }

    // Pickup clip cutout - rectangular slot at bottom of round cutout, going down parallel to round hole
    // Positioned to leave clip_rim_thickness between it and the inner cavity, extends all the way through bottom
    translate([outer_width/2 - clip_width/2,
               rim_width + rect_notch_thickness/2 + inner_length/2 - trap_height/2 + round_offset_y - casing_height/2 + clip_overlap,
               wall_thickness - clip_rim_thickness]) {
        translate([0, 0, -(wall_thickness - clip_rim_thickness + speedloader_depth + 0.1)])
            cube([clip_width, clip_height, wall_thickness - clip_rim_thickness + speedloader_depth + 0.1]);
    }

    // Entrance chamfer for round cutout - creates dramatic funnel at bottom entrance for easier insertion
    // Wide at bottom (entrance), narrows to normal size going up
    translate([outer_width/2 + round_offset_x,
               rim_width + rect_notch_thickness/2 + inner_length/2 - trap_height/2 + round_offset_y,
               -speedloader_depth]) {
        scale([entrance_flare, entrance_flare, 1])
            linear_extrude(height = entrance_chamfer, scale = 1/entrance_flare)
                round_profile();
    }

    // Entrance chamfer for clip cutout - creates dramatic flare on rectangular entrance
    // Wide at bottom, narrows to normal size going up
    translate([outer_width/2 - clip_width/2,
               rim_width + rect_notch_thickness/2 + inner_length/2 - trap_height/2 + round_offset_y - casing_height/2 + clip_overlap,
               -speedloader_depth]) {
        hull() {
            translate([-(clip_width * (entrance_flare - 1) / 2), -(clip_height * (entrance_flare - 1) / 2), 0])
                cube([clip_width * entrance_flare, clip_height * entrance_flare, 0.01]);
            translate([0, 0, entrance_chamfer])
                cube([clip_width, clip_height, 0.01]);
        }
    }
    }

    // Bottom edge fillets on left and right sides of cavity (added material for concave curve)
    // Left side bottom edge - fillet fills the corner inward (curved surface faces right)
    translate([(outer_width - inner_width)/2,
               rim_width + rect_notch_thickness/2,
               wall_thickness]) {
        bottom_edge_fillet_left(bottom_edge_radius, inner_length);
    }

    // Right side bottom edge - fillet fills the corner inward (curved surface faces left)
    translate([(outer_width + inner_width)/2 - bottom_edge_radius,
               rim_width + rect_notch_thickness/2,
               wall_thickness]) {
        bottom_edge_fillet_right(bottom_edge_radius, inner_length);
    }
}
