//include <nutsnbolts/cyl_head_bolt.scad>

design_mode = true;
show_components = false;
assembled = true;
part = "top_board";  // power_board top_board chassis motor_arm_a motor_arm_b camera_tray

faa_drone_id="FA11AA1AAA";
fpv_camera = true;

// ========== Dimensions
zip_tie_size = "M4";

chassis_thick  = 4;
chassis_length = 157;
chassis_width  = 20; // ***TODO*** this is actually 1/2 the chassis height when assembled
chassis_round  = 5; // how big the diameter of curves are

crossbeam_size = "M3";
crossbeam_count = 2; // How many support beams top and bottom
crossbeam_from_edge = 5; // How close the support beams are to the edges
crossbeam_width = 37; // How many mm across are the support pieces
crossbeam_outer_size = 8; // What size are the metal crossbeam supports in mm

hex_depth = 0.1; // How many MM deep we want the hex outline[ 40.92, -48.00, 24.02 ]

motor_arm_length = 95;
motor_arm_tilt_a = 20;
motor_arm_tilt_b  = -20;
motor_arm_box = 10;
motor_arm_wire_diameter = 5;
motor_arm_thick = 5;
motor_arm_esc_outboard = false;
motor_arm_width_modifier = motor_arm_esc_outboard ? 1 : 0.5;
motor_arm_edge = 5; // Edge of the mount plates around the screws
mount_motor_circle_size = 28;   // How many mm wide is the motor?
motor_hole_width1 = 19;
motor_hole_width2 = 16;
motor_hole_size_vent = 2.5;
motor_hole_size_screw = "M3";
motor_hole_size_shaft = "M5";

top_board_thick = chassis_thick;
top_board_thick = 1;

// ========== Build options
debug = true;
$fn = 64;

cut_z_min_safe = -1; // A floor value below which nothing will appear; for cutting  XXX deprecate this idea
cut_z_max_safe = chassis_thick + 2; // Max value above which nothing exists for cutting

// ========== Computations
chassis_side_opening_height = (chassis_width/4);

// center point of each cylinder is this many points off the center line
curve_offset = (chassis_length/2) - (chassis_round);
echo("==> curve offset:", curve_offset, "");

// How far from the centerline our support crossbeams should be
crossbeam_offset  = chassis_length/2.25; // Default to starting at the start of the curve
crossbeam_length  = chassis_length/1.15; // Total length of our crossbeam section
crossbeam_spacing = crossbeam_length/crossbeam_count; // Distanceb between each crossbeam
echo("==> crossbeam offset, length, spacing: ", crossbeam_offset, crossbeam_length, crossbeam_spacing);
echo("==> crossbeam_width, crossbeam_outer_size: ", crossbeam_width, crossbeam_outer_size);

mount_plate_size = (motor_arm_box + motor_arm_edge);
echo("==> motor arm mount_plate_size: ", mount_plate_size);

motor_center_a = (chassis_length/2)-(mount_plate_size+motor_arm_edge);
motor_center_b  = -motor_center_a;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CHASSIS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module chassis()
{
    difference()
    {
        chassis_frame();   
        
        // Motor arm 
        translate([motor_center_a, 0, cut_z_max_safe])
            chassis_motor_arm_mount();
        translate([motor_center_b, 0, cut_z_max_safe])
            chassis_motor_arm_mount();

        // Motor arm wiring cutouts
        translate([motor_center_a, 0, cut_z_min_safe])
            cylinder(cut_z_max_safe, r=motor_arm_wire_diameter);
        translate([motor_center_b, 0, cut_z_min_safe])
            cylinder(cut_z_max_safe, r=motor_arm_wire_diameter);

        // Cross beam mounts
        for (q = [1 : crossbeam_count])
        { 
            translate([((crossbeam_length/crossbeam_count)*q)-crossbeam_offset-(crossbeam_spacing/2),
                    chassis_width - crossbeam_from_edge,
                    cut_z_min_safe-(chassis_thick/4)])
                rotate([0,180,0])
                    hole_through(name=crossbeam_size, l=cut_z_max_safe-cut_z_min_safe, cl=0.1, h=0, hcl=0.4);   
            translate([((crossbeam_length/crossbeam_count)*q)-crossbeam_offset-(crossbeam_spacing/2),
                    -1*(chassis_width - crossbeam_from_edge),
                    cut_z_min_safe-(chassis_thick/4)])
                rotate([0,180,0])
                    hole_through(name=crossbeam_size, l=cut_z_max_safe-cut_z_min_safe, cl=0.1, h=0, hcl=0.4); 
                    //chassis_mount();
        }
    }
}

