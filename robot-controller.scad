
include <nutsnbolts/cyl_head_bolt.scad>
$fn = 64;

j1_offset=8;
j2_offset=j1_offset + 64;
setback = 8;
        
union() {
    difference() {
        cube([100,50,6]);
        translate([32,5,3]) cube([36,48,5]);
        
        boltHole(j1_offset,setback);
        boltHole(j1_offset+20,setback);
        boltHole(j1_offset,setback+26);
        boltHole(j1_offset+20,setback+26);
        
        boltHole(j2_offset,setback);
        boltHole(j2_offset+20,setback);
        boltHole(j2_offset,setback+26);
        boltHole(j2_offset+20,setback+26);
    }
    translate([0,setback+3,6])  cube([5,20,2]); // raise 1
    translate([j1_offset+20,setback+3,6]) cube([3,20,2]); // raise 2
    translate([j2_offset-3,setback+3,6]) cube([3,20,2]); // raise 2
    translate([j2_offset+20,setback+3,6]) cube([5,20,2]); // raise 3
}

module boltHole(x,y)
{
    union() {
        translate([x,y,7])
        {
            hole_through(name="M3", l=8, cl=0.1, h=0, hcl=0.4);
        }
        translate([x,y,2.99])
        {
            nutcatch_parallel("M3", l=3);
        }
    }
        
    
    
}