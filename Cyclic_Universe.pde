// 2016/9
// Tomomasa Uchida
import java.util.Arrays;
import java.util.Iterator;

Mover[] movers = new Mover[27];
Attractor[] attractors = new Attractor[1];
Attractor[] last_attractors = new Attractor[0];
PImage moverImg;
PImage attractorImg;
boolean b_saveframe = false;
boolean attract_A = false;
boolean repel_A = true;
boolean attract_repel_M = false;
boolean repel_M = false;
boolean b_blackhole = true;
boolean b_background_Red = false;
boolean b_background_White = false;
boolean b_inflation = false;
boolean b_trajectory_Bold = false;
boolean b_trajectory_T = false;
boolean b_Mover_Expand = false;
boolean b_Mover_Contract = false;
boolean b_Attractor_Expand = false;
boolean b_Attractor_Contract = false;
boolean b_absorb_Mover = false;
boolean b_absorb_Attractor = false;
boolean b_massIncrease = false;
boolean b_increase = false;
boolean b_ABME = false;
boolean b_AEAB = false;
int scene = 1;
int pattern = 1;
int trajectoryThickness = 0;
int[] maxMass = new int[0];
int[] index = new int[0];
float distance = 0;
float slow = 0;
int absorbCount = 0;
int r = 0;
int backgroundCount = 0;
int exchange = 0;

void setup() {
  fullScreen();
  colorMode(HSB, 360, 100, 100, 100);
  background(215, 85, 10, 100);
  smooth();
  noCursor();
  frameRate(30);
  imageMode(CENTER);
  moverImg = loadImage("particle.png");
  attractorImg = loadImage("particle.png");

  attractors[0] = new Attractor( 0, width*0.5, height*0.5 );
}

