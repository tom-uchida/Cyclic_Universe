class Attractor {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float G;
  float mass;
  float img_mass = 4.5;
  float angle = 0.0;
  float radius = mass*0.43;
  boolean b_display = true;

  Attractor(float _mass, float x, float y) {
    mass = _mass; // The radius of the attractor
    location = new PVector(x, y);
    velocity = new PVector(1.0, 0);
    acceleration = new PVector(0, 0);
  }

  void start(PImage img) {
    blendMode(ADD);
    pushMatrix();
    tint(280, 90, 100);
    translate(location.x, location.y);
    image(img, 0, 0, img_mass*mass, img_mass*mass);
    popMatrix();
    blendMode(NORMAL);

    noStroke();
    fill(0, 90, 0, 100);
    ellipse(location.x, location.y, mass*img_mass/5, mass*img_mass/5);

    //mass += random(0.45, 0.55);
    mass += 20;
      // scene1
      if ( mass >= 300 && scene == 1 ) {
        velocity.mult(0);
        for (int i = 0; i < movers.length; i++) {
          PVector m = PVector.random2D();
          m.mult(random(150, 200));
          m.add(new PVector(width/2, height/2));

          movers[i] = new Mover( random(0.5, 0.9), m );
        }
        scene = 2;
        b_background_Red = true;
        b_blackhole = false;
      }

      // scene7
      if ( mass >= 300 && scene == 7 ) {
        for (int i = 0; i < 30; i++) {
          PVector m = PVector.random2D();
          m.mult(random(150, 200));
          m.add(new PVector(width/2, height/2));

          movers = (Mover[]) append( movers, new Mover( random(0.5, 0.9), m ));
        }
        scene = 8;
        b_background_Red = true;
        b_blackhole = false;
      }
    }

  void end() {
    strokeWeight(random(5, mass*0.06));
    if ( scene == 6 ) {
      if ( mass >= displayWidth*0.58 ) {
        mass += 20;
      } else {
        mass += 5.0;
      }
    }
  }

  // An atrractor attracts a mover
  PVector attract_Mover(Mover m, float G) {
    PVector dir_force = PVector.sub(location, m.location);          // Calculate direction of force
    float distance = dir_force.mag();                               // Distance between objects
    distance = constrain(distance, 5, 25);                          // Keep distance within a reasonable range
    dir_force.normalize();                                          // Normalize vector (distance doesn't matter here, we just want this vector for direction)

    float strength = (G * mass * m.mass) / (distance * distance);   // Calculate strength of attraction
    dir_force.mult(strength);                                       // Get force vector --> magnitude * direction
    return dir_force;
  }

  // An atrractor repels a mover
  PVector repel_Mover(Mover m, float G) {
    PVector dir_force = PVector.sub(location, m.location);
    float distance = dir_force.mag();
    distance = constrain(distance, 10.0, 10000);
    dir_force.normalize();

    float strength = (G * mass * m.mass) / (distance * distance);
    dir_force.mult(-1.0*strength);
    return dir_force;
  }

  // An attractor attracts the other attractor
  PVector attract_Attractor(Attractor a, float G) {
    PVector dir_force = PVector.sub(location, a.location);
    float distance = dir_force.mag();
    distance = constrain(distance, 7.0, 25.0);
    dir_force.normalize();

    float strength = (G * mass * a.mass) / (distance * distance);
    dir_force.mult(strength);
    return dir_force;
  }

  // An attractor repels the other attractor
  PVector repel_Attractor(Attractor a, float G) {
    PVector dir_force = PVector.sub(location, a.location); 
    float distance = dir_force.mag();
    distance = constrain(distance, 1000.0, 10000.0);
    dir_force.normalize();             

    float strength = (G * mass * a.mass) / (distance * distance);
    dir_force.mult(-1.0*strength);
    return dir_force;
  }

  PVector attract_repel_Mover(Mover m, float minDistance, float maxDistance, float G, boolean b_magField) {
    PVector dir_force = PVector.sub(location, m.location);
    float distance = dir_force.mag();

    if ( distance >= maxDistance || distance <= minDistance ) {
      distance = constrain(distance, minDistance, maxDistance);
      dir_force.normalize();

      float sign = 1.0; //attract 
      if ( distance <= minDistance ) {
        sign = -1.0; //repel
      }

      float force = sign * (G * mass * m.mass) / (distance*distance);
      return dir_force.mult(force);

    } else {
      if ( b_magField ) {
        return new PVector(random(-2.0, 2.0), random(-2.0, 2.0));
      } else {
        return new PVector(0, 0);
      }
    }
  }

  // A function to that Black Holes absorb Movers
  void absorb_Mover(float _param) {
    if ( mass < 500 ) {
      ArrayList<Mover> li = new ArrayList<Mover>(Arrays.asList(movers));
      Iterator<Mover> it = li.iterator();
      while (it.hasNext()) {
        Mover m = (Mover) it.next();
        float distance = PVector.dist(location, m.location);
        if ( distance < mass * _param ) {
          b_Attractor_Expand = true;
          b_inflation = true;
          mass += m.mass*random(1, 5);
          it.remove();
        }
      }
      movers = li.toArray(new Mover[li.size()]);
    }
  }

  // A function to search max mass Black Hole
  void checkMaxMass(int _index) {
    if ( _index == 0 ) {
      maxMass = new int[attractors.length];
      index = new int[attractors.length];
    }

    maxMass[_index] = (int)mass; 
    int[] temp_maxMass = sort(maxMass);
    int[] temp_maxMass_reverse = reverse(temp_maxMass);

    // finish searching
    if ( _index+1 == attractors.length ) {
      // sort index
      for (int i = 0; i < attractors.length; i++) {
        for (int j = 0; j < attractors.length; j++) {
          if ( temp_maxMass_reverse[i] == maxMass[j] ) {
            index[i] = j; 
          }
        }
      }

      last_attractors = new Attractor[attractors.length];
      arrayCopy(attractors, last_attractors, attractors.length);
      for (int i = 0; i < attractors.length; i++) {
        // Syntax : arrayCopy(src, srcPosition, dst, dstPosition, length)
        arrayCopy( attractors, index[i], last_attractors, i, 1 );
      }
      scene = 4;
      b_absorb_Attractor = true;
      b_background_White = true;
      attract_A = true;
    }
  }  

  // A function to that Black Holes absorb each other
  void absorb_Attractor() {
    ArrayList<Attractor> li = new ArrayList<Attractor>(Arrays.asList(last_attractors));
    Iterator<Attractor> it = li.iterator();
    while (it.hasNext()) {
      Attractor a = (Attractor) it.next();
      float distance = PVector.dist(location, a.location);
      if ( distance < (mass*0.5 + a.mass*0.5)*0.8 && distance != 0.0 ) {
        b_Attractor_Expand = true;
        b_inflation = true;
        mass += a.mass*0.1;
        it.remove();
      }
    }
    last_attractors = li.toArray(new Attractor[li.size()]);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  // A function to change mass of Atttractors
  void glow() {
    // Expand
    if ( b_Attractor_Expand ) {
      img_mass += 0.08;
      if ( img_mass >= 6.8 ) {
        b_Attractor_Expand = false;
        b_Attractor_Contract = true;
      }
    }

    // Contract
    if ( b_Attractor_Contract ) {
      img_mass -= 0.08;
      if ( img_mass <= 4.5 ) {
        b_Attractor_Contract = false;
      }
    } 
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);

    // Change size of mass
    if ( !b_inflation && !b_increase) {
      if ( scene == 2 || scene == 7 ) {
        mass = constrain(mass, 300, 350);
      } else {
        mass = constrain(mass, 100.0, 400);
      } 

      float phase = TWO_PI / random(180);
      mass += random(1, 3) * sin(angle);
      angle = angle + phase;
    }

    if ( b_inflation ) {
      mass = constrain(mass, 100.0, 1200);
    }
  }

  void massIncrease() {
    // mass increase gradually when new one birth
    if ( b_massIncrease || b_increase ) {
      mass += 15;
      if ( mass > 250 ) {
        b_massIncrease = false; 
        b_increase = false;
        if ( b_AEAB ) b_AEAB = false;
        if ( b_ABME ) b_ABME = false;
      }
    }
  }

  void displayImg(PImage img, boolean b_glow) {
    blendMode(ADD);
    pushMatrix();
    //tint(156, 50, 255, 200);
    tint(280, 90, 100);
    translate(location.x, location.y);
    image(img, 0, 0, img_mass*mass, img_mass*mass);
    if ( b_Attractor_Expand && b_glow ) {
      tint(280, 90, 100);
      image(img, 0, 0, 1.75*img_mass*mass, 1.75*img_mass*mass);
    }
    popMatrix();
    blendMode(NORMAL);

    if ( b_display ) {
      noStroke();
      fill(0, 90, 0, 100);
      ellipse(location.x, location.y, mass*0.85, mass*0.85);
    }
  }

  // A function to check the edge
  void checkEdges() {
    if (location.x > width-mass*0.5) {
      location.x = width-mass*0.5;
      velocity.x *= -0.9;
    } 
    else if (location.x < mass*0.5) {
      location.x = mass*0.5;
      velocity.x *= -0.8;
    }

    if (location.y > height-mass*0.5) {
      location.y = height-mass*0.5;
      velocity.y *= -0.8;
    } 
    else if (location.y < mass*0.5) {
      location.y = mass*0.5;
      velocity.y *= -0.8;
    }
  }
}

/*
  // A function to calculate distance
  void calcDistance (float _locationX, float _locationY, float _mass) {
    float distance = dist(location.x, location.y, _locationX, _locationY);
    // 接触した場合
    if ( distance < (mass*0.86+_mass*0.86)*0.43 ) {
      b_display = false;
      meta.collisionDetection(_mass);
    } else {
      b_display = true;
    }
  }
*/