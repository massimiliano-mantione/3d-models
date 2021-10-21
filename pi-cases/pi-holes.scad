//Shut your Pi Hole! 
//An OpenSCAD library to assist with designing Raspberry Pi accessories

//This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
//© 2016 Dale Price

//Pi dimensions sourced from https://www.raspberrypi.org/documentation/hardware/raspberrypi/mechanical/
//Currently supports "1B", "1A+", "1B+", "2B", "3B", "Zero"

//Pi hole diameter plus a tiny bit extra to account for shrinkage when 3D printing
piHoleD = 2.9;


//get vector of [x,y] vectors of locations of mounting holes based on Pi version
function piHoleLocations (board="3B") = 
	(board=="1A+" || board=="1B+" || board=="2B" || board=="3B") ?
		[[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]] : //pi 1B+, 2B, 3B
	(board=="Zero") ?
		[[3.5, 3.5], [61.5, 3.5], [3.5, 26.5], [61.5, 26.5]] : //pi zero
	(board=="1B") ?
		[[80, 43.5], [25, 17.5]] :
	[]; //invalid board

//get vector of [x,y,z] dimensions of board
//	dimensions are for PCB only, not ports or anything else
function piBoardDim (board="3B") =
	(board=="1B" || board=="1B+" || board=="2B" || board=="3B") ?
		[85, 56, 1.25] :
	(board=="Zero") ?
		[65, 30, 1.25] :
	(board == "1A+") ?
		[65, 56, 1.25] :
	[0,0,0];

//Mounting holes for a Raspberry Pi of the specified version
//	Parameters
//		board: the version of the raspberry pi to generate holes for
//		depth: the depth of the holes in mm
module piHoles (board, depth = 5, preview=true) {
	//preview of the board itself
	if(preview==true)
		% piBoard(board);
	
	//mounting holes
	for(holePos = piHoleLocations(board)) {
		translate([holePos[0], holePos[1], -depth]) cylinder(d=piHoleD + 0.1, h=2*depth);
	}
}

//Preview of board dimensions for Raspberry Pi of the specified version
module piBoard (board) {
	difference() {
		cube(piBoardDim(board), center=false);
		translate([0,0,piBoardDim(board)[2] + 0.01]) piHoles(board, piBoardDim(board)[2] + 0.02, false);
	}

	//warn about possible inaccuracy of boards that don't currently have official documentation
	if(board == "1B") {
		echo("CAUTION: The mounting hole positions for the board you have selected may not be accurate because the Raspberry Pi Foundation does not currently provide official mechanical drawings for it.");
	}
}

//Snap-fit posts for mounting the Raspberry Pi
//	Parameters
//		board: version of the raspberry pi to mount
//		height: height of the top surface of the raspberry pi board off the base of the posts
//		preview: whether or not to show a preview of the board in place
module piPosts(board, height=5, preview=true) {
	piSize = piBoardDim(board);
	piHolePos = piHoleLocations(board);

	module pcbPost(height) {
		cylinder(d=2, h=height);
		cylinder(d1=5, d2=2, h=height - piSize[2] - 0.25);

		translate([0, 0.4, height]) scale([1.1, 1.1, 1]) cylinder(d=2, h=0.5);
	}
	
	for(holePos = piHolePos) {
		translate([holePos[0], holePos[1], 0]) pcbPost(height);
	}

	if(preview==true)
		% translate([0,0,height-piSize[2]]) piBoard(board);
}

//Generic stands of arbitrary height
//	Parameters
//		height: stand height
module pcbStand(height) {
	difference() {
		cylinder(d=7, h=height);
		translate([0, 0, -1]) cylinder(d=piHoleD + 0.42, h=height+2);
	}
}

//Pass-through stands for mounting the Raspberry Pi
//	Parameters
//		board: version of the raspberry pi to mount
//		height: height of the top surface of the raspberry pi board off the base of the posts
//		preview: whether or not to show a preview of the board in place
module piStands(board, height=5, preview=true) {
	piSize = piBoardDim(board);
	piHolePos = piHoleLocations(board);

	for(holePos = piHolePos) {
		translate([holePos[0], holePos[1], 0]) pcbStand(height);
	}

