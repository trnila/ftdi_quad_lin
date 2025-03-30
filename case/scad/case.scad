include <NopSCADlib/lib.scad> 
include <NopSCADlib/vitamins/geared_steppers.scad>
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/cameras.scad>
include <NopSCADlib/vitamins/inserts.scad>
include <NopSCADlib/vitamins/insert.scad>
include <NopSCADlib/vitamins/d_connectors.scad>
include <NopSCADlib/vitamins/d_connector.scad>
include <NopSCADlib/vitamins/pcb.scad>
include <NopSCADlib/printed/printed_box.scad>

include <NopSCADlib/vitamins/microswitches.scad>
include <NopSCADlib/vitamins/d_connectors.scad>
include <NopSCADlib/vitamins/leds.scad>
include <NopSCADlib/printed/led_bezel.scad>
include <NopSCADlib/vitamins/axials.scad>
include <NopSCADlib/vitamins/radials.scad>
include <NopSCADlib/vitamins/smds.scad>
include <NopSCADlib/vitamins/7_segments.scad>
include <NopSCADlib/vitamins/potentiometers.scad>

use <NopSCADlib/vitamins/pcb.scad>
use <NopSCADlib/printed/foot.scad>

$explode = 0;

// PR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

w1 = 55;
w2 = 80;
h = 42;
wall = 2;

lever_w1 = 23.25;
lever_w2 = 7.3;
lever_hole_w1 = 9;
lever_hole_w2 = 3.8;
lever_btn_w1 = 5.40;
lever_thickness = 0.6;

insert_type = CNCKM3;
insert_w = insert_outer_d(insert_type);

led_dsub_spacing = 5;
led_top_spacing = 5;

pcb_thickness = 1.6;
pcb_spacing = 0.4;
pcb_tol = 0.03;
pcb_screw_offset = 3.45;

led_activity_bezel = led_bezel(LED3mm, height=5);


foot = Foot(d = 7, h = 5, t = 2, r = 1, screw = M3_pan_screw);
module foot_stl() foot(foot);
ftdi_quad_lin_box = pbox(
    name = "ftdi_quad_lin_box",
    wall = wall,
    top_t = wall,
    base_t = 2 + pcb_thickness,
    radius = 0,
    size = [w1, w2, h],
    foot = foot,
    short_insert = true
);


ftdi_quad_lin_pcb = ["ftdi_quad_lin_pcb", "ftdi quad lin",
    w1, w2, pcb_thickness, // length, width, thickness
    0,      // Corner radius
    2.75,   // Mounting hole diameter
    5.5,    // Pad around mounting hole
    "green",// Color
    true,   // True if the parts should be separate BOM items
    // hole offsets
    [ [3.45, 3.45], [3.45, -3.45], [-3.45, 3.45], [-3.45, -3.45] ],
    // components
    [
        [ 3.7, 12.49, 180, "usb_C"],
        [  6, 66, 180, "barrel_jack"],
        [  22.11,  3.5,  0, "2p54header", 11, 1 ,undef, "black", true ],
      
    ],
    // accessories
    []
];

module lin_positions() {
    dcon_w = d_flange_width(DCONN9);
    for(i = [0:3]) {
        translate([0, w2/4*i - w2/2 + 3/2*dcon_w/2, 0]) {
            children();
        }
    }
}

module dsub() {
   dcon_l = d_flange_length(DCONN9);
   lin_positions() {
        translate([w1/2, 0, dcon_l/2 + led_dsub_spacing + led_top_spacing]) {
            rotate([0, 90, 0]) {
                children();
            }
        }
    }
}

module dsub_led_activity() {
    flange_length = d_flange_length(DCONN9);
    translate([flange_length/2 + led_dsub_spacing, 0, 0]) {   
        children();
    }
}

module d_flange(type) {
    cut=0;
    tolerance=0.2;
    flange_length = d_flange_length(type);
    flange_width = d_flange_width(type);
    translate([0, 0, wall/2-1.5])
    linear_extrude(wall)
    rounded_square([flange_length+tolerance, flange_width+tolerance], 2);
}


