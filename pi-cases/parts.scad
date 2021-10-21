use <pi-holes.scad>
use <roundedcube.scad>

hInner = 27;
hBase = 4;
hPiStand = 5;

hTop = 4;
hInnerStep = 2;
corner = 8;
extIn = 2;
extOut = 2;
extSpace = 2;
extAll = extIn + extOut;
extAllSpace = extAll + extSpace;
thick = 2;

hPiBoard = 1.25;

hTunerStand = 10.5;
hTunerTop = (hInner - (hPiStand + hTunerStand + hPiBoard + hPiBoard));
hPiTopStand = (hInner - (hPiStand + hPiBoard));

hCaseSpacer = 20;

hBetweenCases = 25;

module piBase(board="3B") {
    piPlate(board, ext = extAllSpace, h = thick);
    piStands(board, height=hPiStand, preview=false);
    piPlatePartialWalls(board=board, ext=extAllSpace, thick=extOut, h=hBase, size=corner, top=0);
    piPlatePartialWalls(board=board, ext=extAllSpace-extSpace, thick=extOut, h=hBase-hInnerStep, size=corner-extOut, top=0);
    piPlateCorners(board=board, ext=extAllSpace, thick=extOut, h=hInner, size=corner, top=0);
}

module piTop(board="3B") {
    piPlate(board, ext = extAllSpace, h = thick);
    piPlatePartialWalls(board=board, ext=extAllSpace, thick=extOut, h=hTop, size=corner, top=2);
    piPlatePartialWalls(board=board, ext=extAllSpace-extSpace, thick=extIn, h=hTop-hInnerStep, size=corner-extOut, top=2);
    piPlateCorners(board=board, ext=extAllSpace-extOut, thick=extIn, h=hInner, size=corner-2.1, top=2);
}

module piBase3B() {
    diskX = 10;
    diskW = 3;
    diskD = hBase - 0.5;

    difference() {
        piBase("3B");
        translate([diskX, -30, hBase - diskD]) cube([diskW, 100, diskD + 1]);
        translate([piBoardDim("3B")[0] - (diskX + diskW), -30, hBase - diskD]) cube([diskW, 100, diskD + 1]);
    }

}

module piTop3B() {
    board = "3B";
    hole = 15;
    dx = piBoardDim(board)[0];
    dy = piBoardDim(board)[1];
    dyZero = piBoardDim("Zero")[1];

    antennaHoleD = 3;
    antennaX = 65;
    antennaY0 = 12;
    antennaY1 = antennaY0 - 7.5;
    antennaDX = 10;
    antennaDY = 8;

    fanHoleD = 3;
    fanD = 24;
    fanR = fanD / 2;
    fanCross = 3;
    fanX = 39;
    fanY = 16;

    translate([fanX, fanY, -thick/2]) cube([fanD, fanCross, thick], true);
    translate([fanX, fanY, -thick/2]) cube([fanCross, fanD, thick], true);

    difference() {
        piTop(board);
        union() {
            translate([antennaDX, antennaDY, -25]) cylinder(d=antennaHoleD, 50);
            translate([antennaDX, antennaDY + antennaY0, -25]) cylinder(d=antennaHoleD, 50);
            translate([antennaDX + antennaX, antennaDY + antennaY0, -25]) cylinder(d=antennaHoleD, 50);
            translate([antennaDX + antennaX, antennaDY + antennaY1, -25]) cylinder(d=antennaHoleD, 50);

            translate([fanX, fanY, -25]) cylinder(d=fanD, 50);
            translate([fanX + fanR, fanY + fanR, -25]) cylinder(d=fanHoleD, 50);
            translate([fanX - fanR, fanY + fanR, -25]) cylinder(d=fanHoleD, 50);
            translate([fanX + fanR, fanY - fanR, -25]) cylinder(d=fanHoleD, 50);
            translate([fanX - fanR, fanY - fanR, -25]) cylinder(d=fanHoleD, 50);

            translate([0,piBoardDim("3B")[1] - piBoardDim("Zero")[1],0]) piHoles("Zero", 50, false);
            //translate([1 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);
            //translate([3 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);

            rotate([0,90,0]) translate([8.8, dyZero / 2, dx]) cylinder(d=9.5, 20, center=true);
        }
    }
}

