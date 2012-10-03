class Mesh {
	/* Config Parameters */
	float node_radius = 5.0;

	/* Mesh Implementation Objects */
	ArrayList<Point> G;
	ArrayList<Integer> V;
	ArrayList<Integer> S;
	ArrayList<Integer> R;
	ArrayList<Integer> C;
	ArrayList<Boolean> tri_enabled;
	int triangle_count;

	/* Visualization */
	ArrayList<Point> T_center;
	int cursor; /* (current corner) */
	Disk last_bulge = null;

	/*Mesh(filename) { };*/

	Mesh(Point[] G_in, int mode) {
		G = new ArrayList();
		V = new ArrayList();
		for (int i=0; i < G_in.length; i++) {
			G.add(G_in[i]);
		}
		if (mode == 0) {
			do_bulge_triangulation();
		}
		else if (mode == 1) {      
			do_triangulation();
		}
		post_triangulate();
		calc_c();
		calc_swing();
		cursor = 0;
	}

	boolean in_front(int a, int b, int c) {
		// given two points a and b which constitute a line, determine if c is ahead or behind
		// return true if in front, false if behind   

		// For a given line ab, this is the dot product between a vector perpendicular to ab
		// and the vector ac.  If it is positive, then c is in front.  If it is negative, 
		// then c is behind.  Note many formulations use the clockwise 90 degree rotation
		// and so the equations and sign conditions are slightly different.  
		// (Cx-Ax)*(By-Ay) + (Cy-Ax)*(Ax-Bx)

		float val = (g(c).x-g(a).x)*(g(b).y-g(a).y)+(g(c).y-g(a).y)*(g(a).x-g(b).x);
		//println("Is " + c + " in front of " + a + "," + b + "?"); 
		if (val >= 0) {
			return false;
		} 
		else {
			return true;
		}
	}
	boolean in_front_point(int a, int b, float x, float y) {
		// given two points a and b which constitute a line, determine if c is ahead or behind
		// return true if in front, false if behind   

		// For a given line ab, this is the dot product between a vector perpendicular to ab
		// and the vector ac.  If it is positive, then c is in front.  If it is negative, 
		// then c is behind.  Note many formulations use the clockwise 90 degree rotation
		// and so the equations and sign conditions are slightly different.  
		// (Cx-Ax)*(By-Ay) + (Cy-Ax)*(Ax-Bx)

		float val = (x-g(a).x)*(g(b).y-g(a).y)+(y-g(a).y)*(g(a).x-g(b).x);
		if (val >= 0) {
			return false;
		} 
		else {
			return true;
		}
	}
	void recursive_bulge(int v1, int v2) {
		int v3;
		//println("Bulging from: " + v1 + "," + v2);
		ArrayList<Integer> old_vlist = new ArrayList(V);
		v3 = bulge(v1, v2);
		//if (v3 == 12) {v3 = -1;}
		if (v3 == -1) {
			//println("No node found on bulge from " +v1 +"," +v2 +" , not recursing");
		}
		else if (old_vlist.contains(v3)){
			//println("Not recursing.. we already had this one");       
		}
		else // bulge left and right
		{
			//println("Recursing to left");
			recursive_bulge(v3, v2);    // v1 = v3; // this "goes left"
			//println("Recursing to right");
			recursive_bulge(v1, v3);    // v2 = v3; // this "goes right"
		}
	}

	int bulge(int v1, int v2) {
		// bulge from v1,v2 and try to grab a vertex
		// return it if you find it, -1 if you don't find anything

		int min_idx=-1;
		float min_bulge = 1e10;
		float gam_app, d_app;
		float[] mp = new float[2];

		// Compute the midpoint
		mp[0] = (g(v1).x+g(v1).x)/2.0;
		mp[1] = (g(v1).y+g(v2).y)/2.0;    

		// Loop over unseen vertices.  if it is "in front", then do apollonius
		// otherwise, skip it

		for (int k=0; k < G.size(); k++)
		{ 
			//boolean test = is_triangle(v1, v2, k);

			if (!in_front(v1, v2, k)) {
				continue;
			}  
			/*if (v_list.contains(k)) { // change this to search for existing triangle
			//if (is_triangle(v1, v2, k)) {
				println(k + " already in vertex list...");
				continue;
			}*/

			Disk dsc= apollonius(g(v1), g(v2), g(k));
			// map need to choose between "alpha" and "gamma" here.. see whiteboard notes
			boolean center_location = in_front_point(v1, v2, dsc.x, dsc.y);
			//if (center_location) {println("front");} else {println("back");}
			gam_app = sqrt(sq(dsc.x-mp[0])+sq(dsc.y-mp[1]));
			float bulge_val;
			if (center_location){
				// front
				bulge_val = max(dsc.r+gam_app, dsc.r-gam_app);
			}
			else {
				// back
				bulge_val = min(dsc.r-gam_app, dsc.r+gam_app);        
			}                    
			//d_app = dsc.r-gam_app;
			if (bulge_val < min_bulge){
				min_bulge = bulge_val;
				min_idx = k;
			}
		}

		if (min_idx > -1 ) {
			V.add(v1);
			V.add(v2);       
			V.add(min_idx);
		} 
		return min_idx;
	}
	void do_bulge_triangulation() {
		int v1, v2, v3;

		// Get the first two vertices 
		v1 = get_leftmost();
		v2 = min_angle_from_leftmost();

		//println("Doing bulge triangulation, " + v1 + "," +  v2);
		recursive_bulge(v1, v2);
	}

	void do_triangulation() {
		Disk d;
		float r2;
		boolean success;

		/* Do triangulation with ArrayList */
		for (int i = 0; i < G.size(); i++) {
			for (int j = i+1; j < G.size(); j++) {
				for (int k = j+1; k < G.size(); k++) {
					Point gi = g(i), gj = g(j), gk = g(k);
					d = apollonius(gi, gj, gk);
					r2 = sq(d.r);
					success = true;
					for (int m = 0; m < G.size(); m++) {
						Point gm = g(m);
						if ((m!=i) && (m!=j) && (m!=k) && (sq(d.x-gm.x) + sq(d.y-gm.y) <= r2)) {
							success = false;
							break;
						}
					}
					if (success) {
						V.add(i);
						int c = V.size()-1;
						if (clockwise_triangle(gi, gj, gk)) {
							/* println("CW:" + c + ", " + (c+1) + ", " + (c+2)); */
							V.add(j);
							V.add(k);
						}
						else {
							/* println("CCW:" + c + ", " + (c+1) + ", " + (c+2)); */
							V.add(k);
							V.add(j);
						}
					}
				}
			}
		}
	}

	void post_triangulate() {
		/* Compute triangle centers */
		triangle_count = V.size()/3;
		T_center = new ArrayList();
		/* iterate over Triangles */
		for (int i=0; i < triangle_count; i++) {
			T_center.add(calc_triangle_center(i));
		}

		tri_enabled = new ArrayList();
		for (int i=0; i < triangle_count; i++) {
			tri_enabled.add(true);
		}
	}

	Point calc_triangle_center(int t) {
		float x_sum, y_sum;

		x_sum = 0;
		y_sum = 0;
		/* iterate over the three corners of Triangle */
		for (int k=0; k < 3; k++) {
			x_sum += g(v(c(t,k))).x;
			y_sum += g(v(c(t,k))).y;
		}
		return new Point(x_sum/3, y_sum/3);
	}

	void calc_c() {
		C = new ArrayList();
		for (int i=0; i < G.size(); i++) {
			C.add(null);
		}
		for (int i=0; i < V.size(); i++) {
			C.set(v(i), i);
		}
	}

	void calc_swing() {
		S = new ArrayList();
		R = new ArrayList();

		/* find all good (non-super) swings */
		int tri, iv, ipv, inv;
		boolean swing_found, rswing_found;
		/* iterate over corners */
		for (int i=0; i < V.size(); i++) {
			iv = v(i);
			ipv = v(p(i));
			inv = v(n(i));
			swing_found = false;
			rswing_found = false;
			/* iterate over corners to find a match */
			for (int j=0; j < V.size(); j++) {
				if (!swing_found && (i != j) && (iv == v(j)) && (ipv == v(n(j)))) {
					S.add(j);
					swing_found = true;
				}
				else if (!rswing_found && (i != j) && (iv == v(j)) && (inv == v(p(j)))) {
					R.add(j);
					rswing_found = true;
				}
				if (swing_found && rswing_found) {
					break;
				}
			}
			/* No non-super swing found */
			if (!swing_found) {
				S.add(i);
			}
			/* No non-super rswing found */
			if (!rswing_found) {
				R.add(i);
			}
		}

		for (int i=0; i < S.size(); i++) {
			if (S.get(i) == i) {
				int j = -1, next_j = i;
				while (j != next_j) {
					j = next_j;
					next_j = R.get(j);
				}
				S.set(i, j);
				R.set(j, i);
			}
		}
	}

	void draw() {
		strokeWeight(1);
		fill(0, 0, 0);
		Point gi;
		for (int i=0; i < G.size(); i++) {
			gi = g(i);
			ellipse(gi.x, gi.y, 2*node_radius, 2*node_radius);
		}

		int a, b, c;
		Point ga, gb, gc;
		for (int i=0; i < triangle_count; i++) {
			if (enabled_triangle(i)) {
				a = v(c(i,0));
				b = v(c(i,1));
				c = v(c(i,2));
				ga = g(a);
				gb = g(b);
				gc = g(c);
				/* Draw bounding disks */
				/*apollonius(ga, gb, gc).show_outline();*/
				/* Draw triangulation */
				line(ga.x, ga.y, gb.x, gb.y);
				line(gb.x, gb.y, gc.x, gc.y);
				line(gc.x, gc.y, ga.x, ga.y);
			}
		}

		/* Draw triangulation centers */
		/*Point ti;
		for (int i=0; i < triangle_count; i++) {
			if (enabled_triangle(i)) {
				ti = T_center.get(i);
				ellipse(ti.x, ti.y, 2*node_radius, 2*node_radius);
			}
		}*/

		/* Draw corner labels */
		int corner;
		String s;
		Point gcorner, ti;
		for (int i=0; i < triangle_count; i++) {
			if (enabled_triangle(i)) {
				for (int j=0; j < 3; j++) {
					corner = c(i,j);
					s = ((Integer)corner).toString();
					if (cursor==corner) {
						if (bs(corner)) {
							fill(255, 0, 0);
						}
						else {
							fill(0, 255, 0);
						}
					}
					else {
						fill(0, 0, 0);
					}
					gcorner = g(v(corner));
					ti = T_center.get(i);
					text(s, 0.7*gcorner.x+0.3*ti.x-0.5*textWidth(s),
					        0.7*gcorner.y+0.3*ti.y+5);
				}
			}
		}
		fill(0, 0, 0);
		if (last_bulge != null) {
			last_bulge.show_outline();
		}
	}

	int c(int v) {
		return C.get(v);
	}

	int c(int t, int i) {
		return 3*t + i%3;
	}

	Point g(int v) {
		return G.get(v);
	}

	int n(int c) {
		return (c+1)%3 + 3*t(c);
	}

	int p(int c) {
		return (c+2)%3 + 3*t(c);
	}

	int r(int c) {
		return R.get(c);
	}

	int s(int c) {
		return S.get(c);
	}

	int t(int c) {
		/* integer division rounds down */
		return c/3;
	}

	int v(int c) {
		return V.get(c);
	}

	boolean bs(int c) {
		return v(p(c)) != v(n(s(c)));
	}

	void set_cursor(int new_cursor) {
		cursor = new_cursor;
	}

	boolean enabled_triangle(int t) {
		return tri_enabled.get(t);
	}

	int get_leftmost()
		// Return leftmost point
	{
		float min_val = 1e10;
		int min_idx = -1;
		Point gi;
		for (int i=0; i < G.size(); i++) {
			gi = g(i);
			if (gi.x < min_val)
			{
				min_idx = i;
				min_val = gi.x;
			}
		}	
		return min_idx;
	}

	float angle_from_leftmost(int input)
	{
		int leftmost = this.get_leftmost();
		Point g_leftmost = g(leftmost),
		      g_input = g(input);
		Point lv = new Point(0.0, 0.0-g_leftmost.y);
		Point tv = new Point(g_input.x-g_leftmost.x, g_input.y-g_leftmost.y);
		return angle(lv, tv);
	}

	int min_angle_from_leftmost()
	{
		float min_val = PI;
		int min_idx = -1;
		float current;
		int leftmost = this.get_leftmost();
		for (int i=0; i < G.size(); i++) {
			if (i != leftmost)
			{
				current = angle_from_leftmost(i);
				if (current < min_val ) {
					min_idx = i;
					min_val = current;
				}
			}
		}
		return min_idx;
	}

	int add_vertex(Point p) {
		G.add(p);
		C.add(-1);
		return G.size()-1;
	}

	int add_triangle(int a, int b, int c) {
		/* Assumption: CW triangle */
		/* int s = V.size();
		println("add_triangle: " + s + "(" + a + "), " + (s+1) + "(" + b + "), " + (s+2) + "(" + c + ")"); */
		V.add(a);
		V.add(b);
		V.add(c);

		int corner, corner_v, corner_pv, corner_nv, cmp,
			/* compiler complains if we don't initialize */
		    swing = -1, rswing = -1;
		Boolean success;
		for (int i=0; i < 3; i++) {
			corner = c(triangle_count, i);

			corner_v = v(corner);
			corner_pv = v(p(corner));
			corner_nv = v(n(corner));
			success = false;
			for (int j=0; j < triangle_count; j++) {
				if (enabled_triangle(j)) {
					for (int k=0; k < 3; k++) {
						cmp = c(j,k);
						if ((corner != cmp) && (corner_v == v(cmp))) {
							if (corner_pv == v(n(cmp))) {
								success = true;
								swing = cmp;
								rswing = r(swing);
							}
							else if (corner_nv == v(p(cmp))) {
								success = true;
								rswing = cmp;
								swing = s(rswing);
							}
						}
						if (success) {
							S.add(swing);
							R.set(swing, corner);
							R.add(rswing);
							S.set(rswing, corner);
							break;
						}
					}
				}
				if (success) {
					break;
				}
			}
			if (!success) {
				rswing = c(v(corner));
				if (rswing >= 0) {
					while (!bs(rswing)) {
						rswing = s(rswing);
					}
					swing = s(rswing);
					S.add(swing);
					R.add(rswing);
					S.set(rswing, corner);
					R.set(swing, corner);
				}
				else {
					S.add(corner);
					R.add(corner);
				}
			}

			C.set(v(corner), corner);
		}

		T_center.add(calc_triangle_center(triangle_count));
		tri_enabled.add(true);

		triangle_count += 1;
		return triangle_count-1;
	}

	void disable_triangle(int t) {
		tri_enabled.set(t, false);

		/* remove corners from swing lists */
		int corner, swing, rswing;
		for (int i=0; i < 3; i++) {
			corner = c(t, i);
			swing = s(corner);
			rswing = r(corner);
			S.set(rswing, swing);
			R.set(swing, rswing);
		}
	}
}
