debug = true;
$fn = 64; // Edge faces
$radius = rands(1,16,1)[0]; // Radius of edge curves
$thick = rands(1,8,1)[0]; // Thickness of parts
$insert_height = 0.500; // 20% will be lid/insert, 80% receiver  -- Safe range: 0.3 to 0.75 or so?
$abs_min = 1; // absolute minimum width for any piece
$lip_height = 2; // How deep the friction-fit part of the lip should be
$friction_rub = 0.1; 

// Receiver = "bottom", Insert = "top" with lip
receiver_size = [50,50,70];
//receiver_size = rands(20,100,3);

echo("[[[[ ", $radius, " ||||", $thick, " ]]]]");

display_skew = 1.0; // How many mm apart we hold the box and lid when displaying it or for printing
$print_mode = true;

// ######### Computed values 
// lip_width is how deep the lip can be 
$lip_width = ($thick/2 <= $abs_min*2) ? $abs_min*2 : $thick / 2;
// Ratio between the radius of the inside surface vs. the outside surface of the box
pinch = ($radius-$thick) > ($radius / 2) ? ($radius-$thick) : ($radius / 2);


insert_size = [receiver_size[0], receiver_size[1], receiver_size[2]*$insert_height];
// When we make lip corners this is how far in/out we move the profile to get a correct inside curve
radius_width_padding = $radius - $thick - $lip_width; 
lip_corner_width = radius_width_padding + $thick;


    

echo("lip_width=",$lip_width);
echo("lip_corner_width=",lip_corner_width);
echo("pinch=",pinch);

difference() { // DEBUG
    // join top and bottom for display
    union() { 
        // OPTIONAL - cut out the lip profile from the receiver for a good friction fit or debug the fit
        *difference() {
            makeReceiver(receiver_size); 
            translate([0,receiver_size[1],receiver_size[2]*(1-$insert_height)+(receiver_size[2]*$insert_height)]) 
                rotate([180,0,0])
                    makeInsert(insert_size);
        }
        if( ! $print_mode) { // Put the lid just over the box, display_skew above where it should be
            translate([0,receiver_size[1],receiver_size[2]*(1-$insert_height)+(receiver_size[2]*$insert_height)+display_skew])
                rotate([180,0,0])    
                    makeInsert(insert_size);
        } else { // Put the lid on the print bed display_skew from the other part
            translate([0,receiver_size[1]+display_skew,0])
                rotate([0,0,0])
                    makeInsert(insert_size);
        }
    }
    *translate([0,receiver_size[1]/2,0]) cube(125,25,25); // DEBUG 
}
///////////////////////////////////////////////////////////////////////////////
module makeReceiver(size) {
    difference() {
        roundedBox(size, $radius, $thick);
        translate([0,0,size[2]*(1-$insert_height)])
            cube(size+[1,1,1]); // cut off top of box for lid fit
    }    
}

module makeInsert(size) {
    difference() { // DEBUG
        union() {
            echo("radius|thick|z", size, $radius, $thick, $insert_height);
            difference() { // Build the base box half
                roundedBox(receiver_size); 
                translate([0,0,size[2]])
                    cube(size+[1,1,size[2]]); // cut off the top of the box
            }
            color("red")
                // position the lip inside the insert
                translate([size[0]/2,size[1]/2,(size[2]+$thick+$lip_height)])
                    rotate([180,0,0])            
                        makeLip(size);
            
        }
        cube([20,25,70]); // DEBUG
    }
}
module makeLip(size) {
    //size = lipSize-[$lip_width*2,$lip_width*2,0]; // the lip needs to be slightly smaller so it's flush with the inside
    union() {  echo("Size=",size);
        translate([0,size[2],0])
            lipEdgeAndCorner(size, 0);
        translate([0,0,0])
            rotate([0,0,90])
                lipEdgeAndCorner(size, 1);
        translate([0,0,0])
            rotate([0,0,180])
                lipEdgeAndCorner(size, 1);
        translate([0,0,0])
            rotate([0,0,270])
                lipEdgeAndCorner(size, 1);

    }
}
module lipEdgeAndCorner(size, q) {
    render() {
       union() {
            translate([pinch,0,$thick]) //TODO
            {
                difference() {
                    // Rotate the profile around to create a corner
                    rotate_extrude()
                        lipProfileCorner();
                    // slice off the sections of the curve we don't need
                    bound = $radius+$lip_width+$thick; // for cutting off pieces we don't need, make a larger box
                    translate([0,-bound,-bound])
                        cube([bound*2,bound*2,bound*2]); 
                    translate([-bound,-bound,-bound])
                        cube([bound*2,bound,bound*2]);
                }            
            }
            $setback = ($thick*2)+$lip_width;
            if(q % 2 == 0) { 
                translate([pinch,0,0])
                    rotate([90,0,90]) // Straight Edge 1 (X)
                        linear_extrude(height = size[0]-$setback, convexity = 1)
                            translate([0,$thick,0])
                                lipProfileStraight();
            } else {
                translate([pinch,0,0])
                    rotate([90,0,90]) // Straight Edge 2 (Y)
                        linear_extrude(height = size[1]-$setback, convexity = 1)
                            translate([0,$thick,0]) 
                                lipProfileStraight();
            }
        
        }
    }
}
module lipProfileCorner() {
    difference()
    {
        lipProfileStraight();
        
        bound = pinch; // just bigger than our biggest dimension, we clip off anything in negative X so we can rotate_extrude
        polygon(points=[[0,0],[0,-bound],[-bound,-bound],[-bound,bound],[0,bound]]);
    }   
}
module lipProfileStraight() {
    w = $lip_width/2;
    difference()
    {
        translate([pinch,-w,0])
            mirror() // flips the lip edge around so the profile is correct
                polygon(points=[[w,0],[w*2,0],[w*2,w+$lip_height],[0,w*4+$lip_height],[0,w]]); // gives us a 45 degree angle on the back side support
        
       bound = (w*4)+$lip_height+1; // just bigger than our biggest dimension, we clip off anything in negative X so we can rotate_extrude
       polygon(points=[[0,0],[0,-bound],[-bound,-bound],[-bound,bound],[0,bound]]);
    }
}
module roundedBox(size) {
    difference() { 
        roundedCube(size, $radius);
        translate([$thick,$thick,$thick])
            roundedCube(size-[$thick*2, $thick*2, $thick*2], pinch);
    }
}
module roundedCube(size, r) {
    echo ("R =",r);
    hull() { // 8 spheres in the corners, made into a hull
        x = size[0]-r;
        y = size[1]-r;
        z = size[2]-r;
        translate([r,r,r]) sphere(r);
        translate([x,r,r]) sphere(r);
        translate([r,y,r]) sphere(r);
        translate([x,y,r]) sphere(r);
        translate([r,y,z]) sphere(r);
        translate([r,r,z]) sphere(r);
        translate([x,r,z]) sphere(r);
        translate([x,y,z]) sphere(r);
    }
}