	if(preview==true)
		% translate([0,0,height-piSize[2]]) piBoard(board);
}

//baseplate (or top cover) for board enclosure
//	ext is the added dimension in mm
//	h is the thickness in mm
module piPlate (board="3B", ext=4, h=2) {
	let (
		base=[
			piBoardDim(board)[0] + ext * 2,
			piBoardDim(board)[1] + ext * 2,
			h
		],
		bh = piBoardDim(board)[2]
	)
	difference() {
		translate([-ext,-ext,-h]) cube(base, center=false);
		translate([0,0,1]) piHoles(board, h + 2, false);
	}

	//warn about possible inaccuracy of boards that don't currently have official documentation
	if(board == "1B") {
		echo("CAUTION: The mounting hole positions for the board you have selected may not be accurate because the Raspberry Pi Foundation does not currently provide official mechanical drawings for it.");
	}
}


//walls on baseplate for board enclosure
//	ext is the added dimension in mm
//	thick is the thickness in mm (inwards)
//	h is the height in mm
//	if top > 0 consider this a top cover and extend walls down from "top"
module piPlateWalls(board="3B", ext=4, thick=2, h=10, top=0) {
	outer=[
		piBoardDim(board)[0] + ext * 2,
		piBoardDim(board)[1] + ext * 2,
		h
	];
	inner=[
		piBoardDim(board)[0] + (ext - thick) * 2,
		piBoardDim(board)[1] + (ext - thick) * 2,
		h + 2
	];
	dh = top > 0 ? (h + top) : 0;
	translate([0, 0, -dh]) difference() {
		translate([-ext,-ext,0]) cube(outer, center=false);
		translate([-(ext - thick),-(ext - thick),-1]) cube(inner, center=false);;
	}
}

//partial walls on baseplate for board enclosure
//	ext is the added dimension in mm
//	thick is the thickness in mm (inwards)
//	size is the corner space to skip in mm
//	h is the height in mm
//	if top > 0 consider this a top cover and extend walls down from "top"
module piPlatePartialWalls(board="3B", ext=4, thick=2, h=10, size=10, top=0) {
	innerX=[
		piBoardDim(board)[0] + (ext * 2) - (size * 2),
		piBoardDim(board)[1] + (ext * 2) + 2,
		h + 2
	];
	innerY=[
		piBoardDim(board)[0] + (ext * 2) + 2,
		piBoardDim(board)[1] + (ext * 2) - (size * 2),
		h + 2
	];
	dh = top > 0 ? (h + top) : 0;
	translate([0, 0, -dh]) intersection() {
		piPlateWalls(board, ext, thick, h);
		union() {
			translate([size-ext,-ext-1,-1]) cube(innerX, center=false);
			translate([-ext-1,size-ext,-1]) cube(innerY, center=false);
		}
	}
}

//corners on baseplate for board enclosure
//	ext is the added dimension in mm
//	thick is the thickness in mm (inwards)
//	h is the height in mm
//	size is the corner size in mm
//	if top > 0 consider this a top cover and extend walls down from "top"
module piPlateCorners(board="3B", ext=4, thick=2, h=10, size=10, top=0) {
	innerX=[
		piBoardDim(board)[0] + (ext * 2) - (size * 2),
		piBoardDim(board)[1] + (ext * 2) + 2,
		h + 2
	];
	innerY=[
		piBoardDim(board)[0] + (ext * 2) + 2,
		piBoardDim(board)[1] + (ext * 2) - (size * 2),
		h + 2
	];
	dh = top > 0 ? (h + top) : 0;
	translate([0, 0, -dh]) difference() {
		piPlateWalls(board, ext, thick, h);
		{
			translate([size-ext,-ext-1,-1]) cube(innerX, center=false);
			translate([-ext-1,size-ext,-1]) cube(innerY, center=false);
		}
	}
}

color("DarkGreen", 1, $fn=20) {
	piBoard("1B");
	translate([100,0,0]) piBoard("1A+");
	translate([0,80,0]) piBoard("2B");
	translate([100,80,0]) piBoard("Zero");
}