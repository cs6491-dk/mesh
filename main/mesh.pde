class Mesh {
	/* Config Parameters */
	float node_radius = 5.0;

	/* Mesh Implementation Objects */
	ArrayList<Point> G;
	ArrayList<Integer> V;
	ArrayList<Integer> S;
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

	void do_bulge_triangulation() {
		int v1, v2, min_idx;
		float min_bulge;
		float gam_app, d_app;
		Point mp = new Point(0, 0);

		V = new ArrayList();

		// Get the first two vertices and add them to the list
		v1 = get_leftmost();
		v2 = min_angle_from_leftmost();

		for (int i=0; i < 10; i++)
		{
			V.add(v1);
			V.add(v2);
			// Compute the midpoint
			Point gv1 = g(v1), gv2 = g(v2);
			mp.set((gv1.x+gv2.x)/2.0, (gv1.y+gv2.y)/2.0);

			min_idx=-1;
			min_bulge = 1e10;
			for (int k=0; k < G.size(); k++)
			{
				if (!V.contains(k)) {
					Disk dsc= apollonius(gv1, gv2, g(k));
					gam_app = sqrt(sq(dsc.x-mp.x)+sq(dsc.y-mp.y));
					d_app = dsc.r-gam_app;
					//println("gam+r: " + (gam_app+dsc.r));
					if ((gam_app+dsc.r) < min_bulge) {
						//min_bulge = d_app;
						min_bulge = gam_app+dsc.r;
						min_idx = k;
						//println("k: " + k);
						//            println("Gam_app: " + gam_app);
						//            println("d_app: " + d_app);

						//last_bulge = dsc;
					}
				}
			}
			if (min_idx == -1) {
				break;
			}
			println("min_idx: " + min_idx);
			V.add(min_idx);
			v1 = v2;
			v2 = min_idx;
		}
		
	}

	void do_triangulation() {
		Disk d;
		V = new ArrayList();
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

		/* find all good (non-super) swings */
		int tri, iv, ipv;
		boolean success;
		/* iterate over corners */
		for (int i=0; i < V.size(); i++) {
			iv = v(i);
			ipv = v(p(i));
			success = false;
			/* iterate over corners to find a match */
			for (int j=0; j < V.size(); j++) {
				if ((i != j) && (iv == v(j)) && (ipv == v(n(j)))) {
					S.add(j);
					success = true;
					break;
				}
			}
			/* No non-super swing found */
			if (!success) {
				S.add(i);
			}
		}

		/* Inefficient.  Better idea:
		 * maintain a reverse swing table, due to 
		 * manifold mesh requirement, there will be a single beginning and end to the loop */
		/* superswing */
		/* iterate over corners, looking for superswingers */
		int jnv;
		float a, best_angle;
		for (int i=0; i < S.size(); i++) {
			if (S.get(i) == i) {
				best_angle = 2*PI;
				iv = v(i);
				ipv = v(p(i));
				for (int j=0; j < S.size(); j++) {
					if ((i != j) && (iv == v(j))) {
						jnv = v(n(j));
						a = angle(g(iv), g(ipv), g(jnv));
						if (a < best_angle) {
							best_angle = a;
							S.set(i, j);
						}
					}
				}
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
		V.add(a);
		V.add(b);
		V.add(c);
		int corner;
		for (int i=0; i < 3; i++) {
			corner = c(triangle_count, i);
			C.set(v(corner), corner);
			/* TODO: These are bogus swings */ 
			S.add(corner);
		} 
		T_center.add(calc_triangle_center(triangle_count));
		tri_enabled.add(true);
		triangle_count += 1;
		return triangle_count-1;
	}

	void disable_triangle(int t) {
		tri_enabled.set(t, false);
	}
}
