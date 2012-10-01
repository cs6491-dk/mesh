float signed_area(Point a, Point b, Point c)
{
	return b.minus(a).cross(c.minus(a));
}

boolean clockwise_triangle(Point a, Point b, Point c)
{
	return signed_area(a, b, c) > 0;
}

boolean triangle_contains(Point a, Point b, Point c, Point p)
{
	float c1 = signed_area(a, b, p),
	      c2 = signed_area(b, c, p),
	      c3 = signed_area(c, a, p);

	return ((c1>=0) && (c2>=0) && (c3>=0)) || ((c1<0) && (c2<0) && (c3<0));
}

float angle(Point p1, Point p2) {
	float theta = acos(p1.dot(p2)/sqrt(p1.mag2()*p2.mag2()));

	if (p1.cross(p2) < 0) {
		theta = 2*PI - theta;
	}

	return theta;
}

float angle(Point p1, Point p2, Point p3) {
	return angle(p2.minus(p1), p3.minus(p1));
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