module ftdi_quad_lin_box_base_stl() stl("ftdi_quad_lin_box_base") {
    difference() {
        union() {
            pbox_base(ftdi_quad_lin_box);
        }
        
        translate([0, 0, (pcb_thickness+pcb_spacing)/2])
        cube([w1+pcb_tol, w2+pcb_tol, (pcb_thickness+pcb_spacing)], center=true);
    }
    
    intersection() {
        pbox_base(ftdi_quad_lin_box);
        pbox_screw_positions(ftdi_quad_lin_box) {
            translate([0, 0, pcb_thickness])
            cylinder(d=6, h=pcb_spacing);
        }
    }
}

module ftdi_quad_lin_box_stl() stl("ftdi_quad_lin_box") {
 difference() {    
        pbox(ftdi_quad_lin_box);
        
        dsub() {
            d_hole(DCONN9, h=10);
            d_flange(DCONN9);
            d_connector_holes(DCONN9) {
                rotate([0, 0, 90])
                cylinder(r=3.05/2, h=wall*10, center=true);
            }
            
            dsub_led_activity() {
                cylinder(r=led_bezel_hole_r(led_activity_bezel), h=10);
            }
        }
        
        lin_positions() {
            translate([0, 0, wall-lever_thickness/2])
            cube([lever_w1, lever_w2, lever_thickness], center=true);
            
            cube([lever_hole_w1, lever_hole_w2, 10], center=true);
        }
        
        translate([0, 0, h+pcb_thickness])
        rotate([180, 0, 0])
        pcb_cutouts(ftdi_quad_lin_pcb);
    }
}


module LED3mm_bezel_stl() stl("LED3mm_bezel") {
    led_bezel(led_activity_bezel);
}

module LED3mm_bezel_retainer_stl() stl("LED3mm_bezel_retainer") {
    led_bezel_retainer(led_activity_bezel);
}

//! 1. Insert LED into the bezel
//! 2. Prepare retainer, but dont screw yet
module LED3mm_red_bezel_assembly() led_bezel_fastened_assembly(led_activity_bezel, 2);

//! Place FTDI Quad LIN PCB into base part.
module ftdi_quad_lin_box_base_assembly()
pose([ 241.20, 0.00, 294.50 ], [ 0.52, -11.90, 43.01 ])
assembly("ftdi_quad_lin_box_base") {
    ftdi_quad_lin_box_base_stl();
    
    explode(-20) {
        translate([0, 0, pcb_thickness])
        rotate([180, 0, 0])
        pcb(ftdi_quad_lin_pcb);
    }
}

//! 1. Insert 4x LED with bezel into hole and screw with retainer
//! 2. Insert 4x slide switches and glue them inside
//! 3. insert 4x DCONN9 connectors and glue them inside
module ftdi_quad_lin_box_assembly() {
    ftdi_quad_lin_box_stl();
    
    dsub() {
        d_plug(DCONN9);
        dsub_led_activity() {
            translate([0, 0, 2])
            led_bezel_fastened_assembly(led_activity_bezel, 2);
        }
    }


    lin_positions() {
        color("gray")
            translate([lever_hole_w1/2 - lever_btn_w1/2, 0, 0])
                cube([lever_btn_w1, lever_hole_w2, 10], center=true);
    }
}


//! 1. Connect LEDs
//! 2. Connect slide switches
//! 3. Connect DCONN9 connectors
//! 4. Screw base into the box with 4x M3
module main_assembly()
pose([ 246.80, 0.00, 316.40 ], [ 0.52, -11.90, 43.01 ])
assembly("main") {
    ftdi_quad_lin_box_assembly();
    
    translate([0, 0, h]) {
        explode(40) {
            ftdi_quad_lin_box_base_assembly();
        }
    }
}

if($preview) {
    main_assembly();
}