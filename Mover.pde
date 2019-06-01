class Mover {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float G;
  float mass;
  float mass_tmp;
  float hue;
  float sat_scene2;
  float val_scene2;
  float sat_scene34;
  float val_scene34;
  color c;
  Trajectory trajectory;

  Mover(float _mass, PVector _location) {
    mass = _mass;
    location = _location.copy();
    velocity = new PVector(random(-1,1), random(-1,1));
    acceleration = new PVector(0, 0);
    trajectory = new Trajectory((int)random(10, 30), random(5*mass, 10*mass));
  }

  void displayImg(PImage img) {
    blendMode(ADD);
    pushMatrix();
    //hue = map(second()%60, 0, 60, 0, 360);

    // Color variation
    if ( scene == 2 ) {
      c = color( random(290, 360), sat_scene2, val_scene2 );
      sat_scene2 = constrain(sat_scene2, 30, 100);
      val_scene2 = constrain(val_scene2, 30, 100);
      sat_scene2 += 0.25;
      val_scene2 += 0.25;

    } else if ( scene == 3 || scene == 4 ) {
      c = color( random(210, 260), sat_scene34, val_scene34 );
      sat_scene34 = constrain(sat_scene34, 20, 100);
      val_scene34 = constrain(val_scene34, 20, 100);
      sat_scene34 += 0.1;
      val_scene34 += 0.1;
    }
    
    tint(c);
    translate(location.x, location.y);
    image(img, 0, 0, 100*mass, 100*mass);

    tint(c);
    image(img, 0, 0, 30*mass, 30*mass);
    popMatrix();

    trajectory.display(c);
    blendMode(NORMAL);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  // A function to explode
  void explode(int num, float x, float y) {
    for (int i = 0; i < num; i++) {
      PVector m = PVector.random2D();
      m.mult(50); // Location to explode
      m.add(new PVector(x, y));

      movers = (Mover[]) append(movers, new Mover( random(0.1, 0.6), m ));
    }
  }

  // A function to change mass of Movers
  void expand_contract() {
    if ( !b_Mover_Expand && !b_Mover_Contract ) {
      mass_tmp = mass;
    }

    // Expand
    if ( b_Mover_Expand ) {
      mass += 0.2;
        if ( mass >= mass_tmp+3.0 ) {
          b_Mover_Expand = false;
          b_Mover_Contract = true;
        }
    }

    // Contract
    if ( b_Mover_Contract ) {
      mass -= 0.2;
        if ( mass <= mass_tmp+0.1 ) {
          b_Mover_Contract = false;
        }
    } 
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    
    trajectory.update(location, velocity);
  }

  // A function to check the edge
  void checkEdges() {
    if (location.x > width+300) {
      location.x = width-300;
      velocity.x *= -0.5;
    } 
    else if (location.x < -300) {
      location.x = -300;
      velocity.x *= -0.5;
    }

    if (location.y > height+300) {
      location.y = height-300;
      velocity.y *= -0.5;
    } 
    else if (location.y < -300) {
      location.y = -300;
      velocity.y *= -0.5;
    }
  }

}