module chassis_mount()
{
    union()
    {
        hole_through(name=crossbeam_size, l=cut_z_max_safe-cut_z_min_safe, cl=0.1, h=0, hcl=0.4);   
        translate([0,0,-1*hex_depth]) // TODO this 
            nutcatch_parallel("M3", l=chassis_thick);
    }
}

// Primary Structure
module chassis_frame()
{
    union()
    {
        difference()
        {
            chassis_hull(curve_offset, chassis_width, chassis_thick, chassis_round, fpv_camera);
            translate([0,0,-1]) // Side frame cutout
                chassis_hull(chassis_length/4,chassis_side_opening_height, chassis_thick+2, chassis_round,false);
            if(fpv_camera) // screw hole for camera
            {
                translate([chassis_length/2+chassis_width-(crossbeam_from_edge),0,chassis_thick*2])
                    hole_through(name=motor_hole_size_screw, l=cut_z_max_safe+chassis_thick, cl=0.1, h=0, hcl=0.4);
            }
             // FAA drone id
            *translate([0,chassis_width/2,chassis_thick*0.95])
                rotate([180,180,0])
                    linear_extrude(height = 1, center = true, convexity = 1000, twist = 0) 
                        text(faa_drone_id, size=chassis_thick);
       }
    }
}

module chassis_hull(length, width, thick, round, camera)
{
    hull()
    {
        edge_offset = (width - round);

        // front rounded curve - top
        translate([length,-edge_offset,0])
            cylinder(thick, r=round, $fn=128);
        // front rounded curve - bottom
        translate([length,edge_offset,0])
            cylinder(thick, r=round, $fn=128);

        // back rounded curve - top
        translate([-length,-edge_offset,0])
            cylinder(thick, r=round, $fn=128);
        // back rounded curve - bottom
        translate([-length,edge_offset,0])
            cylinder(thick, r=round, $fn=128);
        
        if(camera)
        {
            translate([length+width,0,0])
                cylinder(thick, r=round, $fn=128);
            *translate([length+width-(width/3),width/2,0]) // Bent edge to protect camera
                cylinder(thick, r=round, $fn=128);
            *translate([length+width-(width/3),-width/2,0]) // Bent edge to protect camera
                cylinder(thick, r=round, $fn=128);
        }
    }
}

module chassis_motor_arm_mount() // Holes for mounting a motor arm
{
    union()
    {
        translate([ motor_arm_box, motor_arm_box, 0])
            chassis_mount();
        translate([-motor_arm_box, motor_arm_box,0])
            chassis_mount();
        translate([ motor_arm_box,-motor_arm_box,0])
            chassis_mount();
        translate([-motor_arm_box,-motor_arm_box,0])
            chassis_mount();
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MOTOR ARM
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module motor_arm(type) // An entire motor arm
{
    difference() // scrape off anything sticking below the mount plate from tipping the arm
    {
        union()
        {
            motor_arm_mount_plate();
            if( type == "a" )
            {
                translate([-(chassis_thick/1.25),-7,-chassis_thick])  // XXX MAGIC
                    rotate([0,motor_arm_tilt_a,0,0]) 
                        motor_arm_structure(type);
            } else {            
                translate([+(chassis_thick/2.7),-7,-chassis_thick])  // XXX MAGIC
                    rotate([0,motor_arm_tilt_b,0])  
                        motor_arm_structure(type);
            }
        }    
        translate([(mount_plate_size*-2)/1,(mount_plate_size*-3)/2,-30])
            cube(size=[mount_plate_size*4,mount_plate_size*4,30]);
    }
}

module motor_arm_mount_plate() // Where the motor arm attaches to the frame
{
    difference()
    {
        plate(mount_plate_size*2+motor_arm_edge, mount_plate_size*2+motor_arm_edge, chassis_thick, 2); // TODO MAGIC ugh this is a mess right here.
        translate([0,0,cut_z_min_safe])
            cylinder(cut_z_max_safe, r=motor_arm_wire_diameter); // wiring hole
        translate([0,0,cut_z_max_safe])
            chassis_motor_arm_mount(); // bolt holes
    }    
}

// section of motor arm that extends out from frame
module motor_arm_structure(type)
{
    support_rotate = 9; // degrees tilt for the support structure XXX TODO hardcoded magic number

