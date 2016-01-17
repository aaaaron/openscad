width = 100;
depth = 80;
height = 130;
thick = 1.75;
handle_size = width/5;

$fn = 64;

union()
{
    difference()
    {
        cube([width,depth,height]);
        translate([thick,thick,thick])
            cube([width-(thick*2),depth-(thick*2),height]);
        translate([width/2,thick+1,height])
            rotate([90,90,0])
                cylinder(thick*2, r=handle_size);
    }
    
}