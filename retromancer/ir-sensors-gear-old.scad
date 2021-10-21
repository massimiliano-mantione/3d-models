//
// Anybeam OpenSCAD Library
//
// This library provides an anybeam() module that can be used to create beams
// with a variaty of hole, axle and slot patterns using a simple declaritive syntax.
//
//
// Beam String
//
// A beam is speficied with a sequence of characters, each representing a hole
// type in the beam.
//
//  O  Pin hole
//  X  Axle hole
//  (  Half hole with a slot on the right.
//  )  Half hole with the slot on the left.
//  -  (dash) A full width slot, use with ( and ) to create long slots with half hole ends like "(--)" (4 span slot) or "()" (2 span slot)
//  .  (period) Skip this hole.
//
// Use the above characters to represent the hole layout on the beam:
//
//   XOOOOX   - Size 6 beam with axle holes at the ends.
//   OOXOO    - Size 5 beam with an axle hole in the middle.
//   (---)OOO - Size 8 beam with a size 5 slot and three holes at the end.
//
// Between each beam is a connection vector that defines how the beams connect.
//
//   [ PREVIOUS_BEAM_HOLE, CURRENT_BEAM_HOLE, ANGLE ]
//
//  * Holes are numbered from 1 to N (the length of the beam) from left to right.
//  * Angles are in degrees.
//
// Here is a standard 4x2 90 degree lift arm:
//
//   [ "XOOO", [ 4, 1, 90 ], "OO" ]
//
// The connection hole specifier may includ a fractional part.
//
//
// Fractional Hole Spacing
//
// Here is a 4x2 beam with the size 2 beam in the midde of the size 4 beam.
// The space prevents a hole from appearing at the start of the beam where
// the two overlap.
//
// Connecing hole 2.5 of the size 4 beam to hole 1 of the size 2 beam at 90 degrees.
//
//   [ "OOOO", [ 2.5, 1, 90 ], ".O" ]
//
//
// Examples:

/*anybeam( [ "XOOO", [ 4, 1, 53.13 ],   "OOO()", [ 5, 1, -53.13 ],   "(-)X" ], AB_THIN_BEAM_HEIGHT );*/

/*anybeam( [ "XOOX", [ 4, 1, 90 ], "XOOOOX", [ 6, 1, 90 ], "XOOX", [ 4, 1, 90 ], "XOOOOX" ], 1/3);*/


// Constants.
AB_HOLE_SPACING = 8.0;
AB_HOLE_INSIDE_DIAMETER = 5.4;
AB_STUD_DIAMETER = 4.8;
AB_HOLE_RING_DIAMETER = 6.28;
AB_HOLE_RING_DEPTH = 0.9;
AB_BEAM_WIDTH = 7.6;
AB_AXLE_GAP = 1.95;
AB_AXLE_LENGTH = 5.1;
AB_MOUSE_EARS = false;

AB_BEAM_HEIGHT = 7.8;
AB_THIN_BEAM_HEIGHT = AB_BEAM_HEIGHT/3;

// From roipoussiere's string functions - https://www.thingiverse.com/thing:202724
function ab_fill(car, nb_occ, out="") = (nb_occ == 0) ? out : str(ab_fill(car, nb_occ-1, out), car);

module anybeam( beams = [], height = 1 ) {
    difference() {
      ab_beams( beams, height * AB_BEAM_HEIGHT );
      ab_holes( beams, height * AB_BEAM_HEIGHT );
    }
}

module anybeam_straight( holes = 10, height = 1 ) {
  if( len(holes )) {
    anybeam( [ holes ], height);
  }
  else {
    anybeam( [ ab_fill("O", holes ) ], height);
  }
}

module anybeam_tee( stem = "OOO", top = "OOO", height = 1 ) {
  anybeam( [ "OOO", [ 2, 1, 90 ], "OOO" ], height );
}

module anybeam_143( left = "XOOO", right = "OOOOOX", height = 1 ) {
  anybeam( [ left, [ len(left), 1, 53.13 ], right ], height );
}

module anybeam_90(left = "XOOO", right = "OO", height = 1) {
  anybeam( [ left, [ len(left), 1, 90 ], right ], height );
}

module anybeam_135x2(left = "XOOOOOO", middle = " () ", right = "OOX", height = 1) {
  anybeam( [ left, [ len(left), 1, 45 ], middle, [ len(middle), 1, 45], right ], height );
}