    motor_arm_width = mount_plate_size*2*motor_arm_width_modifier;
    support_length = motor_arm_length * 0.68;
    arm_location = [-0.48*motor_arm_width,-1*(motor_arm_width/2)+(motor_arm_edge*1.5),0];// XXX TODO more stupid magic numbers
    base_hole_location = arm_location+[motor_arm_width/2,5,motor_arm_length-(motor_arm_edge*2)];
    shaft_hole_location = base_hole_location-[0,chassis_thick*6,(motor_hole_width1/2)]; // XXX ugly
   
    
    arm_direction_support_offset = (type == "a") ? chassis_thick * -1.1 : chassis_thick * 1.1;
    difference() // Prune off any parts that come over the top from the support arms
    {
        union()
        {   // Main arm rectangle
            translate(arm_location)
                cube([motor_arm_width,chassis_thick,motor_arm_length-mount_motor_circle_size-3]); // XXX MAGIC -3
            
            // Mount interface
            translate(shaft_hole_location+[0,motor_arm_width+chassis_thick,0])
                rotate([270,135,0])
                    motor_arm_interface(mount_motor_circle_size);

            // Support wedge
            //translate(arm_location+[0,0,motor_arm_length-mount_motor_circle_size])
            //    %cube([mount_motor_circle_size,20,20]);
                    
            difference()
            {
                // main arm bottom support 
                rotate([-support_rotate,0,0])
                    translate(arm_location+[(motor_arm_width/2)-(chassis_thick/2)+arm_direction_support_offset,-2.4*chassis_thick,-1])
                        cube([chassis_thick,chassis_thick*3,support_length]); // XXX MAGIC TODO
                // Erase anything that sticks out over the top of the arm from the main arm supports
                translate(arm_location+[-motor_arm_width,chassis_thick,-motor_arm_length/2])
                    cube([motor_arm_width*3,30,motor_arm_length*2]);
            }

            difference()
            {
                union()
                {
                    // main arm top support 1
                    rotate([support_rotate*1,0,0])
                        translate(arm_location+[0,0.8*chassis_thick,-1]) // XXX TODO
                            cube([chassis_thick,chassis_thick*2.5,support_length]);
                    // main arm top support 2
                    rotate([support_rotate*1,0,0])
                        translate(arm_location+[motor_arm_width-chassis_thick,0.8*chassis_thick,-1]) // XXX TODO
                            cube([chassis_thick,chassis_thick*2.5,support_length]);          
                }
                // Erase anything that sticks out over the top of the arm from the main arm supports
                translate(arm_location+[-motor_arm_width,-30,-motor_arm_length/2])
                    cube([motor_arm_width*3,30,motor_arm_length*2]);
            }
        }  
            
        // Zip tie hold downs for motor wires
        if(motor_arm_esc_outboard) {
            // Zip tie hold down - motor end 1 
            translate(base_hole_location-[motor_arm_width/2-(motor_arm_edge*1.25),chassis_thick*-1,motor_arm_length/3])
                rotate([270,90,0])
                    hole_through(name=zip_tie_size, l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
            // Zip tie hold down - motor end 2
            translate(base_hole_location-[-1*(motor_arm_width/2-(motor_arm_edge*1.25)),chassis_thick*-1,motor_arm_length/3])
                rotate([270,90,0])
                    hole_through(name=zip_tie_size, l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);                
            // Zip tie hold down - chassis end 1 
            translate(base_hole_location-[motor_arm_width/2-(motor_arm_edge*1.25),chassis_thick*-1,motor_arm_length/1.4])
                rotate([270,90,0])
                    hole_through(name=zip_tie_size, l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
            // Zip tie hold down - chassis end 2
            translate(base_hole_location-[-1*(motor_arm_width/2-(motor_arm_edge*1.25)),chassis_thick*-1,motor_arm_length/1.4])
                rotate([270,90,0])
                    hole_through(name=zip_tie_size, l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);    
        } else {
            // Zip tie hold down - motor end 1 
            translate(base_hole_location-[-motor_arm_width,chassis_thick-5.2,motor_arm_length/1.5]) // XXX MAGIC
                rotate([0,90,0])
                    hole_through(name=zip_tie_size, l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
            // Zip tie hold down - motor end 2
            translate(base_hole_location-[-motor_arm_width,chassis_thick+3.1,motor_arm_length/1.5]) // XXX MAGIC
                rotate([0,90,0])
                    hole_through(name=zip_tie_size, l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);                        
            
        }
       
        // Motor shaft hole TODO the *6 stuff is hacky to make the hole go all the way through
        /* // Moved to motor arm interface
        translate(shaft_hole_location)
            rotate([270,90,0])
                cylinder(chassis_thick*6, r=3.2);
        */
    }
}

// Section of motor arm that connects to the motor
module motor_arm_interface()
{  
    difference()
    {
        // Base piece
        cylinder(chassis_thick, d=mount_motor_circle_size);
        
        // central shaft hole
        translate([0,0,-1])
            rotate([180,0,0])
                hole_through(name=motor_hole_size_shaft, l=motor_arm_thick+2, cl=0.1, h=0, hcl=0.4);
        
        // motor mounting holes
        translate([ (motor_hole_width1/2),0,-1]) // #1
            rotate([180,0,0])
                hole_through(name=motor_hole_size_screw, l=motor_arm_thick+2, cl=0.1, h=0, hcl=0.4);
        translate([-(motor_hole_width1/2),0,-1]) // #2
            rotate([180,0,0])
                hole_through(name=motor_hole_size_screw, l=motor_arm_thick+2, cl=0.1, h=0, hcl=0.4);
        translate([0, (motor_hole_width2/2),-1]) // #3
            rotate([180,0,0])
                hole_through(name=motor_hole_size_screw, l=motor_arm_thick+2, cl=0.1, h=0, hcl=0.4);
        translate([0,-(motor_hole_width2/2),-1]) // #4
            rotate([180,0,0])
                hole_through(name=motor_hole_size_screw, l=motor_arm_thick+2, cl=0.1, h=0, hcl=0.4);
        
        // Motor vent holes
        translate([ motor_hole_width1/3, motor_hole_width1/3,-1]) // vent #1 XXX magic /3
            rotate([0,0,45])
                motor_arm_vent_hole();
        translate([-motor_hole_width1/3, motor_hole_width1/3,-1]) // vent #1 XXX magic /3
            rotate([0,0,135])
                motor_arm_vent_hole();
        translate([ motor_hole_width1/3,-motor_hole_width1/3,-1]) // vent #1 XXX magic /3
            rotate([0,0,135])
                motor_arm_vent_hole();
        translate([-motor_hole_width1/3,-motor_hole_width1/3,-1]) // vent #1 XXX magic /3
            rotate([0,0,45])
                motor_arm_vent_hole();   
    }
}

// Kinda a kidney bean shape on most motors
module motor_arm_vent_hole()
{
    scale([1,1.5,1])
        cylinder(motor_arm_thick+2,r=motor_hole_size_vent);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CAMERA TRAY
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

camera_thick = 3;
camera_width = 32;
camera_height = 32;
camera_hole_size = "M3";

module camera_tray()
{
    union()
    {
        side_mount_size_ratio = 1.6; // What we divide camera_width/height by for the side plates
        // Back plate
        plate(camera_width, camera_height, camera_thick, 1);
        difference()
        {
            translate([0,camera_thick/1.5,0]) /// XXX TODO MAGIC 1.5? why?
            {
                union()
                {
                    rotate([45,0,0])
                    {
                        // One side mount
                        translate([-(camera_width/2)-camera_thick/2,0,camera_thick]) /// XXX MAGIC 2
                            rotate([45,90,45])
                                plate(camera_height/side_mount_size_ratio, camera_height/side_mount_size_ratio, camera_thick, 2);
                        // Other side mount
                        translate([camera_width/2.2,0,camera_thick]) // XXX MAGIC - camera_width/2
                            rotate([45,90,45])
                                plate(camera_height/side_mount_size_ratio, camera_height/side_mount_size_ratio, camera_thick, 2);
                    }
                }
            }
            // Put screw holes through one support
            translate([-(camera_width/2)+(camera_thick*1.25),0,camera_height/1.9-crossbeam_from_edge])
                rotate([0,90,0])
                    union() {
                        hole_through(name=camera_hole_size, l=camera_thick*2, cl=0.1, h=0, hcl=0.5); 
                        nutcatch_parallel("M3", l=chassis_thick);
                    }
            // Put screw holes through other support
            translate([(camera_width/2)-(camera_thick*1.25),0,camera_height/1.9-crossbeam_from_edge])
                rotate([180,90,0])
                    union() {
                        hole_through(name=camera_hole_size, l=camera_thick*2, cl=0.1, h=0, hcl=0.5); 
                        nutcatch_parallel("M3", l=chassis_thick);
                    }
            // Scrape off the other half of the support triangles
            translate([-camera_width,-camera_height,-camera_height*2]) 
                cube([camera_width*2,camera_height*2,camera_height*2]);
            // Cut out a section for the actual camera to make sure it fits
            translate([-camera_width/2,-camera_height/2,camera_thick+1]) // +1 for zeal / mounting gel
                cube([camera_width, camera_height, 3]);
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BASE BOARD
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
top_board_length = (length > 0) ? length : crossbeam_spacing + (crossbeam_outer_size);
offset = 5;

module base_board(top_thick, base_thick, length=0)
{
    difference()
    {
        union()
        {
            // Top thin plate
            translate([offset/2,0,0]) // XXX TODO evaluate "offset" globally... 
                plate(top_board_length+offset, crossbeam_width+(chassis_thick*2), top_thick, top_board_thick);
            // Main base piece
            translate([0,0,top_board_thick]) 
                plate(top_board_length, crossbeam_width, base_thick, 1);

            // crossbeam blocks
            for (q = [0 : crossbeam_count-1])
            { 
                translate([-(top_board_length/2)+(crossbeam_spacing * q)+offset,-(crossbeam_width/2),top_board_thick])
                      cube([crossbeam_outer_size, crossbeam_width, crossbeam_outer_size+(crossbeam_from_edge-crossbeam_outer_size/2)]);
            }
        }
        // crossbeam holes
        for (q = [0 : crossbeam_count-1])
        { 
            translate([-(top_board_length/2)+(crossbeam_spacing * q)+3,-(crossbeam_width/2),top_board_thick]) // XXX MAGIC 15 wtf
                // -1 is to clear the back side so f5 refresh shows cuts fully
                translate([crossbeam_outer_size/2,-1,(crossbeam_outer_size/2)+(crossbeam_from_edge-(crossbeam_outer_size/2))]) 
                    rotate([90,0,0])
                        nutcatch_parallel(crossbeam_size, l=crossbeam_width+2); // crossbeam_width gets +2 so f5 cuts show fully
        }
        // cut out notches to make rotating the plate easy
        translate([-(top_board_length/2)-1-offset,-(crossbeam_width/2),-1])
            rotate([0,0,270])
                cube([crossbeam_outer_size*2,(chassis_thick*2)*3,crossbeam_outer_size*2]);
        translate([-(top_board_length/2)-1,(crossbeam_width/2),-1])
            rotate([0,0,0])
                cube([crossbeam_outer_size*2,(chassis_thick*2)*3,crossbeam_outer_size*2]);      
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Top board
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module top_board()
{
    cc3d_offset = -20; 
    cc3d_size = 35;  
    cc3d_center = [cc3d_offset+25,0,2];
    mount_post_size = 5;
    mount_post_height = 3;

    if(design_mode) {    
        translate([5,0,7])
            rotate([0,0,270])
                component_cc3d();
    }
    length = 0;
    difference()
    {
        union()
        {
            difference() // Quick hack to flip the board over so the cc3d can go on top temporarily
            {
                translate([0,0,crossbeam_outer_size+top_board_thick+1]) // XXX todo +1
                    rotate([180,0,0])
                        base_board(top_board_thick, crossbeam_outer_size+top_board_thick, length);
                // quick hack to cut the top edges off 
                translate([-50,crossbeam_width/2,0])
                    cube([100,20,50]);
                translate([-50,-crossbeam_width/2-20,0])
                    cube([100,20,50]);
                // cut out a drop down for it to sit
                translate([-22,-crossbeam_width/2-1,2])
                    cube([52,crossbeam_width+2,16]);
            }
            
            // Under the CC3D
            //translate([cc3d_offset,0,top_board_thick]) 
            //    plate(35, crossbeam_width, crossbeam_outer_size+top_board_thick, 1); // 35 = CC3D dimension

            // CC3D mount lift #1
            translate(cc3d_center+[-(cc3d_offset/2),-cc3d_offset/2,0]+[mount_post_size/2,mount_post_size/2,0])
                cube([mount_post_size,mount_post_size,mount_post_height]);
            // CC3D mount lift #2
            translate(cc3d_center+[-(cc3d_offset/2), cc3d_offset/2,0]+[mount_post_size/2,-mount_post_size*1.5,0])
                cube([mount_post_size,mount_post_size,mount_post_height]);
            // CC3D mount lift #3
            translate(cc3d_center+[ (cc3d_offset/2),-cc3d_offset/2,0]-[mount_post_size*1.5,-mount_post_size/2,0])
                cube([mount_post_size,mount_post_size,mount_post_height]);
            // CC3D mount lift #4
            translate(cc3d_center+[ (cc3d_offset/2), cc3d_offset/2,0]-[mount_post_size*1.5,mount_post_size*1.5,0])
                cube([mount_post_size,mount_post_size,mount_post_height]);
        }
     }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// POWER BOARD
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module power_board()
{
    depression_width = 38;
    depression_depth = 3;
    
    length = crossbeam_spacing + (crossbeam_outer_size*3);
    
    difference()
    {
        base_board(top_board_thick, crossbeam_outer_size+top_board_thick, length);
        translate([0,0,crossbeam_outer_size+1]) // +1 on Z here for a clean cut
            cube([depression_width,crossbeam_width+2,depression_depth+1], center=true);
    }
    
    
    esc_offset = 5;
    
    if(design_mode)
    {
        translate([0,0,crossbeam_outer_size+top_board_thick]) // power distribution board
            component_powerboard();
        // ESC's
        translate([30,6,crossbeam_outer_size+top_board_thick+2])
            rotate([0,0,180])
                component_esc();
        translate([30,-9,crossbeam_outer_size+top_board_thick+2])
            rotate([0,0,180])
                component_esc();    
        translate([-30,6,crossbeam_outer_size+top_board_thick+2])
            rotate([0,0,0])
                component_esc();    
        translate([-30,-9,crossbeam_outer_size+top_board_thick+2])
            rotate([0,0,0])
                component_esc();    

    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Back Piece (LED lights)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module back_piece()
{
    width = crossbeam_width-1; // XXX TODO why do I need to subtract one here?  without this it forces the frames apart a bit
    height = chassis_width*1.6; // XXX TODO chassis_width
    depth = motor_arm_box * 1.2;;
    thick = chassis_thick;
    edge_thick = thick * 1;
    led_per_row = 3;
    led_diameter = 5.2;

    // main back plate
    difference()
    {
        union()
        {
            plate(width, height, thick, 1);
            translate([-10.5,0,thick])
                cube([20,12,3.5]);
        }
        // XT60 connector
        translate([7.5,10,8]) // XXX MAGIC NUMBERS
            rotate([0,180,90])
                    component_xt60();
        // LED holes row #1
        translate([-8.5,-7,-1]) /// XXX MAGIC NUMBERS
            for (q = [0 : led_per_row-1]) {
                translate([q*8,0,0])
                    cylinder(7, d=led_diameter);
            }
    }
        
    // support #1
    translate([width/2-edge_thick,0,depth/2+thick-1]) // -1 here, plate width depth+1 to overlap pieces
        rotate([0,90,0])
            difference()
            {
                plate(depth+1,height*0.9,edge_thick, 1);
                translate([motor_arm_box,0,-2+hex_depth])
                    rotate([0,180,0])
                        chassis_motor_arm_mount();
            }
    // support #2
    translate([-(width/2-edge_thick),0,depth/2+thick-1]) // -1 here, plate width depth+1 to overlap pieces
        rotate([0,270,0])
            difference()
            {
                plate(depth+1,height*0.9,edge_thick, 1);
                translate([motor_arm_box,0,-2+hex_depth])
                    rotate([0,180,0])
                        chassis_motor_arm_mount();
            }    
 /*           
    // battery power plate
    translate([0,-(height/2-edge_thick),depth/2+thick-1]) // -1 here, plate width depth+1 to overlap pieces
        rotate([90,90,0])
            difference()
            {
                plate(depth+1,width,edge_thick, 1);
                ;
            }        
            */
    
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Common
module plate(width, height, thick, curve)
{
    hull() // Main mounting plate piece
    {
        translate([ (width/2)-curve,  (height/2)-curve, 0])
            cylinder(thick, r=curve);
        translate([-(width/2)+curve,  (height/2)-curve, 0])
            cylinder(thick, r=curve);
        translate([ (width/2)-curve, -(height/2)+curve, 0])
            cylinder(thick, r=curve);
        translate([-(width/2)+curve, -(height/2)+curve, 0])
            cylinder(thick, r=curve);
    }
  
}

// XT60 female female suitable for differencing from a holder
module component_xt60()
{
    xt60_width = 8.4;
    xt60_length = 16.2;
    xt60_depth = 8.6;
    xt60_corner = xt60_width/3;
    xt60 = [[0,0],[0,xt60_length-xt60_corner],[xt60_corner,xt60_length], // ------\
            [xt60_width-xt60_corner,xt60_length],                        //        |
            [xt60_width,xt60_length-xt60_corner],[xt60_width,0]];        // ------/

    difference() {
        linear_extrude(height=xt60_depth)
            polygon(xt60);
        // protrusions designed to hook into the slot at the back of an xt60 connector
//        translate([-0.1,2,2])
//            cube([1,9.2,2]);
//        translate([xt60_width-0.9,2,2])
//            cube([1,9.2,2]);
    }
    
}
// Powerboard place holder component
module component_powerboard(zeal=false)
{
    zeal_thick = 5.5;
    
    pcb_x = 35;
    pcb_y = 35;
    pcb_z = 1.5;
    
    block_x = 19.3;
    block_y = 24.75;
    block_z = 3.9;

    diff_x = pcb_x-block_x/2;
    diff_y = pcb_y-block_y/2;    

    union()
    {
        color([0.1, 0.4, 0.1])
            difference()
            {
                // green pcb
                plate(pcb_x, pcb_y, pcb_z, pcb_z);
                // holes
                translate([(pcb_x/2)-2.5,(pcb_y/2)-2.5,pcb_z+1])
                    hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
                translate([-(pcb_x/2)+2.5,(pcb_y/2)-2.5,pcb_z+1])
                    hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
                translate([(pcb_x/2)-2.5,-(pcb_y/2)+2.5,pcb_z+1])
                    hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
                translate([-(pcb_x/2)+2.5,-(pcb_y/2)+2.5,pcb_z+1])
                    hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
            }
        translate([0,0,pcb_z]) 
            color([0.8, 0.8, 0.8])
                plate(block_x, block_y, block_z, 0.5);
    }
}

// ESC template
module component_esc()
{
    x = 23;
    y = 12;
    z = 4.5;
    wire = 5; // length of the wire segments
    
    union() {
        color([0.5,0.5,0.5])
            plate(x,y,z,0.2);  
        // red power wire
        color([1,0,0])
            translate([x/2,y/4,z/4])
                rotate([0,90,0])
                    cylinder(wire,1);
        // black power wire
        color([0.1,0.1,0.1])
            translate([x/2,-y/4,z/4])
                rotate([0,90,0])
                    cylinder(wire,1);
        // grey brush #1
        color([0.4,0.4,0.4])
            translate([-x/2,-y/4,z/4])
                rotate([0,270,0])
                    cylinder(wire,1);
        // grey brush #2
        color([0.4,0.4,0.4])
            translate([-x/2,0,z/4])
                rotate([0,270,0])
                    cylinder(wire,1);
        // grey brush #3
        color([0.4,0.4,0.4])
            translate([-x/2,y/4,z/4])
                rotate([0,270,0])
                    cylinder(wire,1);
    } 
}

// CC3d template
module component_cc3d()
{
    cc3d_x = 35;
    cc3d_y = 35;
    cc3d_z = 1.5;
    
    union()
    {
        color([0.95, 0.95, 0.95]) // base white plate
        difference()
        {
            plate(cc3d_x, cc3d_y, cc3d_z, cc3d_z);
            // holes
            translate([(cc3d_x/2)-2.5,(cc3d_y/2)-2.5,cc3d_z+1])
                hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
            translate([-(cc3d_x/2)+2.5,(cc3d_y/2)-2.5,cc3d_z+1])
                hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
            translate([(cc3d_x/2)-2.5,-(cc3d_y/2)+2.5,cc3d_z+1])
                hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
            translate([-(cc3d_x/2)+2.5,-(cc3d_y/2)+2.5,cc3d_z+1])
                hole_through(name="M3", l=chassis_thick*6, cl=0.1, h=0, hcl=0.5);
        }
        
        // speed controller pins
        translate([(cc3d_x/2)-4,-3,cc3d_z]) {
            for (q = [0 : 5]) { 
                translate([0,q*2.40,0]) {
                    union() { // one group of 3 pins + block
                        // the black base block
                        color([0.1,0.1,0.1]) 
                            plate(7.5, 2.35, 2.5, 0.25);
                        // all three pins
                        color([0.7,0.65,0.25]) {
                            translate([-2.5,0,0.25]) {
                                for (p = [0 : 2]) {
                                    translate([p*2.54,0,0]) { //one individual pin
                                        plate(0.65, 0.65, 6.00, 0.1);
                                    }
                                }
                            }
                        }
                    }
                }   
            }
        }
        
        // Mini-USB port on under side
        translate([-4.2,-(cc3d_y/2)+8.7,0])
            rotate([180,0,0])
                color("silver")
                    component_port([7.5, 9.3, 3.65]);
        // SWD connector on under side
        translate([(cc3d_x/2)-4,-11,0])
            rotate([180,0,90])
                color([0.95,0.95,0.8])
                    component_port([6, 3.43, 3]);
        // Flexi port
        translate([-(cc3d_x/2)+7,-(cc3d_y/2)+3.8,3+cc3d_z])
            rotate([180,0,0])
                color([0.95,0.95,0.8])
                    component_port([6, 3.43, 3]);
        // Main port
        translate([(cc3d_x/2)-14,-(cc3d_y/2)+3.8,3+cc3d_z])
            rotate([180,0,0])
                color([0.95,0.95,0.8])
                    component_port([6, 3.43, 3]);
        // "Left" port
        translate([-(cc3d_x/2)+4.2,-5,cc3d_z])
            rotate([00,0,90])
                color([0.95,0.95,0.8])
                    component_port([10, 4, 3]);       
    
    }
}

// thick = percent thick the walls should be, default 5%
module component_port(size=[5,5,5], thick=5)
{
    this_thick = size[0]*(thick/100);
    difference()
    {
        cube(size);
        translate([this_thick,this_thick,this_thick])
            cube(size-[this_thick*2,this_thick-1,this_thick*2]);
    }
}

include <nutsnbolts/cyl_head_bolt.scad>


if(assembled)
{
    explode = 1;
    translate([0,((crossbeam_width/2)+chassis_thick)*explode,(chassis_width+top_board_thick)*explode])
        rotate([90,0,0])
            chassis();
    translate([0,-1*(crossbeam_width/2)*explode,(chassis_width+top_board_thick)*explode])
        rotate([90,0,0])
            chassis();
    
    power_board();
    
    translate([0,0,32])
        rotate([0,0,0])
            top_board(1,chassis_thick);
    
    translate([motor_center_a,-((crossbeam_width/2)+chassis_thick),chassis_width])
        rotate([90,0,0])
            motor_arm("a");
    translate([motor_center_a,((crossbeam_width/2)+chassis_thick),chassis_width])
        rotate([270,180,0])
            motor_arm("b");
    translate([-motor_center_a,-((crossbeam_width/2)+chassis_thick),chassis_width])
        rotate([90,0,0])
            motor_arm("b");    
    translate([-motor_center_a,((crossbeam_width/2)+chassis_thick),chassis_width])
        rotate([270,180,0])
            motor_arm("a");

} else {
    if(part == "chassis")
        chassis();
    if(part == "back_piece")
        back_piece();
    if(part == "top_board")
        top_board(1,chassis_thick);
    if(part == "power_board")
        power_board();
    if(part == "camera_tray")
        camera_tray();
    if(part == "motor_arm_a")
        motor_arm("a");
    if(part == "motor_arm_b")
        motor_arm("b");
}

// component testing
if(show_components) {   
    translate([50,50,20])  component_powerboard();
    translate([100,50,20]) component_cc3d();
    translate([150,50,20]) component_esc();
    translate([180,50,20]) component_xt60();
}