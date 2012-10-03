Mesh m;
Cut c;

boolean dragging;

void setup() {
	size(500, 500);
	//G = read_input("data/mesh.txt"); 
	randomSeed(0);
	G = rand_input(15, width, height);
	m = new Mesh(G, 1);
	c = null;
	dragging = false;
}

void draw() {
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
	dragging = true;
}

void mouseDragged() {
	c.add_point(new Point(mouseX, mouseY));
}

void mouseRelease() {
	dragging = false;
}
