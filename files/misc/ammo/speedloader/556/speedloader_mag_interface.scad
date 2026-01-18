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
clip_junction_fillet = 2;    // Fillet radius where clip cutout meets round cutout (improves printability)

// Calculated outer dimensions (ensures rim_width beyond all features)
outer_width = max(inner_width + 2*rim_width, rect_notch_width + 2*rim_width, circ_notch_diameter + 2*rim_width);
outer_length = inner_length + rect_notch_thickness/2 + (circ_notch_diameter/2 - circ_notch_length_offset) + 2*rim_width;
outer_height = inner_depth + wall_thickness;
inner_height = inner_depth + 1;  // Slightly taller to cut through cleanly

// === CLIP PARAMETERS ===
// Pickup clip dimensions (from technical drawing)
clip_outer_width = 12;           // Outer width at base (not including chamfers)
clip_outer_height = 6.2;         // Outer height
clip_length = 289.5;             // Length of clip extrusion
clip_corner_chamfer = 0.866;     // Chamfer size on outer corners

// Inner cavity dimensions
clip_cavity_bottom_width = 8.4;  // Inner cavity width at bottom
clip_cavity_wall_angle = 135;    // Angle of cavity walls from horizontal
clip_bottom_radius = 0.919;      // Radius at bottom corners of cavity

// Gripping notch (inward projection near top)
clip_top_opening = 1.150;        // Width of top opening
clip_notch_width = 0.962;        // Width at gripping notch
clip_notch_angle = 158;          // Angle of notch section
clip_notch_length = 1.602;       // Length of angled notch section
clip_notch_radius = 0.62;        // Radius at notch transition
clip_notch_depth = 0.6;          // Depth of notch step
clip_dimension = 0.635;          // Additional dimension

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

module clip_profile() {
    // Creates 2D profile using exact vertex positions
    // Your coordinates, then mirrored across x = 6.5

    polygon([
        // Left side (your exact coordinates)
        [0.5, 0],
        [0, 0.5],
        [0, 6.7],
        [0.5, 7.2],
        [1.65, 7.2],
        [1.65, 6.238],
        [2.25, 4.753],
        [2.25, 4.133],
        [1.65, 4.133],
        [1.65, 3.498],
        [2.3, 2.848],
        [6.5, 2.848],
        [6.5, 0],
        [0.5, 0],
        // Right side (mirrored across x=6.5, so x' = 13 - x)
        [12.5, 0],
        [6.5, 0],
        [6.5, 2.848],
        [10.7, 2.848],
        [11.35, 3.498],
        [11.35, 4.133],
        [10.75, 4.133],
        [10.75, 4.753],
        [11.35, 6.238],
        [11.35, 7.2],
        [12.5, 7.2],
        [13, 6.7],
        [13, 0.5],
        [12.5, 0]
    ]);
}

module pickup_clip() {
    // Creates the complete pickup clip by extruding the profile
    // Plus short cylinders at one end and grip extension at other end

    grip_length = 16;  // Length of grip extension
    grip_height = 2.848;  // Height of grip (bottom section only)

    union() {
        linear_extrude(height = clip_length)
            clip_profile();

        // Left cylinder at one end - tangent to top edge, 2.5mm long
        // Center at y = 7.2 - 0.6 = 6.6 to be tangent
        translate([1.65, 7.2, 0.6])
            rotate([90, 0, 0])
                cylinder(d=1.2, h=2.5);

        // Right cylinder at one end
        translate([11.35, 7.2, 0.6])
            rotate([90, 0, 0])
                cylinder(d=1.2, h=2.5);

        // Grip extension with triangular grooves
        difference() {
            // GRIP BASE
            translate([0, 0, clip_length])
                linear_extrude(height = grip_length)
                    polygon([
                        [0.5, 0],
                        [12.5, 0],
                        [13, 0.5],
                        [13, grip_height],
                        [0, grip_height],
                        [0, 0.5]
                    ]);

            // Triangular groove cutters
            for (i = [0 : 3]) {
                translate([13, grip_height, clip_length + grip_length - 10 + i * 3 - 1.4])
                    rotate([0, -90, 0])
                        linear_extrude(height = 13)
                            polygon([
                                [0, 0],
                                [2, 0],
                                [1, -1.5]
                            ]);
            }
        }
    }
}

module speedloader() {
    // Creates the complete speedloader with magazine interface
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

    // Junction chamfers where clip cutout meets round cutout - ADDS material to support internal corners
    // These run the full length of the speedloader along the Z axis, improving printability with 45-degree slopes
    // Left side chamfer - at the +Y edge of clip cutout where it meets the round cutout
    translate([outer_width/2 - casing_base/2 - clip_junction_fillet,
               rim_width + rect_notch_thickness/2 + inner_length/2 - trap_height/2 + round_offset_y - casing_height/2 + clip_overlap + clip_height - clip_junction_fillet,
               wall_thickness - clip_rim_thickness]) {
        translate([0, 0, -(wall_thickness - clip_rim_thickness + speedloader_depth - entrance_chamfer)])
            rotate([0, 0, 45])
                cube([clip_junction_fillet * sqrt(2), clip_junction_fillet * sqrt(2), wall_thickness - clip_rim_thickness + speedloader_depth - entrance_chamfer]);
    }

    // Right side chamfer - at the +Y edge of clip cutout where it meets the round cutout
    translate([outer_width/2 + casing_base/2,
               rim_width + rect_notch_thickness/2 + inner_length/2 - trap_height/2 + round_offset_y - casing_height/2 + clip_overlap + clip_height,
               wall_thickness - clip_rim_thickness]) {
        translate([0, 0, -(wall_thickness - clip_rim_thickness + speedloader_depth - entrance_chamfer)])
            rotate([0, 0, -45])
                cube([clip_junction_fillet * sqrt(2), clip_junction_fillet * sqrt(2), wall_thickness - clip_rim_thickness + speedloader_depth - entrance_chamfer]);
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
}

// === RENDER SELECTION ===
// Comment/uncomment to choose which part to render

$fn = 64;  // Resolution for curves

// speedloader();
pickup_clip();