//
// Test beam that uses all features.
//
module anybeam_test(left = "XOOOOOO", middle = "O(-) ", right = 3, height = 1) {
  anybeam( [ left, [ len(left), 3, 45 ], middle, [ len(middle), 1, 45], right ], height );
}

//
// Support Modules
//

//
// Layout beam holes.
//
module ab_holes( beams = [], height = AB_BEAM_HEIGHT, b = 0 ) {
  beam = beams[b];
  connection = beams[b-1];
  next_beam = beams[b+2];

  if( connection ) {
    if( next_beam ) {
    translate( [ (connection[0]-1)*AB_HOLE_SPACING, 0,  0 ] )
     rotate([0, 0, connection[2]])
      translate( [ -(connection[1]-1)*AB_HOLE_SPACING, 0, 0 ] )
        ab_beam_holes( beam, height )
          ab_holes( beams, height, b+2 );
    }
    else {
      translate( [ (connection[0]-1)*AB_HOLE_SPACING, 0, 0 ] )
       rotate([0, 0, connection[2]])
        translate( [ -(connection[1]-1)*AB_HOLE_SPACING, 0, 0 ] )
          ab_beam_holes( beam, height );
    }
  }
  else {
    if( next_beam ) {
      ab_beam_holes( beam, height )
        ab_holes( beams, height, b+2 );
    }
    else {
      ab_beam_holes( beam, height );
    }
  }
}

//
// Layout solid beams.
//
module ab_beams( beams = [], height = AB_BEAM_HEIGHT, b = 0 ) {

  beam = beams[b];
  connection = beams[b-1];
  next_beam = beams[b+2];

  if( connection ) {
    if( next_beam ) {
    translate( [ (connection[0]-1)*AB_HOLE_SPACING, 0, 0 ] )
     rotate([0, 0, connection[2]])
      translate( [ -(connection[1]-1)*AB_HOLE_SPACING, 0, 0 ] )
        ab_solid_beam( beam, height )
          ab_beams( beams, height, b+2 );
    }
    else {
      translate( [ (connection[0]-1)*AB_HOLE_SPACING, 0, 0 ] )
       rotate([0, 0, connection[2]])
        translate( [ -(connection[1]-1)*AB_HOLE_SPACING, 0, 0 ] )
          ab_solid_beam( beam, height );
    }
  }
  else {
    if( next_beam ) {
      ab_solid_beam( beam, height )
        ab_beams( beams, height, b+2 );
    }
    else {
      ab_solid_beam( beam, height );
    }
  }
}

//
// A single solid beam.
//
module ab_mouse_ear( beam = "OOOO", beam_height = AB_BEAM_HEIGHT ) {
  holes = len(beam) ? len(beam)-1 : beam-1;
  beam_length = holes*AB_HOLE_SPACING;

  union() {
    translate( [beam_length/2,0,0] ) {

		// Mouse Ear
      translate( [-beam_length/2, 0, -(AB_BEAM_HEIGHT-.5)/2] )
			difference() {
	        cylinder( r = AB_BEAM_WIDTH, .5, center=true, $fn=100 );
	        cylinder( r = AB_BEAM_WIDTH/2+.2, 1, center=true, $fn=100 );
         }

		// Mouse Ear
      translate( [beam_length/2, 0, -(AB_BEAM_HEIGHT-.5)/2] )
			difference() {
	        cylinder( r = AB_BEAM_WIDTH, .5, center=true, $fn=100 );
	        cylinder( r = AB_BEAM_WIDTH/2+.2, 1, center=true, $fn=100 );
	      }
    }

    if( $children ) children(0);
  }
}

//
// A single solid beam.
//
module ab_mouse_ear_cutout( beam = "OOOO", beam_height = AB_BEAM_HEIGHT ) {
  holes = len(beam) ? len(beam)-1 : beam-1;
  beam_length = holes*AB_HOLE_SPACING;

  union() {
		// Mouse Ear
      translate( [-beam_length/2, 0, -(AB_BEAM_HEIGHT-.5)/2] )
	        cylinder( r = AB_BEAM_WIDTH+.2, 1, center=true, $fn=100 );

		// Mouse Ear
      translate( [beam_length/2, 0, -(AB_BEAM_HEIGHT-.5)/2] )
	        cylinder( r = AB_BEAM_WIDTH+.2, 1, center=true, $fn=100 );

    if( $children ) children(0);
  }
}


//
// A single solid beam.
//
module ab_solid_beam( beam = "OOOO", beam_height = AB_BEAM_HEIGHT ) {
  holes = len(beam) ? len(beam)-1 : beam-1;
  beam_length = holes*AB_HOLE_SPACING;

