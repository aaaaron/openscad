$fn=64;
//$size = [107, 45.7, 4];
//size = [38, 38, 7];

small_hole_size = 4.5; // radius not diameter
small_distance_between_holes = 7.2;
big_hole_size = 8.75;
big_distance_between_holes = 9.5;

size = [100, 40, 9];
handle_size_pct = 10;

num = 4;


makeBigRow([size[0]-1,(size[1])/num,size[2]], big_hole_size, big_distance_between_holes);
//translate([0,12,0]) makeSmallRow(size, small_hole_size, small_distance_between_holes);

translate([0,0,0]) makeBox(size);

module makeBox(size)
{
    difference() {
        cube(size);
        translate([1,1,1])
            cube(size-[2,2,0]);
    }  
}

module makeSmallRow(size, hole_size, distance_between_holes) {

    echo("d_b_h", distance_between_holes);
    echo("size", size);

    rows = (size[0] - 2) / distance_between_holes;
    
    echo("rows/cols",rows);
    
    //rows = 1;
    //cols = 1;
    wide = 5;
    offset = 5;
    
    hs = 30;
    he = 52;

    union() {
        difference() {
            cube(size);
            for (x = [0:rows/2-1]) {
                if(x * distance_between_holes > hs && x * distance_between_holes < he)
                {
                    // nothing
                } else {
                    translate([(x * distance_between_holes)+offset, wide, 0.5])
                        cylinder(size[2]+1, d=hole_size, d=hole_size);
                }
            }
            for (x = [rows/2-1:rows-1]) {
                if(x * distance_between_holes > hs && x * distance_between_holes < he)
                {
                    // nothing
                } else {
                    translate([size[1]-((rows-1)-x * distance_between_holes)+offset+8, wide, 0.5])
                        cylinder(size[2]+1, d=hole_size, d=hole_size);
                }
            }
        }
        translate([47,2,8])
            cube([6,6,10]);
        translate([50,wide,15])
            rotate([45,0,90])
                cylinder(12, r=3);
        translate([50,wide,15])
            rotate([315,0,90])
                cylinder(12, r=3);
    }
    
}


module makeBigRow(size, hole_size, distance_between_holes) {

    echo("d_b_h", distance_between_holes);
    echo("size", size);

    rows = (size[0] - 2) / distance_between_holes;
    
    echo("rows/cols",rows);
    
    //rows = 1;
    //cols = 1;
    wide = 5;
    offset = 5;
    
    hs = 30;
    he = 52;

    union() {
        difference() {
            cube(size);
            for (x = [0:rows/2-1]) {
                if(x * distance_between_holes > hs && x * distance_between_holes < he)
                {
                    // nothing
                } else {
                    translate([(x * distance_between_holes)+offset, wide, 0.5])
                        cylinder(size[2]+1, d=hole_size, d=hole_size);
                }
            }
            for (x = [rows/2-1:rows-1]) {
                if(x * distance_between_holes > hs && x * distance_between_holes < he)
                {
                    // nothing
                } else {
                    translate([size[1]-((rows-1)-x * distance_between_holes)+offset+2, wide, 0.5])
                        cylinder(size[2]+1, d=hole_size, d=hole_size);
                }
            }
        }
        translate([47,2,8])
            cube([6,6,10]);
        translate([50,wide,15])
            rotate([45,0,90])
                cylinder(12, r=3);
        translate([50,wide,15])
            rotate([315,0,90])
                cylinder(12, r=3);
    }
    
}