epsilon=0.05;

clearance=0.3;
plate_height=125.5;
plate_width=84;
plate_width_inner=77.2;
plate_thick=2;
plate_edge_thick=1;

finger_thick=20;
case_extra_height=5;
case_extra_width=finger_thick;

wall_thick=0.8;
space_under_plate=3;

case_thick=wall_thick + space_under_plate + plate_thick;
case_width = plate_width + case_extra_width;

cover_extra_wide=clearance + 4.5;
cover_extra_thick=clearance + wall_thick;


module magnet() {
    color("gray") cube([0.9 + clearance, 6.4 + clearance, 3.3 + clearance],center=true);

    // Additional stuff to cut a pathway to the outside
    color("blue") translate([0,0,(3+5)/2]) cube([0.9 + clearance, 6.4 + clearance, 5],center=true);
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
    difference() {
	base_block();

	// substract some wedges.
	translate([(plate_width + case_extra_width + 7)/2, 0, 0]) rotate([0,25,0])  cube([10, plate_height + case_extra_height+ 5, 20], center=true);
	
	translate([-(plate_width + case_extra_width + 7)/2, 0, 0]) rotate([0,-25,0])  cube([10, plate_height+ case_extra_height+ 5, 20], center=true);

    }
}

module block_with_magnets() {
    difference() {
	base_dovetail();
	translate([(plate_width + case_extra_width - 4)/2, 20, case_thick-2.5]) rotate([0,25,0]) rotate([0,180,0])  magnet();
	translate([-(plate_width + case_extra_width - 4)/2, 20, case_thick-2.5]) rotate([0,-25,0]) rotate([0,180,0]) magnet();
    }
}

module base_case() {
    difference() {
	block_with_magnets();
	translate([0,0,case_thick - (plate_thick + space_under_plate)/2 + epsilon]) cube([plate_width_inner, plate_height, plate_thick + space_under_plate], center=true);
    }
}

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
		case_rim();
		translate([plate_width/2,0,case_thick + 5]) scale([1,1.5,1]) sphere(r=finger_thick/2, $fn=120);
	    }
	    translate([0,0,epsilon]) intersection () {
		case_rim();
		translate([-plate_width/2,0,case_thick + 5]) scale([1,1.5,1]) sphere(r=finger_thick/2, $fn=120);
	    }
	}
    }
}

module cover() {
    difference() {
	//translate([0,-cover_extra_thick/2-epsilon,(case_thick + cover_extra_thick)/2]) cube([plate_width + case_extra_width + cover_extra_wide, plate_height + case_extra_height + cover_extra_thick, case_thick + cover_extra_thick], center=true);
	translate([0,-cover_extra_thick/2-epsilon,0]) base_block(extra_y=cover_extra_thick,extra_x=cover_extra_wide,extra_z=cover_extra_thick);
	
	minkowski() {
	    base_dovetail();
	    sphere(r=clearance);
	}
	
	translate([(plate_width + case_extra_width+1.5)/2, 20, case_thick-3.5]) rotate([0,25,0])  rotate([0,180,0]) magnet();
	translate([-(plate_width + case_extra_width+1.5)/2, 20, case_thick-3.5]) rotate([0,-25,0]) rotate([0,180,0]) magnet();
    }
}

module print() {
    case();
    translate([case_width + 5, 0, case_thick + cover_extra_thick ]) rotate([0,180,0]) cover();
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
print();
//xray();
//base_block(extra_y=0);
