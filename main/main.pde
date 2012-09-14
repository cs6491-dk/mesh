Mesh m;

void setup() {
	size(300, 300);
	G = read_input("data/mesh.txt"); 
	m = new Mesh(G);
}

void draw() {
	background(#FFFFFF);
	m.draw();
}

void keyPressed() {
	if (key == 'n') {
		m.set_cursor(m.n(m.cursor));
	}
	else if (key == 'p') {
		m.set_cursor(m.p(m.cursor));
	}
	else if (key == 's') {
		m.set_cursor(m.s(m.cursor));
	}
}
