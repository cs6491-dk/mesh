class Mesh {
	/* Config Parameters */
	float node_radius = 1.0;

	/* Mesh Implementation Objects */
	float[][] G;
	int[] T;
	int[] S;

	/* Visualization */
	float[][] T_center;
	int cursor; /* (current corner) */

	/*Mesh(filename) { };*/

	Mesh(float[][] G_in) {
		G = G_in;
		do_triangulation();
		calc_swing();
		cursor = 0;
	}

	void do_triangulation() {
		Disk d;
		ArrayList t_list = new ArrayList();
		float r2;
		boolean success;

		for (int i = 0; i < G.length; i++) {
			for (int j = i+1; j < G.length; j++) {
				for (int k = j+1; k < G.length; k++) {
					d = apollonius(G[i][0], G[i][1], G[j][0], G[j][1], G[k][0], G[k][1]);
					r2 = sq(d.r);
					success = true;
					for (int m = 0; m < G.length; m++) {
						if ((m!=i) && (m!=j) && (m!=k) && (sq(d.x-G[m][0]) + sq(d.y-G[m][1]) <= r2)) {
							success = false;
							break;
						}
					}
					if (success) {
						t_list.add(i);
						int c = t_list.size()-1;
						if (clockwise_triangle(G[i][0], G[i][1], G[j][0], G[j][1], G[k][0], G[k][1])) {
							/* println("CW:" + c + ", " + (c+1) + ", " + (c+2)); */
							t_list.add(j);
							t_list.add(k);
						}
						else {
							/* println("CCW:" + c + ", " + (c+1) + ", " + (c+2)); */
							t_list.add(k);
							t_list.add(j);
						}
					}
				}
			}
		}

		T = new int[t_list.size()];
		for (int i=0; i < t_list.size(); i++) {
			T[i] = (Integer)t_list.get(i);
		}

		T_center = new float[T.length/3][2];
		float sum;
		/* iterate over Triangles */
		for (int i=0; i < T_center.length; i++) {
			/* iterate over spatial dimensions (2) */
			for (int j=0; j < 2; j++) {
				sum = 0;
				/* iterate over the three corners of Triangle */
				for (int k=0; k < 3; k++) {
					sum += G[T[i*3+k]][j];
				}
				T_center[i][j] = sum/3;
			}
		}
	}

	void calc_swing() {
		S = new int[T.length];

		int tri, v, pv;
		boolean success;
		/* iterate over corners */
		for (int i=0; i < S.length; i++) {
			v = T[i];
			pv = T[p(i)];
			success = false;
			/* iterate over corners to find a match */
			for (int j=0; j < S.length; j++) {
				if ((i != j) && (T[i] == T[j]) && (T[n(j)] == pv)) {
					S[i] = j;
					success = true;
					break;
				}
			}
			if (!success) {
				S[i] = i;
			}
		}

		/* supwerswing */
		/* iterate over corners, looking for superswingers */
		int nsv;
		float a, best_angle;
		for (int i=0; i < S.length; i++) {
			if (S[i] == i) {
				best_angle = 2*PI;
				v = T[i];
				pv = T[p(i)];
				for (int j=0; j < S.length; j++) {
					if ((i != j) && (T[i] == T[j])) {
						nsv = T[n(j)];
						a = angle(G[v][0], G[v][1], G[pv][0], G[pv][1], G[nsv][0], G[nsv][1]);
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
			ellipse(G[i][0], G[i][1], 2*node_radius, 2*node_radius);
		}

		int a,b,c;
		for (int i=0; i < T.length/3; i++) {
			a = T[i*3  ];
			b = T[i*3+1];
			c = T[i*3+2];
			/* Draw bounding disks */
			/*apollonius(G[a][0], G[a][1], G[b][0], G[b][1], G[c][0], G[c][1]).show_outline();*/
			/* Draw triangulation */
			line(G[a][0], G[a][1], G[b][0], G[b][1]);
			line(G[b][0], G[b][1], G[c][0], G[c][1]);
			line(G[c][0], G[c][1], G[a][0], G[a][1]);
		}

		/* Draw triangulation centers */
		/*for (int i=0; i < T_center.length; i++) {
			ellipse(T_center[i][0], T_center[i][1], 2*node_radius, 2*node_radius);
		}*/

		/* Draw corner labels */
		int tri;
		String s;
		for (int i=0; i < T.length; i++) {
			tri = t(i);
			s = ((Integer)i).toString();
			if (i==cursor) {
				fill(255, 0, 0);
			}
			else {
				fill(0, 0, 0);
			}
			text(s, 0.7*G[T[i]][0]+0.3*T_center[tri][0]-0.5*textWidth(s),
			        0.7*G[T[i]][1]+0.3*T_center[tri][1]+5);
		}
		fill(0, 0, 0);
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

	int t(int corner) {
		/* integer division rounds down */
		return corner/3;
	}

	void set_cursor(int new_cursor) {
		cursor = new_cursor;
	}
}
