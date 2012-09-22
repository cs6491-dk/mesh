float dot_product(float[] a, float[] b) {
	return a[0]*b[0]+a[1]*b[1];
}
float magnitude(float ax, float ay) {
	return sqrt(ax*ax+ay*ay);
}
float angle(float[] a, float[] b) {
	// return angle between two vectors using dot product.  this may not work all of the time
	// and cross product may be required... 
	float dp = dot_product(a, b);
	return acos(dp/(magnitude(a[0], a[1])*magnitude(b[0], b[1])));
}

float[] center_for_two_points(float[] a, float[] b, float r) {
	// Inspired by approach given here
	//  http://www.mathworks.com/matlabcentral/newsreader/view_thread/255121

	float[] m = new float[2];
	float[] p = new float[2];
	float[] c = new float[2];
	float[] c2 = new float[2];
	float d, alp, gam, magp;


	// Compute the midpoint
	m[0] = (a[0]+b[0])/2.0;
	m[1] = (a[1]+b[1])/2.0;


	// Alpha is distance from the midpoint to either a or b
	// Gamma is the distance from the midpoint to the center of the circle
	alp = sqrt(sq(b[0]-m[0])+sq(b[1]-m[1]));
	gam = sqrt(r*r-alp*alp);
	println("Alp*2: " + alp*2);
	println("r: " + r);
	println("Gamma: " + gam);

	// Find a vector p orthonal to the line ab connecting the two points
	// This is given as [b(1)-a(1), a(0)-b(0)]; 

	p[0] = b[1] - a[1];
	p[1] = a[0] - b[0];
	magp = sqrt(p[0]*p[0]+p[1]*p[1]);

	d = r-gam;
	println("d: " + d);
	c[0] = m[0] + p[0]/magp * gam;
	c[1] = m[1] + p[1]/magp * gam; 
	//c2[0] = m[0] - p[0]/magp * d;
	//c2[1] = m[1] - p[1]/magp * d; 


	if (true) { // debug
		noFill();
		ellipse(m[0]-p[0]/magp*gam, m[1]-p[1]/magp*gam, r*2, r*2);
	}
	return m;
}

