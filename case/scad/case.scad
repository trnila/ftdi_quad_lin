include <NopSCADlib/lib.scad> 
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/d_connectors.scad>
include <NopSCADlib/vitamins/d_connector.scad>
include <NopSCADlib/vitamins/pcb.scad>
include <NopSCADlib/printed/printed_box.scad>
include <NopSCADlib/vitamins/d_connectors.scad>
include <NopSCADlib/vitamins/leds.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/printed/led_bezel.scad>

use <NopSCADlib/vitamins/pcb.scad>
use <NopSCADlib/printed/foot.scad>

$explode = 0;

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
pcb_spacing = 0.8;
pcb_tol = 0.06;
pcb_screw_offset = 3.45;

led_activity_bezel = led_bezel(LED3mm, height=5);


foot = Foot(d = 7, h = 5, t = 2, r = 1, screw = M3_pan_screw);
box_top_thickness = wall;
box_base_thickness = wall + pcb_thickness;
base_pos_z = h + box_top_thickness + box_base_thickness + 2 * eps;
module foot_stl() foot(foot);
ftdi_quad_lin_box = pbox(
    name = "ftdi_quad_lin_box",
    wall = wall,
    top_t = box_top_thickness,
    base_t = box_base_thickness,
    radius = 0,
    size = [w1, w2, h],
    screw = M3_pan_screw,
    short_insert = true
);

module barrel_jack(cutout = false) { //! Draw barrel power jack
    l = 13.2;
    w = 8.89;
    h = 9;
    bore_d = 6.3;
    bore_h = 5;
    bore_l = 11.8;
    pin_d = 2;
    front = 3.3;
    r = 0.5;
    contact_d = 2;
    contact_w = 4;
    inset = 1;
    if(cutout) {
        rotate([0, 90, 0])
            translate([-bore_h, 0])
                cylinder(d = bore_d + panel_clearance, h = 100);
    } else {
        color(grey(20)) rotate([0, 90, 0]) {
            linear_extrude(l, center = true) {
                difference() {
                    translate([-h / 2, 0])
                        rounded_square([h, w], r);

                    translate([-bore_h, 0])
                        circle(d = bore_d);

                    translate([-h / 2 - bore_h, 0])
                        square([h, w], center = true);

                }
            }
            translate_z(l / 2 - front)
                linear_extrude(front) {
                    difference() {
                        translate([-h / 2, 0])
                            rounded_square([h, w], r);

                        translate([-bore_h, 0])
                            circle(d = bore_d);
                    }
                }

            translate([-bore_h, 0])
                tube(or = w / 2 - 0.5, ir = bore_d / 2, h = l);

            translate([-bore_h, 0, -l / 2])
                cylinder(d = w -1, h = l - bore_l);
        }
        color("silver") {
            translate([l / 2 - inset - pin_d / 2, 0, bore_h])
                hull() {
                    sphere(pin_d / 2);

                    rotate([0, -90, 0])
                        cylinder(d = pin_d, h = bore_l - inset);
                }
            hull() {
                translate([l / 2 - inset - contact_d / 2, 0, bore_h - bore_d / 2])
                    rotate([90, 0, 0])
                        cylinder(d = contact_d, h = contact_w, center = true);

                translate([l / 2 - bore_l, 0,  bore_h - bore_d / 2 + contact_d / 4])
                    cube([eps, contact_w, eps], center = true);
            }
        }
    }
}


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
        [ 3.7,   12.49, 180, "usb_C"],
        [  6,       66, 180, "barrel_jack"],
        [  22.11,  7.5/*3.5*/,   0, "2p54socket", 11, 1, 1],
        
        [   15.9, 76.3,   0, "jst_xh", 5],
        [   51.2, 12.9,  90, "jst_xh", 3],
        [   51.2, 31.1,  90, "jst_xh", 3],
        [   51.2, 49.1,  90, "jst_xh", 3],
        [   51.2, 66.5,  90, "jst_xh", 3],
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
        
        hole_h = (pcb_thickness+pcb_spacing);
        translate([0, 0, box_base_thickness - hole_h/2])
        cube([w1+pcb_tol, w2+pcb_tol, hole_h], center=true);
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
        
        translate([0, 0, h + box_top_thickness + box_base_thickness/2 + 2 * eps])
        vflip()
            pcb_cutouts(ftdi_quad_lin_pcb);
    }
}


module LED3mm_bezel_stl() stl("LED3mm_bezel") {
    led_bezel(led_activity_bezel);
}

