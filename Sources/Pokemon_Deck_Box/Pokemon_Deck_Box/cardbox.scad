/*
	Box for pokemon cards.
	Has space for coin & counters.

	Designed by Jesse Donaldson.
*/


// ***
// Render the inside or outside of the box?
inside();
//outside();


$fn = 50;

// Size of standard 60-card deck:
deckWidth = 63+2; // 1mm clearance each side
deckHeight = 88+2;
deckThickness = 18.3+0.5;
deckCornerR = 1.8;

// Flipping coin that comes with Talos starter sets.
coinDia = 34.25;
coinThickness = 2.25;

wall = 2; // 2mm thick walls.

// bottom compartment for counters.
compartmentWidth = 40;
compartmentHeight = 60;
compartmentDepth = 4;

lidClearance = 0.4; // extra room so the lid can smoothly move over the bottom

// Radius used for round holes in sides.
sideHoleR = 8;

// Geometry for detents to hold the lid on.
detentR = 1;
detentOffset = deckWidth/2+wall;
detentWidth = 2*sideHoleR;

// dependent variables:
topWall = max(wall, coinThickness+1);

module adhesionPads() {
	padR = 20;
	
	// Add pads to improve build platform adhesion:
	translate([deckWidth/2, deckHeight/2, 0]) cylinder(r=padR, h=0.2);
	translate([-deckWidth/2, deckHeight/2, 0]) cylinder(r=padR, h=0.2);
	translate([deckWidth/2, -deckHeight/2, 0]) cylinder(r=padR, h=0.2);
	translate([-deckWidth/2, -deckHeight/2, 0]) cylinder(r=padR, h=0.2);
}

module outside() {
	nubbinR = 2;
	coinHoleClearance = 0.5; // clearance from edge of coin to edge of inset.
	coinHoleOuterR = coinDia/2 + coinHoleClearance;
	nubbinOffset = coinHoleOuterR+nubbinR-coinHoleClearance-0.1;
	
	pokeballCircleR = coinHoleOuterR+4;
	pokeballStripeWidth=4;
	
	union() {
		difference() {
			// Basic outer form.
			semi_rounded_cube(deckWidth+4*wall+2*lidClearance, 
					deckHeight+4*wall+2*lidClearance, 
					deckThickness + topWall, deckCornerR+2*wall);
			
			// Remove inside.
			translate([0,0,topWall+0.1]) 
				semi_rounded_cube(deckWidth+2*wall+2*lidClearance, 
						deckHeight+2*wall+2*lidClearance, 
						deckThickness, deckCornerR+wall);
			
			// Remove coin cutout.
			translate([0,0,-0.1]) cylinder(r=(coinDia-2)/2, h=topWall+0.3);
			translate([0,0,1]) cylinder(r=coinHoleOuterR, h=topWall);
			
			// Pokeball decorations:
			rotate_extrude(convexity=4) translate([pokeballCircleR,0,0]) circle(r=0.5);
			translate([10+pokeballCircleR,pokeballStripeWidth/2,0]) 
				rotate([0,90,0]) cylinder(r=0.5, h=20, center=true);
			translate([10+pokeballCircleR,-pokeballStripeWidth/2,0]) 
				rotate([0,90,0]) cylinder(r=0.5, h=20, center=true);
			translate([-10-pokeballCircleR,pokeballStripeWidth/2,0]) 
				rotate([0,90,0]) cylinder(r=0.5, h=20, center=true);
			translate([-10-pokeballCircleR,-pokeballStripeWidth/2,0]) 
				rotate([0,90,0]) cylinder(r=0.5, h=20, center=true);

		}
		
		// Add nubbins to hold the coin in.
		translate([nubbinOffset,0,0]) cylinder(r=nubbinR, h=topWall);
		translate([-nubbinOffset,0,0]) cylinder(r=nubbinR, h=topWall);
		translate([0, nubbinOffset,0]) cylinder(r=nubbinR, h=topWall);
		translate([0, -nubbinOffset,0]) cylinder(r=nubbinR, h=topWall);
		
		// Add nubbins to hold the top on:
		translate([-detentOffset-lidClearance-0.25,0,topWall+deckThickness-detentR]) 
				rotate([90,0,0]) cylinder(r=detentR, h=detentWidth-0.5, center=true);
		translate([detentOffset+lidClearance+0.25,0,topWall+deckThickness-detentR]) 
				rotate([90,0,0]) cylinder(r=detentR, h=detentWidth-0.5, center=true);
		
		adhesionPads();
	}
}


module semi_rounded_cube(x,y,z, r) {
	
	translate([0,0,z/2]) union() {
		cube(size=[x, y-2*r, z], center=true);
		cube(size=[x-2*r, y, z], center=true);
		
		assign(xx = x/2-r, yy=y/2-r) {
			for(i=[0:3]) {
				translate([(i%2)>0 ? xx : -xx, i<2 ? yy : -yy, 0]) 
							cylinder(r=r, h=z, center=true);	
			}
		}
	}
}

module side_hole(left=false) {
	dir = left ? -1 : 1;
	translate([-dir * (deckWidth/2 + 2*wall+lidClearance+.1), 0, sideHoleR+wall+2]) rotate([0,dir * 90,0]) union() {
		cylinder(r=sideHoleR, h=2*wall);
		translate([-dir * sideHoleR,0,(2*wall+sideHoleR)/2]) 
				cube([2*sideHoleR, 2*sideHoleR, 2*wall+sideHoleR], center=true);
		translate([0,0,2*wall]) sphere(r=sideHoleR);
	}
}

module inside() {
	difference() {
		
		// Basic inner form:
		union() {
			semi_rounded_cube(deckWidth+2*wall, deckHeight+2*wall, deckThickness+wall+compartmentDepth, deckCornerR+wall);

			// Bottom flat bit:
			semi_rounded_cube(deckWidth+4*wall+2*lidClearance, 
					deckHeight+4*wall+2*lidClearance, compartmentDepth+wall-0.1, deckCornerR+2*wall);
			adhesionPads();
		}
	
		// Hollow out space for cards:
		translate([0,0,wall+compartmentDepth]) semi_rounded_cube(deckWidth, deckHeight, deckThickness+0.2, deckCornerR);
		
		// Hollow out under-deck compartment:
		translate([0,0,wall]) semi_rounded_cube(compartmentWidth, compartmentHeight, compartmentDepth+0.2, deckCornerR);
		
		// Holes in sides for easy card removal:
		side_hole(left=true);
		side_hole(left=false);
		
		// Detents to hold lid in place:
		translate([-detentOffset,0,wall+compartmentDepth+detentR]) rotate([90,0,0]) 
				cylinder(r=detentR, h=detentWidth+2, center=true);
		translate([detentOffset,0,wall+compartmentDepth+detentR]) rotate([90,0,0]) 
				cylinder(r=detentR, h=detentWidth+2, center=true);
	}

}



