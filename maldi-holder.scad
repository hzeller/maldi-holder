epsilon=0.05;
clearance=0.25;  // clearance between moving parts.

plate_height=125.02     + 2*clearance;
plate_width=83.07       + 2*clearance;
plate_width_inner=77.02 + 2*clearance;
plate_thick=2;
plate_edge_thick=1 + clearance;

finger_thick=20;  // approximation of a thumb :)
case_extra_height=5;
case_extra_width=finger_thick;

wall_thick=1;
space_under_plate=4;

case_thick=wall_thick + space_under_plate + plate_thick;
case_width = plate_width + case_extra_width;

cover_extra_wide=clearance + 8;  // Wider to accomodate dovetail and magnet.
cover_extra_thick=clearance + wall_thick;

magnet_thick= 1.5 + clearance;
magnet_long = 8   + clearance;
magnet_wide = 6   + clearance;

// Magnet. Upright, with some extra additional space poking out the bottom,
// a pathway to slide it in.
module magnet(extra=5) {
    color("gray") #translate([0,0,magnet_wide/2]) cube([magnet_thick, magnet_long, magnet_wide], center=true);
    color("blue") translate([0,0,-extra/2+epsilon]) cube([magnet_thick, magnet_long, extra], center=true);
}

module plate() {
    color("silver") {
	translate([0,0,plate_thick/2]) cube([plate_width_inner, plate_height, plate_thick], center=true);
	translate([0,0,plate_edge_thick/2]) cube([plate_width, plate_height, plate_edge_thick], center=true);
    }
}

module base_block(extra_x=0,extra_y=0,extra_z=0) {
    hull() {
	translate([-(plate_width + case_extra_width + extra_x)/2,(plate_height+case_extra_height + extra_y)/2,0]) cube([plate_width + case_extra_width + extra_x, epsilon, case_thick+extra_z]);
	color("red") translate([(plate_width+extra_x)/2, -(plate_height-case_extra_width+case_extra_height+extra_y)/2, 0]) cylinder(r=case_extra_width/2, h=case_thick+extra_z, $fn=60);
	translate([-(plate_width+extra_x)/2, -(plate_height-case_extra_width+case_extra_height+extra_y)/2, 0]) cylinder(r=case_extra_width/2, h=case_thick+extra_z, $fn=60);
    }
}

// Base block with the dovetail cut.
module base_dovetail() {
    intersection() {
	union() {
	    difference() {
		base_block();

		// substract some wedges.
		translate([(plate_width + case_extra_width + 7)/2, 0, 0]) rotate([0,25,0])  cube([10, plate_height + case_extra_height+ 5, 20], center=true);
	
		translate([-(plate_width + case_extra_width + 7)/2, 0, 0]) rotate([0,-25,0])  cube([10, plate_height+ case_extra_height+ 5, 20], center=true);

	    }
	    
	    translate([-100,(plate_height+case_extra_height+finger_thick-1)/2,case_thick/2]) rotate([0,90,0]) cylinder(r=finger_thick/2,h=200,$fn=60);
	}
	translate([0,-cover_extra_thick/2-epsilon,0]) base_block(extra_y=cover_extra_thick+15,extra_x=cover_extra_wide,extra_z=cover_extra_thick);
    }
}

module block_with_magnets() {
    difference() {
	base_dovetail();
	translate([(plate_width + case_extra_width - 8)/2, 20, 0]) rotate([0,25,0]) translate([0,0,0.8]) magnet();
	translate([-(plate_width + case_extra_width - 8)/2, 20, 0]) rotate([0,-25,0]) translate([0,0,0.8]) magnet();
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
    }
}

module outer_cover() {
    translate([0,-cover_extra_thick/2-epsilon,0]) base_block(extra_y=cover_extra_thick,extra_x=cover_extra_wide,extra_z=cover_extra_thick);
}

module cover() {
    difference() {
	outer_cover();
	
	minkowski() {
	    base_dovetail();
	    sphere(r=clearance);
	}
	
	translate([(plate_width + case_extra_width)/2, 20, 0]) rotate([0,25,0]) translate([0,0,0.8]) magnet();
	translate([-(plate_width + case_extra_width)/2, 20, 0]) rotate([0,-25,0]) translate([0,0,0.8]) magnet();
    }
}

module print() {
    case();
    translate([case_width + cover_extra_wide + 4, 0, case_thick + cover_extra_thick ]) rotate([0,180,0]) cover();
}

//magnet();
//print();
//cover();
//magnet();

module xray() {
    difference() {
	union() {
	    color("red") cover();
	    color("gray") case();
	}
	
	translate([0,20,-20]) cube([100,100,100]);
	translate([-100,0,-20]) cube([100,100,100]);
    }
}

//base_dovetail();
//print();
//xray();
//base_block(extra_y=0);

print();
