class Trajectory {
	PVector [] pos; 
	PVector [] vel;
	int num; // The number of elements
	float radius;
	int countItem; // Count the number of elements
	boolean isOccupied; // The contents of the array are occupied ?

	Trajectory (int _num, float _radius) {
		num = _num;
		radius = _radius;
		pos = new PVector[num];
		vel = new PVector[num];
		countItem = -1;
		isOccupied = false;
	}

	void update (PVector _pos, PVector _vel) {
		// Call of the function about trajectory
		setPosition(_pos);
		setVelocity(_vel);
		countItem ++;

		// If countItem matches the number of elements in the array
		if ( countItem == num-1 ) {
			isOccupied = true; // State elements of the array are all occupied
		}
	}

	// Operations related to the "pos vector array"
	// Syntax : splice(list, value, index)
	// Syntax : arrayCopy(source array, destination array, length)
	void setPosition ( PVector _pos ) {
		PVector[] tempPos = (PVector[])splice(pos, _pos.copy(), 0); // 配列pos[]の先頭(0番目の要素)に現在の位置ベクトルをコピーして挿入
		arrayCopy(tempPos, pos, num);
	}

	// Operations related to the "vel vector array"
	void setVelocity ( PVector _vel ) {
		PVector[] tempVel = (PVector[])splice(vel, _vel.copy(), 0);
		arrayCopy(tempVel, vel, num);
	}

	void display(color c) {
		int endId = 0;
		if (isOccupied) {
			endId = num;
		} else {
			endId = countItem;
		}
		
		beginShape(QUAD_STRIP);
		for ( int i = 1; i < endId; i+=1 ) {
			PVector velLeft = vel[i].copy();
			PVector velRight = vel[i].copy();
			velLeft.rotate(-HALF_PI);
			velRight.rotate(HALF_PI);
			velLeft.normalize();
			velRight.normalize();

			float thickness = calcThickness(i);

			PVector vertexLeft = PVector.add(pos[i], velLeft.mult(thickness)); //線をつなぐ点
			PVector vertexRight = PVector.add(pos[i], velRight.mult(thickness));

			fill(c, 3*(endId-i));
			noStroke();

			vertex(vertexLeft.x, vertexLeft.y);
			vertex(vertexRight.x, vertexRight.y);
		}
		endShape();
	}

	// A function that determines the thickness of the trajectory
	float calcThickness(int id) {
		float minRrate = 0.1;
		float magRate = 0.1;

		// Thickness
		if ( b_trajectory_Bold == true ) {
			magRate = map(trajectoryThickness, 0, 20, 0.12, 0.7);
			if(trajectoryThickness > 20) {
				b_trajectory_T = true; 
				b_trajectory_Bold = false;
			}
		}

		if ( b_trajectory_T == true ) {
			magRate = map(trajectoryThickness, 20, 0, 0.7, 0.12);
			if(trajectoryThickness < 0) b_trajectory_T = false; b_trajectory_Bold = false;
		} 

		if ( b_trajectory_Bold == false && b_trajectory_T == false ) {
			trajectoryThickness = 0;
		}

		float minR = minRrate * radius;
		float mag = magRate * radius;
		float phase = TWO_PI / (num-1) * id;

		return -cos(phase) * mag + 2.0*mag + minR;
	}
}