boolean clockwise_triangle(float x1, float y1, float x2, float y2, float x3, float y3)
{
	float a0 = x2 - x1,
	      a1 = y2 - y1,
	      b0 = x3 - x1,
	      b1 = y3 - y1;

	/* This is just the third element of the cross product of
	 * V(1,2) and V(1,3).  The sense is inverted from usual
	 * because the flipped y axis gives us a left-handed system */
	return (a0 * b1 - a1 * b0) > 0;
}

/*float[] cross_product(float[] a, float[] b)
{
	float[] c = new float[3];
	c[0] = a[1]*b[2] - a[2]*b[1];
	c[1] = a[2]*b[0] - a[0]*b[2];
	c[2] = a[0]*b[1] - a[1]*b[0];

	return c;
}*/