module piBaseZero() {
    board = "Zero";
    hole = 15;
    dx = piBoardDim(board)[0];
    dy = piBoardDim(board)[1];

    difference() {
        piBase(board);
        union() {
            translate([1 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);
            translate([3 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);
        }
    }
}

module piTopZero() {
    board = "Zero";
    hole = 15;
    dx = piBoardDim(board)[0];
    dy = piBoardDim(board)[1];

    difference() {
        piTop(board);
        union() {
            translate([1 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);
            translate([3 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);
            rotate([0,90,0]) translate([8.8, dy / 2, dx]) cylinder(d=9.5, 20, center=true);
        }
    }
}

module tunerStand() {
    pcbStand(hTunerStand);
}

module tunerTop() {
    pcbStand(hTunerTop);
}

module piTopStand() {
    pcbStand(hPiTopStand);
}

module caseSpacer() {
    pcbStand(hCaseSpacer);
}

module caseSpacerCutDown() {
    difference() {
        pcbStand(hCaseSpacer - 3.01);
        translate([-5, 0.9, 4]) cube([10, 10, 13]);
    }
}
module caseSpacerCutUp() {
    pcbStand(3);
}

module topHanger() {
    board = "Zero";
	piHolePos = piHoleLocations(board);
    h = 4;
    hole = 15;
    dx = piBoardDim(board)[0];
    dy = piBoardDim(board)[1];

    support_w = 10;
    support_gap = 4;
    support_hw = 3;
    support_hl = 2;
    support_h_gap = support_gap - support_hl;
    support_base = 35;
    support_l = support_base + support_gap + support_gap;

    module support() {
        difference() {
            cube([support_w, support_l, h], center=false);
            union() {
                translate([support_w / 2, support_h_gap + (support_hl / 2), h / 2]) cube([support_hw, support_hl, h * 2], center=true);
                translate([support_w / 2, support_base + support_gap + (support_hl / 2), h / 2]) cube([support_hw, support_hl, h * 2], center=true);
            }
        }
    }

    difference() {
        union() {
            cube([piBoardDim(board)[0], piBoardDim(board)[1], h], center=false);
            translate([0, -support_l, 0]) support();
            translate([piBoardDim(board)[0] - support_w, -support_l, 0]) support();
        }
        union() {
            translate([0,0,piBoardDim(board)[2] + 0.01]) piHoles(board, 20 + 0.02, false);
            translate([1 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);
            translate([3 * dx / 4, dy / 2, 0]) roundedcube(size = hole, center = true, radius = 3);
        }
    }
    // translate([0, 0, h]) piStands(board, height=hPiStand, preview=false);
}

module diskStand() {
    difference() {
        cylinder(d=10,6);
        translate([0,0,2]) cylinder(d=6,6);
    }
}

module antennaSpacer(distance) {
    dOut = 5.1;
    dIn = 3.1;
    thickUp = 5;
    thickIn = 1.5;
    thickHole = (thickUp + thickIn) * 2;

    difference() {
        union() {
            cylinder(d=dOut, thickUp);
            translate([distance, 0, 0]) cylinder(d=dOut, thickUp);
            translate([distance / 2, 0, thickUp / 2]) cube([distance, dOut, thickUp], center=true);
            translate([distance / 2, 0, thickUp + thickIn / 2]) cube([distance, dIn, thickIn], center=true);
        }
        union() {
            translate([0, 0, -thickHole/3]) cylinder(d=dIn, thickHole);
            translate([distance, 0, -thickHole/3]) cylinder(d=dIn, thickHole);
        }
    }
}

module antennaSpacers() {
    antennaSpacer(12);
    translate([0, 15, 0]) antennaSpacer(7.5);
}