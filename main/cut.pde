class Cut {
	float node_radius = 0.5;

	ArrayList path_list;
	ArrayList isect_list;
	Mesh m;

	Cut(Mesh arg_m) {
		path_list = new ArrayList();
	}

	void add_point(Point p) {
		path_list.add(p);
	}

	void draw() {
		Point prev, cursor = null;
		for (int i=0; i<path_list.size(); i++) {
			prev = cursor;
			cursor = (Point) path_list.get(i);

			strokeWeight(1);
			fill(0, 0, 255);
			ellipse(cursor.x, cursor.y, 2*node_radius, 2*node_radius);
			if (prev != null) {
				line(prev.x, prev.y, cursor.x, cursor.y);
			}
		}
	}
}
