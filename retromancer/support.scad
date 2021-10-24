use <anybeam.scad>

$fn=64;


PI_HOLE_D_L = 58; // 61.5 - 3.5
PI_HOLE_D_W = 49; // 52.5 - 3.5

FRAME_W = 80;
FRAME_L = 56;

HOLE_DISTANCE = (FRAME_W - PI_HOLE_D_W) / 2; // 15.5
HOLE_STEP = (FRAME_L - PI_HOLE_D_L) / 2; // 1

HOLE_D = 3;
BEAM_LENGTH = HOLE_DISTANCE - (8 - 1);
BEAM_W = 8;
BEAM_H = 4;

SUPPORT_D = 5;
SUPPORT_H = 1;

module support() {
    translate([-4,0,4]) anybeam(["OO"]);
    translate([HOLE_STEP,0,0]) difference() {
        union() {
            translate([0, HOLE_DISTANCE / 2, BEAM_H / 2]) cube([BEAM_W,BEAM_LENGTH,BEAM_H], center = true);
            translate([0, HOLE_DISTANCE - 2, BEAM_H / 2]) cube([BEAM_W,4,BEAM_H], center = true);
            translate([0, HOLE_DISTANCE, BEAM_H / 2]) cylinder(d=8, h=BEAM_H, center = true);
            translate([0, HOLE_DISTANCE, (BEAM_H + SUPPORT_H) / 2]) cylinder(d=SUPPORT_D, h=BEAM_H + SUPPORT_H, center = true);
        }
        union() {
            translate([0, HOLE_DISTANCE, BEAM_H / 2]) cylinder(d=HOLE_D, h=BEAM_H * 2, center = true);
        }

    }
}

module moved_support() {
    translate([10, 7, 0]) support();
}

module two_supports() {
    mirror([0,0,0]) moved_support();
    mirror([0,1,0]) moved_support();
}

//two_supports();

module four_supports() {
    mirror([0,0,0]) two_supports();
    mirror([1,0,0]) two_supports();
}

four_supports();