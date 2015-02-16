epsilon=0.05;

clearance=0.3;
plate_height=125.5;
plate_width=84;
plate_width_inner=77.2;
plate_thick=2;
plate_edge_thick=1;

wall_thick=0.8;
space_under_plate=1;

case_thick=wall_thick + space_under_plate + plate_thick;
case_extra_width=20;
case_width = plate_width + case_extra_width;

cover_extra=clearance + 3;
cover_extra_thick=clearance + wall_thick;

finger_thick=20;

module magnet() {
    color("gray") cube([0.9 + clearance, 6.4 + clearance, 3.3 + clearance],center=true);
    color("blue") translate([0,0,(3+2)/2]) cube([0.9 + clearance, 6.4 + clearance, 2],center=true);
}

module plate() {
    color("silver") {
	translate([0,0,plate_thick/2]) cube([plate_width_inner, plate_height, plate_thick], center=true);
	translate([0,0,plate_edge_thick/2]) cube([plate_width, plate_height, plate_edge_thick], center=true);
    }
}

module base_block() {
    difference() {
	translate([0,0,case_thick/2]) cube([plate_width + case_extra_width, plate_height + case_extra_width, case_thick], center=true);
	
	translate([(plate_width + case_extra_width + 5)/2, 0, 0]) rotate([0,25,0])  cube([10, plate_height+ case_extra_width+ 5, 20], center=true);
	
	translate([-(plate_width + case_extra_width + 5)/2, 0, 0]) rotate([0,-25,0])  cube([10, plate_height+ case_extra_width+ 5, 20], center=true);

    }
}

module block_with_magnets() {
    difference() {
	base_block();
	translate([(plate_width + case_extra_width -7)/2, 20, case_thick-2]) rotate([0,25,0]) rotate([0,180,0])  magnet();
	translate([-(plate_width + case_extra_width -7)/2, 20, case_thick-2]) rotate([0,-25,0]) rotate([0,180,0]) magnet();
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
	base_block();
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
		translate([plate_width/2,0,case_thick + 6.8]) sphere(r=finger_thick/2, $fn=120);
	    }
	    translate([0,0,epsilon]) intersection () {
		case_rim();
		translate([-plate_width/2,0,case_thick + 6.8]) sphere(r=finger_thick/2, $fn=120);
	    }
	}
    }
}

module cover() {
    difference() {
	translate([0,-cover_extra_thick/2-epsilon,(case_thick + cover_extra_thick)/2]) cube([plate_width + case_extra_width + cover_extra, plate_height + case_extra_width + cover_extra_thick, case_thick + cover_extra_thick], center=true);
	
	minkowski() {
	    base_block();
	    sphere(r=clearance);
	}
	
	translate([(plate_width + case_extra_width -1)/2, 20, case_thick-2]) rotate([0,25,0])  rotate([0,180,0]) magnet();
	translate([-(plate_width + case_extra_width -1)/2, 20, case_thick-2]) rotate([0,-25,0]) rotate([0,180,0]) magnet();
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
    }
}

print();
//xray();