void draw() {
  if ( b_saveframe ) {
    saveFrame("frame/####.tif");
  }
  
  //saveFrame("frame/####.tif");
  println("frameCount: "+frameCount);

  // About background
    // Black Hole ver.
    if ( b_blackhole ) {
      background(215, 85, 10, 100);
    }

    // Red ver.
    if ( b_background_Red ) {
      if ( 215+r < 360 && backgroundCount < 12) {
        r += 14;
        backgroundCount++;
        background(215+r, 85+r*0.6, 10+r*0.6, 100);
      } else {
        r -= 14;
        if ( r < 0 ) {
          b_background_Red = false;
          b_blackhole = true;
          r = 0;
          backgroundCount = 0;
        }
        background(215+r, 85+r*0.6, 10+r*0.6, 100);
      }
    }

    // White ver.
    if ( b_background_White ) {
      if ( 10+r < 100 && backgroundCount < 12) {
        r += 8.8;
        backgroundCount++;
        background(215, 85-r, 10+r, 100);
      } else {
        r -= 8.8;
        if ( r < 0 ) {
          b_background_White = false;
          b_blackhole = true;
          r = 0;
          backgroundCount = 0;
        }
        background(215, 85-r, 10+r, 100);
      }
    }



  // scene1
  if ( scene == 1 ) {
    attractors[0].start(attractorImg);
  }



  // scene2
  if ( scene == 2 ) {
    // About Attractor
    for (int i = 0; i < attractors.length; i++) {
      attractors[0].update();
      attractors[0].displayImg(attractorImg, false);
    }

    // About Mover
    for (int i = 0; i < movers.length; i++) {
      PVector force = attractors[0].attract_repel_Mover(movers[i], 300, 305, 600, true);
      movers[i].applyForce(force);

      movers[i].update();
      movers[i].displayImg(moverImg);
    }
  }

  if ( frameCount == 39 ) b_trajectory_Bold = true;

  // Divide Black Hole into two parts
  if ( frameCount == 40 ) {
    if ( b_trajectory_Bold ) {
      trajectoryThickness++; 
    } else if ( b_trajectory_T ) {
      trajectoryThickness--;
    }

    if (scene == 2) {
      attractors = (Attractor[]) append(attractors, new Attractor( attractors[0].mass, width/2, height/2 ));
      scene = 3;

      b_background_Red = true;
      b_blackhole = false;
      b_Attractor_Expand = true;
      b_Mover_Expand = true;
    }
  }



  // scene3
  if ( scene == 3 ) {

    // About trajectory thickness 
    if ( b_trajectory_Bold ) {
      trajectoryThickness++; 
    } else if ( b_trajectory_T ) {
      trajectoryThickness--;
    }

    // About Attractor
    for (int i = 0; i < attractors.length; i++) {
        for (int j = 0; j < attractors.length; j++) {
          if ( i != j ) {
            if ( repel_A ) {
              PVector force;
              // Repel each other
              if ( b_Attractor_Expand ) {
                force = attractors[j].repel_Attractor(attractors[i], random(10.0, 20.0));
              } else {
                force = attractors[j].repel_Attractor(attractors[i], random(4.0, 8.0));
              }
              attractors[i].applyForce(force);
            }

            if ( attract_A ) {
              PVector force;
              // Attract each other
              if ( b_Attractor_Expand ) {
                force = attractors[j].attract_Attractor(attractors[i], random(0.1, 0.7/attractors.length));
              } else {
                force = attractors[j].attract_Attractor(attractors[i], random(0.05, 0.2/attractors.length));
              }
              attractors[i].applyForce(force);
            }
          }
        }

        // update
        if ( b_AEAB ) {
          if ( i+3 == attractors.length || i+2 == attractors.length || i+1 == attractors.length ) {
            attractors[i].update(); 
            attractors[i].massIncrease();
          } else {
            attractors[i].update();
          }
        } else if ( b_ABME ) {
          if ( i+1 == attractors.length ) {
            attractors[i].update();
            attractors[i].massIncrease();
          } else {
            attractors[i].update();
          }
        } else {
          attractors[i].update();
        }

        // displayImg and glow
        if ( b_AEAB ) {
          if ( i+3 == attractors.length || i+2 == attractors.length || i+1 == attractors.length ) {
            attractors[i].displayImg(attractorImg, true);
            attractors[i].glow();
          } else {
            attractors[i].displayImg(attractorImg, false);
          }
        } else if ( b_ABME ) {
          if ( i+1 == attractors.length ) {
            attractors[i].displayImg(attractorImg, true);
            attractors[i].glow();
          } else {
            attractors[i].displayImg(attractorImg, false);
          }
        } else {
          attractors[i].displayImg(attractorImg, false);
        }

        attractors[i].checkEdges();
    }

    // About Mover
    for (int i = 0; i < movers.length; i++ ) {
      for (int j = 0; j < attractors.length; j++) {
        PVector force = new PVector();
          if ( attract_repel_M ) {
            force = attractors[j].attract_repel_Mover(movers[i], 300, 310, 300, false);
          } else if ( repel_M ) {
            force = attractors[j].repel_Mover(movers[i], random(5.0, 10.0));
          }
          movers[i].applyForce(force);
      }
        
      movers[i].update();
      movers[i].displayImg(moverImg);
      movers[i].expand_contract();
      movers[i].checkEdges();
    }

  }

  // Absorb mode
  if ( b_absorb_Mover ) {
    for (int i = 0; i < attractors.length; i++) {
      attractors[i].absorb_Mover(0.5);
    }
  }

  // Check max mass
  if ( movers.length == 0 && b_absorb_Attractor == false ) {
    for (int i = 0; i < attractors.length; i++) {
      attractors[i].checkMaxMass(i); // To scene4
    }
  }



  // scene4
  if ( b_absorb_Attractor && scene == 4 ) {
    // About Attractor
    for (int i = 0; i < last_attractors.length; i++) {
      for (int j = 0; j < last_attractors.length; j++) {
        if ( i != j ) {
          PVector force = last_attractors[j].attract_Attractor(last_attractors[i], 0.1/last_attractors.length);
          last_attractors[i].applyForce(force);
        }
      }

      if ( b_massIncrease && i+1 == last_attractors.length ) {
        b_increase = true; last_attractors[i].update();
      } else {
        last_attractors[i].update();
      }
      last_attractors[i].update();
      last_attractors[i].displayImg(attractorImg, false);
      last_attractors[i].glow();
      last_attractors[i].checkEdges();
    }

    // Only Max Mass Black hole absorb the other black holes
    for (int i = 1; i < last_attractors.length; i++) {
      last_attractors[0].absorb_Attractor();
      if ( last_attractors.length == 1 ) {
        scene = 5;
        last_attractors = (Attractor[]) append( last_attractors, new Attractor( last_attractors[0].mass, width*0.5, height*0.5 ));
      }
    }
  }



  // scene5
  if ( scene == 5 ) {
    last_attractors[1].velocity.mult(0);
    PVector force = last_attractors[1].attract_Attractor( last_attractors[0], 2.0 );
    last_attractors[0].applyForce(force);

    last_attractors[0].update();
    last_attractors[0].displayImg(attractorImg, false);
    last_attractors[0].glow();
    last_attractors[0].checkEdges();
    if ( last_attractors[0].location.x > width*0.3 && last_attractors[0].location.x < width*0.7 && last_attractors[0].location.y > height*0.3 && last_attractors[0].location.y < height*0.7 ) {
      distance = PVector.dist(last_attractors[0].location, last_attractors[1].location);
      slow = map(distance, 0, distance, 5.0, 0.0);
      last_attractors[0].velocity.mult(slow);
      if ( last_attractors[0].location.x > width*0.495 && last_attractors[0].location.x < width*0.505 && last_attractors[0].location.y > height*0.495 && last_attractors[0].location.y < height*0.505 ) {
        attractors = (Attractor[]) shorten(attractors);
        last_attractors[0].velocity.mult(0);
        scene = 6;
      }       
    }
  }



  // scene6
  if ( scene == 6 ) {
    last_attractors[0].end();
    last_attractors[0].displayImg(attractorImg, false);
    if ( last_attractors[0].mass >= displayWidth*2.5 ) {
      scene = 7;
      last_attractors[0].mass = 0;
    }
  }



  // scene7
  if ( scene == 7 ) {
    last_attractors[0].start(attractorImg);
  }



  // scene8
  if ( scene == 8 ) {
    last_attractors[0].update();
    last_attractors[0].displayImg(attractorImg, false);
    exit();
  }

  //println("attractors.length: "+last_attractors.length);
  //println("last_attractors.length: "+last_attractors.length);
  //println("movers.length: "+movers.length);
}

