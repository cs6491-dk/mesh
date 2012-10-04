Mesh m;
Cut c;

int apollonius_counter = 0;
void setup() {
	size(500, 500);
	//G = read_input("data/mesh.txt"); 
	randomSeed(1);
	G = rand_input(15, width, height);
	m = new Mesh(G, 0); // bulge
	//m = new Mesh(G, 1); // naive
	c = null;
	println(apollonius_counter + " calls to apoll");
}

void draw() {
	m.update_physics();

	background(#FFFFFF);
	m.draw();
	if (c != null) {
		c.draw();
	}
}

void keyPressed() {
	if (key == 'n') {
		m.set_cursor(m.n(m.cursor));
	}
	else if (key == 'p') {
		m.set_cursor(m.p(m.cursor));
	}
	else if (key == 'r') {
		m.set_cursor(m.r(m.cursor));
	}
	else if (key == 's') {
		m.set_cursor(m.s(m.cursor));
	}
}

void mousePressed() {
	c = new Cut(m);
}

void mouseDragged() {
	c.add_point(new Point(mouseX, mouseY));
}

void mouseReleased() {
	c.terminate(new Point(mouseX, mouseY));
}
