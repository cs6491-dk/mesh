class Mesh {
	float node_radius = 1.0;
	float[][] G;

	/*Mesh(filename) { };*/

	Mesh(float[][] G_in) {
		G = G_in;
	}

	void draw() {
		strokeWeight(1);
		fill(0, 0, 0);
		for (int i=0; i < G.length; i++) {
			ellipse(G[i][0], G[i][1], 2*node_radius, 2*node_radius);
		}
		apollonius(G[0][0], G[0][1], G[1][0], G[1][1], G[2][0], G[2][1]).show_outline();
	}
}
