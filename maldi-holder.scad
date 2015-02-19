epsilon=0.05;
clearance=0.25;  // clearance between moving parts.

magnet_thick= 1.5 + clearance;
magnet_long = 8   + clearance;
magnet_wide = 6   + clearance;

plate_height=125.02     + 3*clearance;
plate_width=83.07       + 3*clearance;
plate_width_inner=77.02 + 3*clearance;
plate_thick=2;
plate_edge_thick=1 + clearance;

finger_thick=20;  // approximation of a thumb :)
case_extra_height_front=4;
case_extra_height_back=4;
case_extra_width=finger_thick;

wall_thick=1.2;
space_under_plate=3.6;

case_thick=wall_thick + space_under_plate + plate_thick;

case_width = plate_width + case_extra_width;
case_height = plate_height + case_extra_height_front + case_extra_height_back;

cover_extra_wide=clearance + 4;  // Wider to accomodate dovetail and magnet.
cover_extra_thick=clearance + wall_thick;
cover_extra_height=clearance + wall_thick + magnet_thick + 0.5;  // back-magnet

side_magnets = false;
back_magnets = true;
magnet_separator=0.4;

text_thick=0.4;

// Magnet. Upright, with some extra additional space poking out the bottom,
// a pathway to slide it in.
module magnet(extra=5) {
    #translate([0,0,magnet_wide/2]) cube([magnet_thick, magnet_long, magnet_wide], center=true);
    translate([0,0,-extra/2+epsilon]) cube([magnet_thick, magnet_long, extra], center=true);
}

module back_magnet_row(count=3, distance=case_width / 3) {
    start_distance = -((count-1) * distance)/2;
    for (i = [0:1:count-1]) {
	translate([start_distance + i * distance,0,0.5]) rotate([0,0,90]) magnet();
    }
}

module plate() {
    translate([0,0,plate_thick/2]) cube([plate_width_inner, plate_height, plate_thick], center=true);
    translate([0,0,plate_edge_thick/2]) cube([plate_width, plate_height, plate_edge_thick], center=true);
}

module base_block(extra_x=0,extra_y=0,extra_z=0) {
    hull() {
	// Front part
	translate([-(plate_width + case_extra_width + extra_x)/2,(plate_height + extra_y)/2 + case_extra_height_front,0]) cube([plate_width + case_extra_width + extra_x, epsilon, case_thick+extra_z]);

	// two rounded back pillars.
	translate([(plate_width+extra_x)/2, -(plate_height-case_extra_width+extra_y)/2-case_extra_height_back, 0]) cylinder(r=case_extra_width/2, h=case_thick+extra_z, $fn=60);
	
	translate([-(plate_width+extra_x)/2, -(plate_height-case_extra_width+extra_y)/2-case_extra_height_back, 0]) cylinder(r=case_extra_width/2, h=case_thick+extra_z, $fn=60);
    }
}

// Base block with the dovetail cut.
module base_dovetail() {
    difference() {
	base_block();

	// substract some wedges.
	translate([(plate_width + case_extra_width + 7)/2, 0, 0]) rotate([0,25,0])  cube([10, case_height+ 5, 20], center=true);
	
	translate([-(plate_width + case_extra_width + 7)/2, 0, 0]) rotate([0,-25,0])  cube([10, case_height + 5, 20], center=true);

    }

    intersection() {
	translate([-100,(plate_height+finger_thick-4)/2 + case_extra_height_front,case_thick/2]) rotate([0,90,0]) cylinder(r=finger_thick/2,h=200,$fn=400);
		    
	// Intersect with base block to keep cylinder in alotted space.
	translate([0,-cover_extra_height,0]) base_block(extra_y=cover_extra_height+15,extra_x=cover_extra_wide,extra_z=cover_extra_thick);
    }
}

module block_with_magnets() {
    difference() {
	base_dovetail();
	
	if (side_magnets) {
	    translate([(plate_width + case_extra_width - 8)/2, 20, 0]) rotate([0,25,0]) translate([0,0,0.8]) magnet();
	    translate([-(plate_width + case_extra_width - 8)/2, 20, 0]) rotate([0,-25,0]) translate([0,0,0.8]) magnet();
	}
	if (back_magnets) {
	    translate([0, -(plate_height - magnet_thick)/2 - case_extra_height_back + magnet_separator,0]) back_magnet_row();
	}
    }
}

module base_case() {
    difference() {
	block_with_magnets();
	translate([0,0,case_thick - (plate_thick + space_under_plate)/2 + epsilon]) cube([plate_width_inner, plate_height, plate_thick + space_under_plate], center=true);
    }
}

// Everything with the middle part cut out.
module case_rim(extra=epsilon) {
    difference() {
	base_dovetail();
	cube([plate_width-extra, plate_height, 20], center=true);
    }
}


module case() {
    difference() {
	base_case();
	translate([0,0,case_thick+epsilon]) rotate([0,180,0]) plate();
	union() {
	    translate([0,0,epsilon]) intersection () {
		case_rim(extra=3);
		translate([plate_width/2,0,case_thick + 5]) scale([1,1.5,1]) sphere(r=finger_thick/2, $fn=120);
	    }
	    translate([0,0,epsilon]) intersection () {
		case_rim(extra=3);
		translate([-plate_width/2,0,case_thick + 5]) scale([1,1.5,1]) sphere(r=finger_thick/2, $fn=120);
	    }
	}

	// Emboss to not be in the way while stacking.
	translate([5,plate_height/2+case_extra_height_front + 4.6,0]) linear_extrude(height=text_thick) rotate([0,180,180]) text("ksm · hz · 2015", size=5, font="Arial:style=Bold");
    }

    // Instructions
    if (text_thick > 0) {
	translate([0,plate_height/2,wall_thick-epsilon]) linear_extrude(height = text_thick) {
	    rotate([0,0,-90]) {
		text("Place upside-down:", size=8, $fn=30);
		translate([0,-12,0]) text("Matrix towards this cavity.", size=8, $fn=30);
	    }
	}
    }
}

module outer_cover() {
    translate([0,-cover_extra_height/2-epsilon,0]) base_block(extra_y=cover_extra_height,extra_x=cover_extra_wide,extra_z=cover_extra_thick);
}

module cover() {
    difference() {
	outer_cover();
	
	minkowski() {
	    base_dovetail();
	    sphere(r=clearance);
	}

	if (side_magnets) {
	    translate([(plate_width + case_extra_width)/2, 20, 0]) rotate([0,25,0]) translate([0,0,0.8]) magnet();
	    translate([-(plate_width + case_extra_width)/2, 20, 0]) rotate([0,-25,0]) translate([0,0,0.8]) magnet();
	}

	if (back_magnets) {
	    translate([0, -(plate_height + magnet_thick)/2 - clearance - case_extra_height_back - magnet_separator,0]) back_magnet_row();
	}
    }
}

module print(do_case=true, do_cover=true) {
    if (do_case) case();
    if (do_cover) translate([case_width + cover_extra_wide + 3, 0, case_thick + cover_extra_thick ]) rotate([0,180,0]) cover();
}

//magnet();
//print();
//cover();
//magnet();

module xray() {
    difference() {
	union() {
	    cover();
	    case();
	}
	
	translate([0,20,-20]) cube([100,100,100]);
	translate([-100,0,-20]) cube([100,100,100]);
    }
}

print(do_case=true, do_cover=true);