  union() {
    translate( [beam_length/2,0,0] ) {
      cube( [ beam_length, AB_BEAM_WIDTH, beam_height ], center=true );

      translate( [-beam_length/2, 0, 0] )
        cylinder( r = AB_BEAM_WIDTH/2, beam_height, center=true, $fn=100 );

      translate( [beam_length/2, 0, 0] )
        cylinder( r = AB_BEAM_WIDTH/2, beam_height, center=true, $fn=100 );
    }

	if( AB_MOUSE_EARS == true ) {
	  ab_mouse_ear( beam, beam_height );
   }

    if( $children ) children(0);
  }
}

module ab_beam_holes( beam = "OOOO", beam_height = AB_BEAM_HEIGHT ) {
  holes = len(beam)-1;
  beam_length = holes*AB_HOLE_SPACING;
  layout = beam;

  for (hole = [0:1:holes]) {
    translate( [hole*AB_HOLE_SPACING,0,0] ) {
      if( layout == "" ) {
        ab_hole_pin( beam_height );
      }
      else {
        if( layout[hole] == "O" ) {
          ab_hole_pin( beam_height );
        }
        if( layout[hole] == "(" ) {
          ab_hole_left_slot( beam_height );
        }
        if( layout[hole] == ")" ) {
          ab_hole_right_slot( beam_height );
        }
        if( layout[hole] == "-" ) {
          ab_hole_slot( beam_height );
        }
        if( layout[hole] == "X" ) {
          ab_hole_axle( beam_height, first = (hole==0), last = (hole==holes) );
        }
        // Any other letter is a space.
      }
    }
  }
  if( $children ) children(0);
}

module ab_hole_pin( beam_height = AB_BEAM_HEIGHT ) {
  cylinder(beam_height+2, AB_HOLE_INSIDE_DIAMETER/2, AB_HOLE_INSIDE_DIAMETER/2, center = true, $fn=100);

  translate([0,0,beam_height/2-AB_HOLE_RING_DEPTH/2+.5])
    cylinder(AB_HOLE_RING_DEPTH+1, AB_HOLE_RING_DIAMETER/2, AB_HOLE_RING_DIAMETER/2, center = true, $fn=100);

  translate([0,0,-(beam_height/2-AB_HOLE_RING_DEPTH/2+.5)])
    cylinder(AB_HOLE_RING_DEPTH+1, AB_HOLE_RING_DIAMETER/2, AB_HOLE_RING_DIAMETER/2, center = true, $fn=100);
}

module ab_hole_left_slot( beam_height = AB_BEAM_HEIGHT ) {
  ab_hole_pin(beam_height);

  translate([AB_HOLE_SPACING/4, 0, 0]) {
    cube([AB_HOLE_SPACING/2+.05,AB_HOLE_INSIDE_DIAMETER,beam_height+2], center = true);

    translate([0,0,beam_height/2-AB_HOLE_RING_DEPTH/2+.5])
      cube([AB_HOLE_SPACING/2+0.05, AB_HOLE_RING_DIAMETER, AB_HOLE_RING_DEPTH+1,], center = true);

    translate([0,0,-(beam_height/2-AB_HOLE_RING_DEPTH/2+.5)])
      cube([AB_HOLE_SPACING/2+0.05, AB_HOLE_RING_DIAMETER, AB_HOLE_RING_DEPTH+1], center = true);
  }
}

module ab_hole_right_slot( beam_height = AB_BEAM_HEIGHT ) {
  ab_hole_pin(beam_height);

  translate([-AB_HOLE_SPACING/4, 0, 0]) {
    cube([AB_HOLE_SPACING/2+.05,AB_HOLE_INSIDE_DIAMETER,beam_height+2], center = true);

    translate([0,0,beam_height/2-AB_HOLE_RING_DEPTH/2+.5])
      cube([AB_HOLE_SPACING/2+0.05, AB_HOLE_RING_DIAMETER, AB_HOLE_RING_DEPTH+1,], center = true);

    translate([0,0,-(beam_height/2-AB_HOLE_RING_DEPTH/2+.5)])
      cube([AB_HOLE_SPACING/2+0.05, AB_HOLE_RING_DIAMETER, AB_HOLE_RING_DEPTH+1], center = true);
  }
}

module ab_hole_slot( beam_height = AB_BEAM_HEIGHT ) {
  cube([AB_HOLE_SPACING,AB_HOLE_INSIDE_DIAMETER,beam_height+2], center = true);

