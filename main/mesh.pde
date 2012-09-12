class Mesh {
	float node_radius = 1.0;
	float[][] G;
	int[] T;

	/*Mesh(filename) { };*/

	Mesh(float[][] G_in) {
		G = G_in;
		T = triangulation();
		println(T);
	}

	int[] triangulation() {
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
						if ( (m!=i) && (m!=j) && (m!=k) && (sq(d.x-G[m][0]) + sq(d.y-G[m][1]) < r2)) {
							success = false;
							continue;
						}
					}
					if (success) {
						t_list.add(i);
						t_list.add(j);
						t_list.add(k);
					}
				}
			}
		}

		int[] ret = new int[t_list.size()];
		for (int i=0; i < t_list.size(); i++) {
			ret[i] = (Integer)t_list.get(i);
		}

		return ret;
	}

	void draw() {
		strokeWeight(1);
		fill(0, 0, 0);
		for (int i=0; i < G.length; i++) {
			ellipse(G[i][0], G[i][1], 2*node_radius, 2*node_radius);
		}
		//apollonius(G[0][0], G[0][1], G[1][0], G[1][1], G[2][0], G[2][1]).show_outline();

		int a,b,c;
		for (int i=0; i < T.length/3; i++) {
			a = T[i*3  ];
			b = T[i*3+1];
			c = T[i*3+2];
			line(G[a][0], G[a][1], G[b][0], G[b][1]);
			line(G[b][0], G[b][1], G[c][0], G[c][1]);
			line(G[c][0], G[c][1], G[a][0], G[a][1]);
		}
	}
}
