

include <Round-Anything/polyround.scad>

// My attempt at creating, a strength optimized, spinal module, with places to insert magnets.
// 3D printable, 6dof, strength bearing 

function rot_translate(rot = [0, 0, 0], pos = [0, 0, 0]) =
  mult_rotation(rot) * mult_translation(pos);

// Rotation matrix (XYZ order)
function mult_rotation(rot) =
  rot_x(rot[0]) * rot_y(rot[1]) * rot_z(rot[2]);

// Translation matrix
function mult_translation(v) =
  [
    [1, 0, 0, v[0]],
    [0, 1, 0, v[1]],
    [0, 0, 1, v[2]],
    [0, 0, 0, 1],
  ];

// Axis rotations
function rot_x(a) =
  [
    [1, 0, 0, 0],
    [0, cos(a), -sin(a), 0],
    [0, sin(a), cos(a), 0],
    [0, 0, 0, 1],
  ];
function rot_y(a) =
  [
    [cos(a), 0, sin(a), 0],
    [0, 1, 0, 0],
    [-sin(a), 0, cos(a), 0],
    [0, 0, 0, 1],
  ];
function rot_z(a) =
  [
    [cos(a), -sin(a), 0, 0],
    [sin(a), cos(a), 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1],
  ];

module fingers() {
  //structures that the top part must avoid that come up
  radiPoints2 = [
    [-body_d, body_d / 5, 1],
    [0, body_d, 5.5],
    [body_d * 3, -body_d / 5, 2],
    [body_d / 5, body_d / 2.5, 0],
    [0, body_d / 4, 1],
  ];
  n = len(radiPoints2);
  function sum_x(i = 0) =
    i == n ? 0 : radiPoints2[i][0] + sum_x(i + 1);
  function sum_y(i = 0) =
    i == n ? 0 : radiPoints2[i][1] + sum_y(i + 1);
  x_off = sum_x() / n;
  y_off = sum_y() / n;
  function center_points(i = 0) =
    i == n ? []
    : concat(
      [[radiPoints2[i][0], radiPoints2[i][1] + y_off, radiPoints2[i][2]]],
      center_points(i + 1)
    );

  radiPoints2_centered = center_points();
  scaleAmount = [0.1, 0.1, 0.1];
  //this is a hack job positioning  
  rotate([0, 90, 180])
    translate([1, 0, -0.5])
      scale(scaleAmount) {
        polyRoundExtrude(radiPoints2_centered, 5, 1, 1, 6);
      }

  rotate([0, 90, 55])
    translate([1, body_d / 5, -0.5])
      scale(scaleAmount) {
        polyRoundExtrude(radiPoints2_centered, 5, 1, 1, 6);
      }

  rotate([0, 90, -55])
    translate([1, body_d / 5, -0.5])
      scale(scaleAmount) {
        polyRoundExtrude(radiPoints2_centered, 5, 1, 1, 6);
      }
}

module teardrop() {
  //ball_d * ball_tolerance, 2.5, 4
  //base_diam, top_diam, height_offset
  // base_diam: The main ball diameter (for the socket)
  // top_diam: The diameter of the smaller ball at the tip
  // height_offset: How far up the smaller ball sits

  hull() {
    // The main socket ball
    sphere(d=ball_d * ball_tolerance, $fn=32);

    // The smaller blunted tip
    translate([0, 0, -4])
      sphere(d=3, $fn=24);
  }
}

module lr_cable_holes(h = ball_d + vertebra_thk + 10, tilt = 2) {
  // 1. Cable Holes (Side-by-Side)
  for (sx = [-1, 1]) {
    translate([cable_hole_d * 1.4 * sx, 2 * body_d / (3 * PI) - body_d / 4, 0])
      //rotate([0, tilt * -sx, 0]) // Tilt in place
        cylinder(h=h, d=cable_hole_d, $fn=16, center=true);
  }

  
// magnet_spacing: how far apart the two sets of holes are
magnet_spacing = 2.03; 

//for (mx = [-1, 1]) {
  // This translate moves the whole "set" of holes left and right
  //translate([mx * magnet_spacing, 0, 0]) {
    
    // Magnet hole 1 (Top)
    translate([0, cable_hole_d + body_d/7, -6.79])
     rotate([00, 0, 0]) // Tilt in place
      cylinder(3.1, 1.7, 1.7, $fn=10);
    
    // Magnet hole 2 (Bottom)
    translate([0, cable_hole_d + body_d/25, -6.7 - vertebra_thk + 2])
      rotate([tilt, 0, 0]) 
        cylinder(10, 1.7, 1.7, $fn=10);
  //}
//}

        radiPoints2 = [
          [-body_d / 2, 0, 3],
          [0, body_d, 11.5],
          [body_d / 2, 0, 3],
          [0, body_d/2,5],
        ];
translate([0, -body_d / 3.5, -vertebra_thk/1.74]) // real place for it to be
//translate([0, -body_d / 3.5, -vertebra_thk/2])
        polyRoundExtrude(radiPoints2, 3.1, 0.5, 0, fn=12, 6);


        
        
}

