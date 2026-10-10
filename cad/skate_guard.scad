// SIKO skate guard v0.1 -- fit and assembly prototype, dimensions in mm.
// NOT validated for walking, 130 kg, or universal skate compatibility.
// Modular length changes require a different centre AND a matched rail pair.
use <branding.scad>
part = "toe_long";
player_number = "88";
blade_thickness = 3.2; // Replace with a measurement; do not infer from skate type.
blade_side_clearance = 1.0; // Initial TPU fit trial only.
$fn = 48;
body_width=64;
body_height=36;
channel_width=16;
channel_floor=12;
rail_inner=20;
rail_slot=4.8; // Steel 4 mm nominal + 0.4 mm on each side.
rail_base=8;
stop=10;

module rounded_rect(l,w,r=3) {
    translate([r,-w/2+r]) offset(r=r) square([l-2*r,w-2*r]);
}
module screw_y(x,z,r=2.75,side=1) {
    // Teardrop ceiling reduces support required in this horizontal bore.
    translate([x,side*34,z]) rotate([90,0,0])
    linear_extrude(height=68,center=true) hull() {
        circle(r=r);
        translate([0,r*1.40]) square([0.10,0.10],center=true);
    }
}
function end_bolts(l) = l>100 ? [30,l-30] : [30,l-30];
function sole_bolts(l,is_end=true) = is_end ? (l>100?[40,l-40]:[30,l-30]) : [l/2];
module body(l=150,end_type="toe") {
    is_end=end_type!="center";
    difference() {
        linear_extrude(body_height) rounded_rect(l,body_width,3);
        // Blade seating well; only the toe or heel has a closed end stop.
        start=end_type=="toe"?stop:-0.2;
        finish=end_type=="heel"?l-stop:l+0.2;
        translate([start,-channel_width/2,channel_floor])
            cube([finish-start,channel_width,body_height]);
        // TPU retaining ribs seat in these shallow side grooves.
        for(side=[-1,1])
            translate([start,side>0?7.9:-9.1,21.2])
                cube([finish-start,1.2,3.6]);
        // Continuous metal rail seats, open at top for assembly.
        for(side=[-1,1]) {
            y=side>0?rail_inner:-rail_inner-rail_slot;
            translate([-0.2,y,rail_base]) cube([l+0.4,rail_slot,body_height]);
        }
        // L-shaped webbing eyes: top entry to side exit, clear of rails/sole.
        // Purchased 10 mm webbing, not a printed safety strap.
        if(is_end) for(side=[-1,1]) {
            y=side>0?27.2:-29.6;
            translate([l/2-6,y,28]) cube([12,2.4,9]);
            translate([l/2-6,side>0?27.2:-32.2,28]) cube([12,5,4]);
        }
        // Separate bolts per side: no fastener crosses the blade channel.
        for(x=is_end?end_bolts(l):[l/2]) for(side=[-1,1]) {
            // Limit the bore to one side of the blade well.
            intersection() {
                screw_y(x,20,2.75,side);
                translate([x-5,side>0?12:-34,14]) cube([10,22,12]);
            }
            // Top-loaded square M5 nut seat; check actual purchased nut.
            translate([x-4.3,side>0?12.8:-17.3,15.7]) cube([8.6,4.5,21]);
        }
        // Sole mounting screws and accessible hex nut pockets.
        for(x=sole_bolts(l,is_end)) {
            translate([x,0,-0.1]) cylinder(h=13,r=1.8);
            translate([x,0,7]) rotate([0,0,30]) cylinder(h=6,r=3.35,$fn=6);
        }
    }
}
module liner(l=140) {
    // Print base flat; slides into the upward-facing body well.
    groove=blade_thickness+2*blade_side_clearance;
    assert(groove>0 && groove<12.0,"Blade groove must be between 0 and 12 mm");
    difference() {
        union() {
            linear_extrude(14) rounded_rect(l,15.2,1.2);
            // Flexible triangular detents: their retention needs a fit trial.
            for(side=[-1,1]) scale([1,side,1])
                translate([0.8,0,0]) rotate([90,0,90])
                linear_extrude(l-1.6)
                    polygon([[7.4,9.5],[8.8,11],[7.4,12.5]]);
        }
        translate([-0.1,-groove/2,3]) cube([l+0.2,groove,14]);
        // Widen the top entry without changing the supporting floor.
        translate([-0.1,-(groove+2)/2,11]) cube([l+0.2,groove+2,5]);
        for(x=[10:20:l-5]) translate([x,0,-0.1]) cylinder(h=3.2,r=1.8);
    }
}
module sole(l=150,is_end=true) {
    // BODY contact face on bed, tread upward. Flip to fit beneath the body.
    difference() {
        union() {
            linear_extrude(3) rounded_rect(l,body_width,3);
            for(x=[2:10:l-4])
                translate([x,-30,3]) cube([min(6,l-x-1),60,1]);
        }
        for(x=sole_bolts(l,is_end)) {
            translate([x,0,-0.1]) cylinder(h=5,r=1.8);
            // Counterbore for button head: actual hardware must be checked.
            translate([x,0,1.4]) cylinder(h=4,r=3.1);
        }
    }
}
module logo_badge() {
    linear_extrude(2) rounded_rect(40,34,2);
    translate([20,3.5,1.98]) linear_extrude(0.82) siko_logo_2d(24);
    translate([20,-11.7,1.98]) linear_extrude(0.82) siko_wordmark_2d(7);
}
module number_badge() {
    linear_extrude(2) rounded_rect(32,24,2);
    translate([16,0,1.98]) linear_extrude(0.82) number_2d(player_number,16);
}
module fit_coupon() {
    // A 40 mm actual centre section: test rail, nut, screw and liner fit.
    body(40,"center");
}

if(part=="body_plate_380") {
    translate([0,32,0]) body(150,"toe");
    translate([0,100,0]) body(150,"heel");
    translate([0,168,0]) body(100,"center");
}
else if(part=="toe_long") body(150,"toe");
else if(part=="heel_long") body(150,"heel");
else if(part=="toe_short") body(90,"toe");
else if(part=="heel_short") body(90,"heel");
else if(part=="center20") body(20,"center");
else if(part=="center40") body(40,"center");
else if(part=="center60") body(60,"center");
else if(part=="center80") body(80,"center");
else if(part=="center100") body(100,"center");
else if(part=="liner_long") liner(139.6);
else if(part=="liner_short") liner(79.6);
else if(part=="liner20") liner(19.6);
else if(part=="liner40") liner(39.6);
else if(part=="liner60") liner(59.6);
else if(part=="liner80") liner(79.6);
else if(part=="liner100") liner(99.6);
else if(part=="sole_long") sole(150,true);
else if(part=="sole_short") sole(90,true);
else if(part=="sole20") sole(20,false);
else if(part=="sole40") sole(40,false);
else if(part=="sole60") sole(60,false);
else if(part=="sole80") sole(80,false);
else if(part=="sole100") sole(100,false);
else if(part=="logo_badge") logo_badge();
else if(part=="number_badge") number_badge();
else if(part=="fit_coupon") fit_coupon();
else assert(false,str("Unknown part: ",part));
