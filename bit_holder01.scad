$fn=64;
//$size = [107, 45.7, 4];
$size = [38, 38, 7];

$hole_size = 2.5; // radius not diameter
$distance_between_holes = 7.6;
$row = 4;
$col = 4;


$handle_size_pct = 10;

makeBase();

module makeBase() {
    
    union() {
        difference() {
            cube($size);
            for (x = [1:$row]) {
                for (y = [1:$col]) {
                    this_x = x*$distance_between_holes;
                    this_y = y*$distance_between_holes;
                    echo (this_x / $size[0]);
                    //if( this_x / $size[0] > 0.5-($handle_size_pct/100) &&
                    //    this_x / $size[0] < 0.5+($handle_size_pct/100))
                    { // do nothing
                    //} else { 
                        translate([this_x,this_y,0.5]) {
                            cylinder($size[2]+1, $hole_size, $hole_size);
                        }
                    }
                }
            }
        }
        // handle bit
        *translate([
            ($size[0]/2)-(($size[0]*($handle_size_pct/100))/4),
            $distance_between_holes,
            $size[2]]) {
                cube([($size[0]*(($handle_size_pct/100)*1))/2,$size[1]-($distance_between_holes*2),12]);
        }
    }
    
}