  translate([0,0,beam_height/2-AB_HOLE_RING_DEPTH/2+.5])
    cube([AB_HOLE_SPACING, AB_HOLE_RING_DIAMETER, AB_HOLE_RING_DEPTH+1,], center = true);

  translate([0,0,-(beam_height/2-AB_HOLE_RING_DEPTH/2+.5)])
    cube([AB_HOLE_SPACING, AB_HOLE_RING_DIAMETER, AB_HOLE_RING_DEPTH+1], center = true);
}

module ab_hole_axle( beam_height = AB_BEAM_HEIGHT , first = false, last = false) {
  if( first == true ) {
    cube([AB_AXLE_GAP,AB_AXLE_LENGTH,beam_height+2], center = true);
      translate([+.5,0,0])
      cube([AB_AXLE_LENGTH+1,AB_AXLE_GAP,beam_height+2], center = true);
  }
  if( last == true ) {
    cube([AB_AXLE_GAP,AB_AXLE_LENGTH,beam_height+2], center = true);
      translate([-.5,0,0])
      cube([AB_AXLE_LENGTH+1,AB_AXLE_GAP,beam_height+2], center = true);
  }
  if( first == false && last == false ) {
    cube([AB_AXLE_GAP,AB_AXLE_LENGTH,beam_height+2], center = true);
      cube([AB_AXLE_LENGTH,AB_AXLE_GAP,beam_height+2], center = true);
  }
}




// MY CODE




// in mm
// tolerance in ()
S_HEIGHT = 29.6;
S_PIN_WIDTH = 7.5 + (0.4);
S_PIN_HEIGHT = 7.5; // < AB_BEAM_HEIGHT!
S_PIN_THICKNESS_MIN = 1.5 + (0.4);
S_PIN_THICKNESS_MAX = 5.8 + (0.2);
// in degrees
S_PIN_ANGLE = 45;

// in mm
PLATE_ADD = ((4 * AB_BEAM_HEIGHT) - S_HEIGHT) / 2; // 0.8
PLATE_HEIGHT = AB_BEAM_HEIGHT + PLATE_ADD;


module beam_tip() {
    difference() {
        cube([AB_BEAM_WIDTH, AB_BEAM_WIDTH / 2, AB_BEAM_HEIGHT]);

        translate([AB_BEAM_WIDTH / 2, 0, -AB_BEAM_HEIGHT / 2])
            cylinder(r = (AB_BEAM_WIDTH + AB_HOLE_RING_DIAMETER) / 4, 2 * AB_BEAM_HEIGHT, $fn=100);
    }
}

module old_lego_struct() {
    union() {
        translate([-5 * AB_HOLE_SPACING, AB_BEAM_WIDTH / 2, AB_BEAM_HEIGHT / 2])
            anybeam(["OOOOOOOOOOO", [6, 1, 90], "OOOOOOO"]);

        translate([-(5 * AB_HOLE_SPACING) - (AB_BEAM_WIDTH / 2), AB_BEAM_WIDTH / 2, 0])
            beam_tip();

        translate([(5 * AB_HOLE_SPACING) - (AB_BEAM_WIDTH / 2), AB_BEAM_WIDTH / 2, 0])
            beam_tip();

        translate([-AB_BEAM_WIDTH / 2, (6 * AB_HOLE_SPACING) + (AB_BEAM_WIDTH / 2), 0])
            beam_tip();
    }
}

module s_pin() {
    union() {
        translate([-S_PIN_WIDTH / 2, -S_PIN_THICKNESS_MAX / 2, PLATE_HEIGHT - S_PIN_HEIGHT])
            cube([S_PIN_WIDTH, S_PIN_THICKNESS_MIN, S_PIN_HEIGHT + 1]);

        difference() {
            translate([-S_PIN_WIDTH / 2, -S_PIN_THICKNESS_MAX / 2, PLATE_HEIGHT - S_PIN_HEIGHT])
                cube([S_PIN_WIDTH, S_PIN_THICKNESS_MAX, S_PIN_HEIGHT + 1]);

            translate([-S_PIN_WIDTH, S_PIN_THICKNESS_MAX / 2, PLATE_HEIGHT])
            rotate([S_PIN_ANGLE, 180, 180])
            translate([0, -1, 0])
                cube([2 * S_PIN_WIDTH, 2 * S_PIN_HEIGHT, 2 * S_PIN_HEIGHT]);
        }
    }
}

