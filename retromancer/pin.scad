$fn=64;

module pin() {
    PIN_HEIGHT = 1.0;
    PIN_DIAMETER = 4.9;
    PIN_HOLE_DIAMETER = 3.3;
    BASE_HEIGHT = 2;
    BASE_DIAMETER = 7.8;

    difference() {
        union() {
            translate([0, 0, 0]) cylinder(d=PIN_DIAMETER, PIN_HEIGHT);
            translate([0, 0, -BASE_HEIGHT]) cylinder(d=BASE_DIAMETER, BASE_HEIGHT);
        }
        translate([0, 0, -25]) cylinder(d=PIN_HOLE_DIAMETER, 50);
    }
}

pin();
