boolean clockwise_triangle(Point p1, Point p2, Point p3)
{
	float a0 = p2.x - p1.x,
	      a1 = p2.y - p1.y,
	      b0 = p3.x - p1.x,
	      b1 = p3.y - p1.y;

	/* This is just the third element of the cross product of
	 * V(1,2) and V(1,3).  The sense is inverted from usual
	 * because the flipped y axis gives us a left-handed system */
	return (a0*b1 - a1*b0) > 0;
}

/*float[] cross_product(float[] a, float[] b)
{
	float[] c = new float[3];
	c[0] = a[1]*b[2] - a[2]*b[1];
	c[1] = a[2]*b[0] - a[0]*b[2];
	c[2] = a[0]*b[1] - a[1]*b[0];

	return c;
}*/

float angle(Point p1, Point p2, Point p3) {
	float a0 = p2.x - p1.x,
	      a1 = p2.y - p1.y,
	      b0 = p3.x - p1.x,
	      b1 = p3.y - p1.y;

	float a = acos((a0*b0 + a1*b1)/sqrt((sq(a0)+sq(a1))*(sq(b0)+sq(b1))));

	if ((a0*b1 - a1*b0) < 0) {
		a = 2*PI - a;
	}

	return a;
}

Point line_segment_intersection(Point A, Point B, Point C, Point D) {
	/*println("A=(" + A.x + "," + A.y + ")");
	println("B=(" + B.x + "," + B.y + ")");
	println("C=(" + C.x + "," + C.y + ")");
	println("D=(" + D.x + "," + D.y + ")");*/

	if (A.x == B.x) {
		if (C.x == D.x) {
			return null;
		}
		/* todo: write this */
		return null;
	}
	else if (C.x == D.x) {
		/* todo: write this */
		return null;
	}
	else {
		float m1 = (B.y - A.y)/(B.x - A.x),
		      m2 = (D.y - C.y)/(D.x - C.x);

		if (m1 == m2) {
			/* Parallel segments */
			return null;
		}

		/* solve the system: (A.x + s, A.y + s*m1) = (C.x + t, C.y + t*m2) */
		float t = ((C.x - A.x)*m1 - (C.y - A.y))/(m2-m1);
		float s = C.x - A.x + t;

		float dxt = D.x - C.x,
		      dxs = B.x - A.x;
		if ((((dxt > 0) && (0 <= t) && (t <= dxt)) || ((0 >= t) && (t >= dxt))) && (((dxs > 0) && (0 <= s) && (s <= dxs)) || ((0 >= s) && (s >= dxs)))) {
			return new Point(C.x + t, C.y + t*m2);
		}
		else {
			/* lines intersect, but segments do not */
			return null;
		}
	}
}
