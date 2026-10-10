// Printable prototype branding for the user's crowned-wolf «Си Ко» mark.
// No original vector source was supplied: this is an illustrative, simplified
// reconstruction of the reference image, not the original brand artwork.
// Units: millimetres. All modules are 2D and centred at [0, 0].
// Extrude onto a backing plaque: the nose and the text need that backing.
// At size=24 the logo is 24 mm high and 20.64 mm wide; its principal strokes
// are approximately 1.0--1.2 mm wide. Do not scale below 24 mm for a 0.4 mm nozzle.

module siko_logo_2d(size=24) {
    scale([size/100, size/100])
    union() {
        // Open-top diamond surround, matching the framing in the reference.
        // Leaving its top open avoids tiny triangular cavities by the crown.
        polygon([
            [-36,22], [-43,0], [0,-50], [43,0], [36,22],
            [31,22], [37,0], [0,-43], [-37,0], [-31,22]
        ]);

        // Broad three-point crown; the lower band is continuous.
        polygon([
            [-22,47], [-17,31], [17,31], [22,47],
            [11,42], [8,36], [3,36], [3,44], [0,50],
            [-3,44], [-3,36], [-8,36], [-11,42]
        ]);

        // Symmetric ears, cheeks and muzzle outline; eye recesses are open.
        for (side=[-1,1])
            translate([0,3])
            scale([0.8*side,1])
            difference() {
                polygon([
                    [-30,33], [-28,15], [-18,0], [-13,-7],
                    [-21,-10], [-21,-18], [-15,-26], [-8,-29],
                    [-7,-35], [0,-41], [0,-36], [-3,-33],
                    [-4,-28], [-9,-23], [-12,-20], [-12,-18],
                    [-7,-14], [-7,-6], [-12,3], [-19,13],
                    [-23,20], [-25,33]
                ]);
                polygon([
                    [-16,-14], [-14,-15], [-11.5,-12],
                    [-14,-11], [-16,-11]
                ]);
            }

        // Broad nose; a plaque supports this separate raised feature.
        translate([0,3])
            polygon([[-4,-20], [4,-20], [2.5,-24], [-2.5,-24]]);
    }
}

// Optional wordmark, kept separate so the emblem can fit a small plaque.
// Minimum recommended letter size is 7 mm with a 0.4 mm nozzle.
module siko_wordmark_2d(size=7) {
    text("Си Ко", size=size, font="DejaVu Sans:style=Bold",
         halign="center", valign="center", spacing=1.0);
}

// Player-number artwork: replace value for personalised plaques.
// At size=16 the default "88" is about 24 mm wide and 12 mm high.
module number_2d(value="88", size=16) {
    text(str(value), size=size, font="DejaVu Sans:style=Bold",
         halign="center", valign="center", spacing=1.0);
}
