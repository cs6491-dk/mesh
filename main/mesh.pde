class Mesh {
	/* Config Parameters */
	float node_radius = 5.0;

	/* Mesh Implementation Objects */
	Point[] G;
	int[] V;
	int[] S;
	int[] C;

	/* Visualization */
	Point[] T_center;
	int cursor; /* (current corner) */
	Disk last_bulge = null;

	/*Mesh(filename) { };*/

	Mesh(Point[] G_in, int mode) {
		G = G_in;
		if (mode == 0) {
			do_bulge_triangulation();
		}
		else if (mode == 1) {      
			do_triangulation();
		}
		calc_swing();
		cursor = 0;
	}

	void do_bulge_triangulation() {
		ArrayList v_list = new ArrayList();
		int v1, v2, min_idx;
		float min_bulge;
		float gam_app, d_app;
		Point mp = new Point(0, 0);

		// Get the first two vertices and add them to the list
		v1 = get_leftmost();
		v2 = min_angle_from_leftmost();


		for (int i=0; i < 10; i++)
		{
			v_list.add(v1);
			v_list.add(v2);
			// Compute the midpoint
			mp.set((G[v1].x+G[v2].x)/2.0, (G[v1].y+G[v1].y)/2.0);

			min_idx=-1;
			min_bulge = 1e10;
			for (int k=0; k < G.length; k++)
			{
				if (!v_list.contains(k)) {
					Disk dsc= apollonius(G[v1], G[v2], G[k]);
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
			v_list.add(min_idx);
			v1 = v2;
			v2 = min_idx;
		}
		
		//println("v_list: " + v_list);
		C = new int[G.length];
		/* Turn ArrayList into array V */
		V = new int[v_list.size()];
		for (int i=0; i < v_list.size(); i++) {
			V[i] = (Integer)v_list.get(i);
			C[V[i]] = i;
		}

		/* Compute triangle centers */
		T_center = new Point[V.length/3];
		float x_sum, y_sum;
		/* iterate over Triangles */
		for (int i=0; i < T_center.length; i++) {
			x_sum = 0;
			y_sum = 0;
			/* iterate over the three corners of Triangle */
			for (int k=0; k < 3; k++) {
				x_sum += G[v(i*3+k)].x;
				y_sum += G[v(i*3+k)].y;
			}
			T_center[i] = new Point(x_sum/3, y_sum/3);
		}
	}

	void do_triangulation() {
		Disk d;
		ArrayList v_list = new ArrayList();
		float r2;
		boolean success;

		/* Do triangulation with ArrayList */
		for (int i = 0; i < G.length; i++) {
			for (int j = i+1; j < G.length; j++) {
				for (int k = j+1; k < G.length; k++) {
					d = apollonius(G[i], G[j], G[k]);
					r2 = sq(d.r);
					success = true;
					for (int m = 0; m < G.length; m++) {
						if ((m!=i) && (m!=j) && (m!=k) && (sq(d.x-G[m].x) + sq(d.y-G[m].y) <= r2)) {
							success = false;
							break;
						}
					}
					if (success) {
						v_list.add(i);
						int c = v_list.size()-1;
						if (clockwise_triangle(G[i], G[j], G[k])) {
							/* println("CW:" + c + ", " + (c+1) + ", " + (c+2)); */
							v_list.add(j);
							v_list.add(k);
						}
						else {
							/* println("CCW:" + c + ", " + (c+1) + ", " + (c+2)); */
							v_list.add(k);
							v_list.add(j);
						}
					}
				}
			}
		}

		C = new int[G.length];

		/* Turn ArrayList into array V */
		V = new int[v_list.size()];
		for (int i=0; i < v_list.size(); i++) {
			V[i] = (Integer)v_list.get(i);
			C[V[i]] = i;
		}

		/* Compute triangle centers */
		T_center = new Point[V.length/3];
		float x_sum, y_sum;
		/* iterate over Triangles */
		for (int i=0; i < T_center.length; i++) {
			x_sum = 0;
			y_sum = 0;
			/* iterate over the three corners of Triangle */
			for (int k=0; k < 3; k++) {
				x_sum += G[v(i*3+k)].x;
				y_sum += G[v(i*3+k)].y;
			}
			T_center[i] = new Point(x_sum/3, y_sum/3);
		}
	}

	void calc_swing() {
		S = new int[V.length];

		/* find all good (non-super) swings */
		int tri, iv, ipv;
		boolean success;
		/* iterate over corners */
		for (int i=0; i < S.length; i++) {
			iv = v(i);
			ipv = v(p(i));
			success = false;
			/* iterate over corners to find a match */
			for (int j=0; j < S.length; j++) {
				if ((i != j) && (iv == v(j)) && (ipv == v(n(j)))) {
					S[i] = j;
					success = true;
					break;
				}
			}
			/* No non-super swing found */
			if (!success) {
				S[i] = i;
			}
		}

		/* Inefficient - maintain a reverse swing table, due to 
		 * manifold mesh requirement, there will be a single beginning and end to the loop */
		/* superswing */
		/* iterate over corners, looking for superswingers */
		int jnv;
		float a, best_angle;
		for (int i=0; i < S.length; i++) {
			if (S[i] == i) {
				best_angle = 2*PI;
				iv = v(i);
				ipv = v(p(i));
				for (int j=0; j < S.length; j++) {
					if ((i != j) && (iv == v(j))) {
						jnv = v(n(j));
						a = angle(G[iv], G[ipv], G[jnv]);
						if (a < best_angle) {
							best_angle = a;
							S[i] = j;
						}
					}
				}
			}
		}
	}

	void draw() {
		strokeWeight(1);
		fill(0, 0, 0);
		for (int i=0; i < G.length; i++) {
			ellipse(G[i].x, G[i].y, 2*node_radius, 2*node_radius);
		}

		int a, b, c;
		for (int i=0; i < V.length/3; i++) {
			a = v(i*3  );
			b = v(i*3+1);
			c = v(i*3+2);
			/* Draw bounding disks */
			/*apollonius(G[a], G[b], G[c]).show_outline();*/
			/* Draw triangulation */
			line(G[a].x, G[a].y, G[b].x, G[b].y);
			line(G[b].x, G[b].y, G[c].x, G[c].y);
			line(G[c].x, G[c].y, G[a].x, G[a].y);
		}

		/* Draw triangulation centers */
		/*for (int i=0; i < T_center.length; i++) {
			ellipse(T_center[i].x, T_center[i].y, 2*node_radius, 2*node_radius);
		}*/

		/* Draw corner labels */
		int tri;
		String s;
		int iv;
		for (int i=0; i < V.length; i++) {
			tri = t(i);
			s = ((Integer)i).toString();
			if (i==cursor) {
				if (bs(i)) {
					fill(255, 0, 0);
				}
				else {
					fill(0, 255, 0);
				}
			}
			else {
				fill(0, 0, 0);
			}
			iv = v(i);
			text(s, 0.7*G[iv].x+0.3*T_center[tri].x-0.5*textWidth(s),
			        0.7*G[iv].y+0.3*T_center[tri].y+5);
		}
		fill(0, 0, 0);
		if (last_bulge != null) {
			last_bulge.show_outline();
		}
	}

	int c(int v) {
		return C[v];
	}

	int n(int c) {
		return (c+1)%3 + 3*t(c);
	}

	int p(int c) {
		return (c+2)%3 + 3*t(c);
	}

	int s(int c) {
		return S[c];
	}

	int t(int c) {
		/* integer division rounds down */
		return c/3;
	}

	int v(int c) {
		return V[c];
	}

	boolean bs(int c) {
		return v(p(c)) != v(n(s(c)));
	}

	void set_cursor(int new_cursor) {
		cursor = new_cursor;
	}

	int get_leftmost()
		// Return leftmost point
	{
		float min_val = 1e10;
		int min_idx = -1;
		for (int i=0; i < G.length; i++) {
			if (G[i].x < min_val)
			{
				min_idx = i;
				min_val = G[i].x;
			}
		}	
		return min_idx;
	}

	float angle_from_leftmost(int input)
	{
		int leftmost = this.get_leftmost();
		Point lv = new Point(0.0, 0.0-G[leftmost].y);
		Point tv = new Point(G[input].x-G[leftmost].x, G[input].y-G[leftmost].y);
		return angle(lv, tv);
	}

	int min_angle_from_leftmost()
	{
		float min_val = PI;
		int min_idx = -1;
		float current;
		int leftmost = this.get_leftmost();
		for (int i=0; i < G.length; i++) {
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
}

