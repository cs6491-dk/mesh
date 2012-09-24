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
	/* solve the following system:
	 * (A.x + s*(B.x - A.x), A.y + s*(B.y - A.y)) == (C.x + t*(D.x - C.x), C.y + t*(D.y - C.y))
	 * for 0<t<=1, 0<s<=1
	 */

	float denominator = (B.y - A.y)*(C.x - D.x) - (B.x - A.x)*(C.y - D.y);

	if (denominator == 0) {
		/* same slope, no intersection */
		return null;
	}
	else {
		float t = ((B.y - A.y)*(C.x - A.x) - (B.x - A.x)*(C.y - A.y))/denominator;
		float s;
		if (A.x != B.x) {
			s = (C.x - A.x + t*(D.x - C.x))/(B.x - A.x);
		}
		else if (A.y != B.y) {
			s = (C.y - A.y + t*(D.y - C.y))/(B.y - A.y);
		}
		else {
			/* A and B are the same point */
			return null;
		}

		if ((0 < t) && (t <= 1) && (0 < s) && (s <= 1)) {
			return new Point(A.x + s*(B.x - A.x), A.y + s*(B.y - A.y));
		}
		else {
			/* the lines intersect, but the segments do not */
			return null;
		}
	}
}
