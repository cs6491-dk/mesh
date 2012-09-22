class Cut {
	float node_radius = 2;

	ArrayList path_list;
	ArrayList isect_list;
	Mesh m;

	Cut(Mesh arg_m) {
		path_list = new ArrayList();
		isect_list = new ArrayList();
		m = arg_m;
	}

	void add_point(Point p) {
		path_list.add(p);

		if (path_list.size() > 1) {
			Point A = (Point) path_list.get(path_list.size()-2),
			      B = p, C, D;
			/* iterate over corners */
			/* TODO: this hits every interior edge twice */
			for (int i=0; i < m.V.length; i++) {
				C = m.G[m.v(i)];
				D = m.G[m.v(m.n(i))];
				Point isect = line_segment_intersection(A, B, C, D);
				if (isect != null) {
					isect_list.add(isect);
					break;
				}
			}
		}
	}

	void draw() {
		Point prev, cursor;

		strokeWeight(1);
		cursor = null;
		for (int i=0; i < path_list.size(); i++) {
			prev = cursor;
			cursor = (Point) path_list.get(i);

			if (prev != null) {
				line(prev.x, prev.y, cursor.x, cursor.y);
			}
		}

		strokeWeight(2);
		fill(0, 0, 255);
		cursor = null;
		for (int i=0; i < isect_list.size(); i++) {
			prev = cursor;
			cursor = (Point) isect_list.get(i);

			ellipse(cursor.x, cursor.y, 2*node_radius, 2*node_radius);
			if (prev != null) {
				line(prev.x, prev.y, cursor.x, cursor.y);
			}
		}
	}
}
