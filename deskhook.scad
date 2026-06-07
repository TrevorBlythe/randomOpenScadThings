include <Round-Anything/polyround.scad>

// A strength optimized desk hook that can have custom text
module gridpattern(memberW = 4, sqW = 12, iter = 5, r = 3){
	round2d(0, r)rotate([0, 0, 45])translate([-(iter * (sqW + memberW) + memberW) / 2, -(iter * (sqW + memberW) + memberW) / 2])difference(){
		square([(iter) * (sqW + memberW) + memberW, (iter) * (sqW + memberW) + memberW]);
		for (i = [0:iter - 1], j = [0:iter - 1]){
			translate([i * (sqW + memberW) + memberW, j * (sqW + memberW) + memberW])square([sqW, sqW]);
		}
	}
}

deskEdgeWidth = 25.5;
clearance = 0.18;
oic = deskEdgeWidth + deskEdgeWidth*clearance;
hookDrop = oic*2;
clearThk = deskEdgeWidth*clearance;
scale([1,1,1]){
   //vertebra();
   //fingers();
radiPoints2 = [
      //[-oic/1.5 - clearThk, 0.0, 0.0],
      [-oic/1.5 - clearThk, oic, 0.0],
      [oic/6, oic, 3.0],
      [oic/6, oic- hookDrop , 3.0],
      [oic/3, oic/1.5- hookDrop ,2.0], 
      [deskEdgeWidth*0.7, oic/2- hookDrop ,2.0],
      [deskEdgeWidth * 1.6, oic*1.5 - hookDrop ,2.0],
      [deskEdgeWidth * 1.2, oic/4- hookDrop ,0.0],
      [0,0- hookDrop , 1],
       [0,0 , 1],
       [-oic/1.5 - clearThk, 0, 0.0],
    [-oic/1.5 - clearThk, clearThk, 0.0],
     [0,clearThk , 1],
      [0, oic- clearThk, 0.0],
      [-oic/1.5, oic-clearThk, 0.0],
      //[-oic/1.5, 0, 0.0],
    
    ];
difference(){
    //polyRoundExtrude(radiPoints2,oneInch,0.5,0.5,fn=3,6);
        
        
linear_extrude(oic/2.0){
  //shell2d(-3.5)polygon(polyRound(radiPoints2,10));
    shell2d(-2.8){
    polygon(polyRound(radiPoints2,30));
    translate([8,8])gridpattern(memberW = 1.5, sqW = 10, iter = 30, r = 0.5);
  }
}


    translate([-oneInch,0,-oneInch/2])
    cube([oneInch*1.0,oneInch*1.0,oneInch*5.0]);
   }

}

    translate([clearThk/2,-1.5,oic/2 - 4])
    rotate([0,0,90])
    linear_extrude(height = 5) {
    text(
        "Buy Scary Descent VR NOW",
        3,
        font = "DejaVu Sans:style=Bold",
        halign = "center",
        valign = "center"
    );
    }
    
















