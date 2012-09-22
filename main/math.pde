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