module startingHull(thk, dontGenTopBallToSaveTime = false) {
  translate([0, -body_d / 4, 0])
    difference() {
      union() {
        radiPoints = [
          [-body_d / 2, 0, 3],
          [0, body_d, 5.5],
          [body_d / 2, 0, 3],
        ];
        radiPoints2 = [
          [-body_d / 2, 0, 3],
          [0, body_d, 5.5],
          [body_d / 2, 0, 3],
        ];

        ballPosition = [0, 2 * body_d / (3 * PI), vertebra_thk + ball_d * ball_peek];
        polyRoundExtrude(radiPoints2, thk, 0.5, 4, fn=12, 6);
        translate([0, 2 * body_d / (3 * PI), vertebra_thk + ball_d * ball_peek]) if (!dontGenTopBallToSaveTime) {
          teardrop(ball_d * ball_tolerance, 6, 3);
        }
      }
      translate([0, 2 * body_d / (3 * PI), ball_d * (ball_peek) - ball_d * (ball_peek_tolerance)])
        teardrop(ball_d * ball_tolerance, 3, 3);
    }
}

module roundedCylinder(thk) {

  difference() {
    translate([0, 0, -thk])
      startingHull(thk);
    hullOnTopPosition =
    [0, -2 * body_d / (3 * PI), ball_peek_tolerance * ball_d] + [0, 2 * body_d / (3 * PI), 0];
    hull() {
      for (sx = [-12, 12]) {

        rot1 = [0, sx, 0]; // Pitch (Nodding Yes)
        rot2 = [sx, 0, 0]; // Roll (Ear to Shoulder)
        rot3 = [0, 0, sx]; // Yaw (Twisting/Shaking No)


        multmatrix(rot_translate(rot1, hullOnTopPosition))
          startingHull(vertebra_thk, true);


        multmatrix(rot_translate(rot2, hullOnTopPosition))
          startingHull(vertebra_thk, true);

        multmatrix(rot_translate(rot3, hullOnTopPosition))
          startingHull(vertebra_thk, true);
      }
    }

    hull() {
      for (sx = [-3, 3]) {

        if (doFingers) {
          rot1 = [0, sx, 0]; // Pitch
          rot2 = [sx, 0, 0]; // Roll
          rot3 = [0, 0, sx]; // Yaw

          // Pitch Fingers
          multmatrix(rot_translate(rot1, [0, 0, -vertebra_thk - ball_peek_tolerance * ball_d]))
            fingers();

          // Roll Fingers
          multmatrix(rot_translate(rot2, [0, 0, -vertebra_thk - ball_peek_tolerance * ball_d]))
            fingers();

          // Twist Fingers
          multmatrix(rot_translate(rot3, [0, 0, -vertebra_thk - ball_peek_tolerance * ball_d]))
            fingers();
        }
      }
    }

    hullOnBottomPosition =
    [
      0,
      -body_d / 4 + 2 * body_d / (3 * PI),
      -vertebra_thk + -(ball_d * ball_peek),
    ];
    hull() {
      for (sx = [-3, 3]) {
           
        rot1 = [0, sx, 0]; // Pitch (Nodding Yes)
        rot2 = [sx, 0, 0]; // Roll (Ear to Shoulder)
        rot3 = [0, 0, sx]; // Yaw 

        

        multmatrix(rot_translate(rot1, hullOnBottomPosition))
          translate([0, 0, ball_d * (ball_peek) - ball_d * (ball_peek_tolerance)])
            teardrop(ball_d * ball_tolerance, 3, 3);
            
        

        multmatrix(rot_translate(rot2, hullOnBottomPosition))
          translate([0, 0, ball_d * (ball_peek) - ball_d * (ball_peek_tolerance)])
            teardrop(ball_d * ball_tolerance, 3, 3);

        multmatrix(rot_translate(rot3, hullOnBottomPosition))
          translate([0, 0, ball_d * (ball_peek) - ball_d * (ball_peek_tolerance)])
            teardrop(ball_d * ball_tolerance, 3, 3);
      }
    }
  }

  if (doFingers) {
    fingers();
  }
}

module vertebra(shear_factor = 0) {

  difference() {
    union() {
    

      multmatrix(
        [
          [1, 0, 0, 0], // X stays same
          [0, 1, 0, 0],
          [0, shear_factor, 1, 0],
          [0, 0, 0, 1],
        ]
      )

        roundedCylinder(vertebra_thk);

      translate([0, 2 * body_d / (3 * PI) - body_d / 4, ball_d * ball_peek])
        teardrop();
        

    }


    lr_cable_holes();
    
  }
}

// ------------ Parameters
ball_d = 5.23; // ball diameter
vertebra_thk = 13; // thickness of central disc
cable_hole_d = 3.15; // diameter of cable tunnels
body_d = 17.5; // vertebra disc diameter
ball_peek = -0.1; // RATIO of the ball sticking out
ball_peek_tolerance = -0.8;
ball_tolerance = 1.00;
doFingers = false;

//------------ Driver
//roundedCylinder();
scale([1, 1, 1]) {
  vertebra();
  //fingers();
}

//startingHull(13, false);
