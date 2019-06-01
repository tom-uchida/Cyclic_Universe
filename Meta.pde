class Meta {
  float posX; //吸い込まれる方
  float posY;
  float mass;
  float radius;
  float radius_tmp;

  ArrayList<PVector> points = new ArrayList<PVector>();
  int resolution = 360; // 点の数
  float angleDisplace = TWO_PI/resolution;

  Meta (PVector _pos, float _mass) {
    posX = _pos.x;
    posY = _pos.y;
    mass = _mass;
    radius = mass*0.43;
  }

  void update(PVector _location, float _mass) {
    posX = _location.x;
    posY = _location.y;
    radius = _mass*0.43;
  }

  void display() {
    
    fill(0, 0, 100);
    // 中心の円周上に点を打つ
    for (int i = 0; i < resolution; i++) {
      PVector point = new PVector();
      float angle = i*angleDisplace;
      point.x = posX + cos(angle)*radius;
      point.y = posY + sin(angle)*radius;
      points.add(point);
    }
    


    for (int i = 0; i < resolution; i++) {
      PVector point = points.get(i); //点の更新
      float dist = dist(posX, posY, point.x, point.y);
      // 吸収
      if ( dist < radius_tmp ) {
        float ang = atan2(posY-point.y, posX-point.x);
        dist = radius_tmp - dist;
        point.x -= cos(ang)*dist;
        point.y -= sin(ang)*dist;
      }
      fill(0, 100, 0); //接触した場合の色
    }

    PVector point = points.get(0);
    beginShape();
    curveVertex(point.x, point.y);
    for (int i = 0; i <= resolution; i++) {
      point = points.get(i%resolution);
      vertex(point.x, point.y);
    }
    endShape(CLOSE);



    fill(0, 0, 0);
    for (int i = 0; i < resolution; i++) {
      point = points.get(i);
      ellipse(point.x, point.y, 4, 4);
    }
  }

  void collisionDetection (float _mass) {
    radius_tmp = _mass*0.43;
  }

}