void AttractorBirth_MoverExplode() {
  b_massIncrease = true;
  int index = movers.length;

  // Mover explodes and diffuses
  movers[0].explode( 30, movers[0].location.x, movers[0].location.y );
  for (int i = index; i < movers.length; i++) {
    movers[i].applyForce(new PVector(random(-15, 15), random(-15, 15)));
  }

  // Black Hole birth in the place where Mover has been exploded
  attractors = (Attractor[]) append( attractors, new Attractor( 1, movers[0].location.x, movers[0].location.y ));
  // Syntax : subset(list, start, count)
  // Delete the Mover that exploded
  movers = (Mover[])subset( movers, 1 );

  // Switch repel(attract) to attract(repel)
  if ( attract_A ) {
    repel_A = true;
    attract_A = false;
  } else if ( repel_A ) {
    attract_A = true;
    repel_A = false;
  }

  b_trajectory_Bold = true;
  b_Attractor_Expand = true;
  b_Mover_Expand = true;
  b_ABME = true;
}

void AttractorExplode_MoverBirth() {
  int index = movers.length;
  // Increase the number of Mover
  for (int i = 0; i < attractors[0].mass*0.2; i++) {
    PVector m = PVector.random2D();
    m.mult(random(20)); // Location to explode
    m.add(new PVector(attractors[0].location.x, attractors[0].location.y));
    movers = (Mover[]) append(movers, new Mover( random(0.1, 0.6), m ));
  }

  // Explosion
  for (int i = index; i < movers.length; i++) {
    movers[i].applyForce(new PVector(random(-12, 12), random(-12, 12)));
  }

  // Delete the Attractor that exploded
  attractors = (Attractor[]) subset(attractors, 1);

  // Switch repel(attract) to attract(repel)
  if ( attract_A ) {
    repel_A = true;
    attract_A = false;
  } else if ( repel_A ) {
    attract_A = true;
    repel_A = false;
  }

  b_trajectory_Bold = true;
  b_Attractor_Expand = true;
  b_Mover_Expand = true;
}