module LED3mm_bezel_retainer_stl() stl("LED3mm_bezel_retainer") {
    led_bezel_retainer(led_activity_bezel);
}

//! 1. Solder wire from J7 pin 5 to 3th LED anode (+)
//! 1. Chain and solder wire to all other anodes (+)
//! 1. solder 3th LED cathode (-) to J7 pin 4
//! 1. solder 2th LED cathode (-) to J7 pin 3
//! 1. solder 1th LED cathode (-) to J7 pin 2
//! 1. solder 0th LED cathode (-) to J7 pin 1
//! 1. Insert LEDs into the bezels
module led_activity_assembly() assembly("led_activity") {
    led = led_bezel_led(led_activity_bezel);
    d = led_diameter(led);
    translate_z(led_bezel_flange_t(led_activity_bezel)) {
        vflip()
            stl_colour(pp1_colour)
                led_bezel(led_activity_bezel);

        translate_z(-led_height(led) + (is_num(d) ? d / 2 : 0))
            explode(-13)
                led(led, "red");
    }
}

//! Place FTDI Quad LIN PCB into base part.
module ftdi_quad_lin_box_base_assembly()
pose([ 45.70, 0.00, 280.00 ], [ 0.52, -11.90, 43.01 ])
assembly("ftdi_quad_lin_box_base") {
    ftdi_quad_lin_box_base_stl();
   
    explode(20) {
        translate([0, 0, pcb_thickness])
        pcb(ftdi_quad_lin_pcb);
    }
}

module slide_switch() {
    vitamin("slide_switch(SS-12F15): SlideSwitch");
    lever_h = 5;
    body_h = 5;
    body_w1 = 2/3*lever_w1;
    color("gray")
        translate([lever_hole_w1/2 - lever_btn_w1/2, 0, -lever_h/2])
            cube([lever_btn_w1, lever_hole_w2, lever_h], center=true);
        
        translate([0, 0, lever_thickness])
            color("silver")
            cube([lever_w1, lever_w2, lever_thickness], center=true);
        
        translate([0, 0, lever_thickness+body_h/2])
        color("yellow")
            cube([body_w1, 2/3*lever_w2, body_h], center=true);
    
        for(i = [-1, 0, 1]) {
            translate([i * body_w1/3, 0, lever_thickness+body_h])
            color("silver")
                cube([1, 1, 3]);
        }
        
}

//! 1. Insert 4x LED with bezel into hole and screw with retainer
//! 2. Insert 4x slide switches and glue them inside
//! 3. insert 4x DCONN9 connectors and secure them with pillar and nuts
module ftdi_quad_lin_box_assembly() assembly("ftdi_quad_lin_box") {
    ftdi_quad_lin_box_stl();
    
    dsub() {
        explode(-15) {
            d_plug(DCONN9);
        }
        
        translate([0, 0, wall])
        d_connector_holes(DCONN9) {
            explode(10)
                d_pillar();
            explode(-20) 
                translate([0, 0, -2*wall])
                nut(M2_nut);
        }
        
        dsub_led_activity() {
            explode(10)
            translate([0, 0, 2])
                led_activity_assembly();

            translate_z(-2)
            vflip()
            stl_colour(pp2_colour)
                explode(40)
                    led_bezel_retainer(led_activity_bezel);
        }
    }

    explode(55)
        lin_positions()
            slide_switch();
}


//! 1. Place 4x heated inserts
//! 1. Connect LEDs wire into J7
//! 1. Connect LIN 0 power switch to JP5
//! 1. Connect LIN 1 power switch to JP6 
//! 1. Connect LIN 2 power switch to JP7 
//! 1. Connect LIN 3 power switch to JP8 
//! 1. Connect LIN 1 CONN9 to J2
//! 1. Connect LIN 2 CONN9 to J3
//! 1. Connect LIN 3 CONN9 to J4
//! 1. Connect LIN 4 CONN9 to J5
//! 1. Screw base into the box with 4x M3 screws
//! 1. Screw the base into the box
module main_assembly()
pose([ 246.80, 0.00, 316.40 ], [ 0.52, -11.90, 43.01 ])
assembly("main") {
    ftdi_quad_lin_box_assembly();
    
    explode(40) {
         translate_z(base_pos_z) vflip()
            ftdi_quad_lin_box_base_assembly();
    }
    
    explode(20)
        pbox_inserts(ftdi_quad_lin_box);
    
    explode(60)
    pbox_base_screws(ftdi_quad_lin_box);
}

if($preview) {
    main_assembly();
}