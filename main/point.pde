class Point {
	float x;
	float y;

	Point(float arg_x, float arg_y) {
		set(arg_x, arg_y);
	}

	void set(float arg_x, float arg_y) {
		x = arg_x;
		y = arg_y;
	}

	float mag2() {
		return sq(x) + sq(y);
	}

	float mag() {
		return sqrt(mag2());
	}

	Point minus(Point p2) {
		return new Point(x-p2.x, y-p2.y);
	}

	float cross(Point v2) {
		/* This is just the third element of the cross product of
		 * this and v2.  The sense is inverted from usual because
		 * the flipped y axis gives us a left-handed system */
		return x*v2.y - y*v2.x;
	}

	float dot(Point v2) {
		return x*v2.x + y*v2.y;
	}
}