module s_pin_place(x, y, angle) {
    translate([x, y, 0])
    rotate([0, 0, -angle])
        s_pin();
    translate([-x, y, 0])
    rotate([0, 0, angle])
        s_pin();
}

module sensor_line() {
    union() {
        translate([-(5 * AB_HOLE_SPACING) - (AB_BEAM_WIDTH / 2), (5 * AB_HOLE_SPACING) + AB_BEAM_WIDTH, 0])
            difference() {
                intersection() {
                    cylinder(r = 5 * AB_HOLE_SPACING, PLATE_HEIGHT, $fn=100);
                    translate([0, -5 * AB_HOLE_SPACING, 0])
                        cube([5 * AB_HOLE_SPACING, 5 * AB_HOLE_SPACING, PLATE_HEIGHT]);
                }
                translate([0, 0, -PLATE_HEIGHT / 2])
                    cylinder(r = 4 * AB_HOLE_SPACING, 2 * PLATE_HEIGHT, $fn=100);
            }
        
        translate([-AB_HOLE_SPACING - (AB_BEAM_WIDTH / 2), (5 * AB_HOLE_SPACING) + AB_BEAM_WIDTH, 0])
            cube([AB_HOLE_SPACING, AB_HOLE_SPACING, PLATE_HEIGHT]);
    }
}

module plate() {
    translate([AB_BEAM_WIDTH / 2, AB_BEAM_WIDTH, 0])
        difference() {
            cube([5 * AB_HOLE_SPACING, 5 * AB_HOLE_SPACING, AB_BEAM_HEIGHT / 2]);
            translate([5 * AB_HOLE_SPACING, 5 * AB_HOLE_SPACING, -AB_BEAM_HEIGHT / 2])
                cylinder(r = 5 * AB_HOLE_SPACING, 2 * AB_BEAM_HEIGHT, $fn=100);
        }
}

module old_main() {
    difference() {
        union() {
            old_lego_struct();

            sensor_line();
            translate([0, 0, PLATE_HEIGHT])
            rotate([0, 180, 0])
                sensor_line();

            plate();
            translate([0, 0, AB_BEAM_HEIGHT / 2])
            rotate([0, 180, 0])
                plate();
        }

        s_pin_place(7.8, 50, 90);
        s_pin_place(11.5, 32, 65);
        s_pin_place(22.2, 19, 37);
        s_pin_place(37, 12.4, 10);
    }
}

module lego_struct() {
    union() {
        translate([-5 * AB_HOLE_SPACING, AB_BEAM_WIDTH / 2, AB_BEAM_HEIGHT / 2])
            anybeam(["O..OOOOO..O", [6, 1, 90], "OO..OO", [6, 2, 90], "OOO"]);

        /*
        translate([-(5 * AB_HOLE_SPACING) - (AB_BEAM_WIDTH / 2), AB_BEAM_WIDTH / 2, 0])
            beam_tip();

        translate([(5 * AB_HOLE_SPACING) - (AB_BEAM_WIDTH / 2), AB_BEAM_WIDTH / 2, 0])
            beam_tip();
        */
    }
}

FRONT_SENSOR_LINE_RADIUS = (6 * AB_HOLE_SPACING) + AB_BEAM_WIDTH;
FRONT_SENSOR_LINE_ANGLE = 42;
FRONT_SENSOR_LINE_RADIUS_SUB = 5 / 4 * AB_HOLE_SPACING;
FRONT_SENSOR_LINE_POS = 10.7 * AB_HOLE_SPACING;

