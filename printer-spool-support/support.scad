$fn=64;

module upper() {
    difference() {
        cube([20, 20, 5.9], center = true);
        cylinder(d=10.1, h=6, center = true);
    }
}

module lower() {
    // rotate([0,0,4]) translate([10, 0, 0]) cube([10, 30, 10], center = true);
    difference() {
        cube([30, 20, 5.9], center = true);
        union() {
            cylinder(d=10.1, h=6, center = true);
            rotate([0,0,9]) translate([16.5, 0, 0]) cube([10, 30, 6], center = true);
            translate([-15, 0, 0]) cube([10, 30, 6], center = true);
        }
    }
}

upper();

//lower();