void AttractorExplode_AttractorBirth() {
  b_massIncrease = true;
  int index = attractors.length;

  // Increase the number of Mover
  for (int i = 0; i < 3; i++) {
    PVector a = PVector.random2D();
    a.mult(random(30, 50));
    a.add(new PVector(attractors[0].location.x, attractors[0].location.y));
    attractors = (Attractor[]) append(attractors, new Attractor( 1, attractors[0].location.x, attractors[0].location.y ));
  }

  // Explosion
  for (int i = index; i < attractors.length; i++) {
    attractors[i].applyForce(new PVector(random(-7.5, 7.5), random(-7.5, 7.5)));
  }

  // Delete the Attractor that exploded
  attractors = (Attractor[]) subset(attractors, 1);

  // Switch repel(attract) to attract(repel)
  if ( attract_A ) {
    repel_A = true;
    attract_A = false;
  } else if ( repel_A ) {
    attract_A = true;
    repel_A = false;
  }

  b_trajectory_Bold = true;
  b_Attractor_Expand = true;
  b_AEAB = true;
}

void keyPressed() {
  // Stop the motion of Black Hole
  if (key == 's') {
    attract_A = false;
    repel_A = false;
    for (int i = 0; i < attractors.length; i++) {
      attractors[i].velocity.mult(0);
    }
  }

  // Mover explode
  if (key == 'm') {
    AttractorBirth_MoverExplode();
  }

  // Black Hole explode
  if (key == 'q') {
    AttractorExplode_MoverBirth();
  }

  if (key == 'b') {
    AttractorExplode_AttractorBirth();
    b_background_Red = true;
    b_blackhole = false;
  }

  // Switch repel to attract
  if (key == 'a') {
    attract_A = true;
    repel_A = false;
  }

  // Switch attract to repel
  if (key == 'r') {
    repel_A = true;
    attract_A = false;
  }

  if (key == 't') {
    if ( attract_repel_M ) {
      attract_repel_M = false;
      repel_M = false;
    } else if ( !attract_repel_M ) {
      attract_repel_M = true;
      repel_M = false;
    }
  }

  if (key == 'p') {
    if ( repel_M ) {
      repel_M = false;
      attract_repel_M = false;
    } else if ( !repel_M ) {
      repel_M = true; 
      attract_repel_M = false;
    }
  }

  if (key == 'c') {
    b_background_Red = true;
    b_blackhole = false;
  }

  if (key == 'd') {
    b_background_White = true;
    b_blackhole = false;
  }

  if (key == 'f') {
    b_absorb_Mover = true;
    b_background_White = true;
    b_blackhole = false;
  }

  if (key == 'g') {
    b_absorb_Mover = false;
  }

  if (key == 'e') {
    b_saveframe = true;
  }

  if (key == 'w') {
    b_saveframe = false;
  }

  if (key == 'x') {
    if ( exchange == 0 ) exchange = 1;
    else if ( exchange == 1 ) exchange = 2;
  }
}