module front_sensor_line() {
    translate([0, FRONT_SENSOR_LINE_POS, 0])
        union() {
            difference() {
                cylinder(r = FRONT_SENSOR_LINE_RADIUS, PLATE_HEIGHT, $fn=100);
                translate([0, 0, -PLATE_HEIGHT / 2])
                    cylinder(r = FRONT_SENSOR_LINE_RADIUS - FRONT_SENSOR_LINE_RADIUS_SUB, 2 * PLATE_HEIGHT, $fn=100);

                translate([sin(180 - FRONT_SENSOR_LINE_ANGLE) * (FRONT_SENSOR_LINE_RADIUS - AB_BEAM_WIDTH / 2), cos(180 - FRONT_SENSOR_LINE_ANGLE) * (FRONT_SENSOR_LINE_RADIUS - AB_BEAM_WIDTH / 2), 0])
                rotate([0, 0, FRONT_SENSOR_LINE_ANGLE])
                translate([0, -FRONT_SENSOR_LINE_RADIUS / 2, -PLATE_HEIGHT / 2])
                    cube([FRONT_SENSOR_LINE_RADIUS, FRONT_SENSOR_LINE_RADIUS, 2 * PLATE_HEIGHT]);
                
                translate([sin(180 - FRONT_SENSOR_LINE_ANGLE) * -(FRONT_SENSOR_LINE_RADIUS - AB_BEAM_WIDTH / 2), cos(180 - FRONT_SENSOR_LINE_ANGLE) * (FRONT_SENSOR_LINE_RADIUS - AB_BEAM_WIDTH / 2), 0])
                rotate([0, 0, 180-FRONT_SENSOR_LINE_ANGLE])
                translate([0, -FRONT_SENSOR_LINE_RADIUS / 2, -PLATE_HEIGHT / 2])
                    cube([FRONT_SENSOR_LINE_RADIUS, FRONT_SENSOR_LINE_RADIUS, 2 * PLATE_HEIGHT]);

                translate([- 3 / 2 * FRONT_SENSOR_LINE_RADIUS, 0, -PLATE_HEIGHT / 2])
                    cube([3 * FRONT_SENSOR_LINE_RADIUS, FRONT_SENSOR_LINE_RADIUS, 2 * PLATE_HEIGHT]);
            }
            translate([sin(180 - FRONT_SENSOR_LINE_ANGLE) * (FRONT_SENSOR_LINE_RADIUS - FRONT_SENSOR_LINE_RADIUS_SUB / 2), cos(180 - FRONT_SENSOR_LINE_ANGLE) * (FRONT_SENSOR_LINE_RADIUS - FRONT_SENSOR_LINE_RADIUS_SUB / 2), 0])
                cylinder(r = FRONT_SENSOR_LINE_RADIUS_SUB / 2, PLATE_HEIGHT, $fn=100);

            translate([sin(180 - FRONT_SENSOR_LINE_ANGLE) * -(FRONT_SENSOR_LINE_RADIUS - FRONT_SENSOR_LINE_RADIUS_SUB / 2), cos(180 - FRONT_SENSOR_LINE_ANGLE) * (FRONT_SENSOR_LINE_RADIUS - FRONT_SENSOR_LINE_RADIUS_SUB / 2), 0])
                cylinder(r = FRONT_SENSOR_LINE_RADIUS_SUB / 2, PLATE_HEIGHT, $fn=100);
        }
}

SIDE_SENSOR_LINE_RADIUS = (11 / 3 * AB_HOLE_SPACING) + AB_BEAM_WIDTH;
SIDE_SENSOR_LINE_RADIUS_SUB = FRONT_SENSOR_LINE_RADIUS_SUB;

module side_sensor_line() {
    translate([0, AB_BEAM_WIDTH, 0])
        union() {
            difference() {
                cylinder(r = SIDE_SENSOR_LINE_RADIUS, PLATE_HEIGHT, $fn=100);
                translate([0, 0, -PLATE_HEIGHT / 2])
                    cylinder(r = SIDE_SENSOR_LINE_RADIUS - SIDE_SENSOR_LINE_RADIUS_SUB, 2 * PLATE_HEIGHT, $fn=100);

            translate([0, FRONT_SENSOR_LINE_POS, -PLATE_HEIGHT / 2])
                cylinder(r = FRONT_SENSOR_LINE_RADIUS, 2 * PLATE_HEIGHT, $fn=100);

            translate([-3 / 2 * SIDE_SENSOR_LINE_RADIUS, -2 * SIDE_SENSOR_LINE_RADIUS, -PLATE_HEIGHT / 2])
                cube([3 * SIDE_SENSOR_LINE_RADIUS, 2 * SIDE_SENSOR_LINE_RADIUS, 2 * PLATE_HEIGHT]);
            }

        }
}

module main() {
    difference() {
        union() {
            lego_struct();
            translate([0, -AB_BEAM_WIDTH, 0])
                union() {
                    front_sensor_line();
                    side_sensor_line();
                }
        }
        translate([0, -AB_BEAM_WIDTH, 0])
            union() {
                s_pin_place(9.5, FRONT_SENSOR_LINE_POS - 49.5, -1 * 180 / 14);
                s_pin_place(32, FRONT_SENSOR_LINE_POS - 39, -3 * 180 / 14);
                s_pin_place(24, 28, 5 * 180 / 14);
                s_pin_place(31.3, 13, 7 * 180 / 14);
        }
    }

}

main();
