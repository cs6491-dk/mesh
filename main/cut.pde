class Cut {
	float node_radius = 2;
	int current_triangle;

	ArrayList path_list;
	ArrayList isect_list;
	Mesh m;

	int entry_edge;
	Point entry_point;
	int entry_v1, entry_v2;

	Cut(Mesh arg_m) {
		path_list = new ArrayList();
		isect_list = new ArrayList();
		m = arg_m;
		current_triangle = -1;
		entry_edge = -1;
		entry_point = null;
		entry_v1 = -1;
		entry_v2 = -1;
	}

	void add_point(Point p) {
		path_list.add(p);

		if (path_list.size() == 1) {
			for (int i=0; i < m.triangle_count; i++) {
				if (triangle_contains(m.G[m.v(m.c(i,0))],
				                      m.G[m.v(m.c(i,1))],
				                      m.G[m.v(m.c(i,2))],
				                      p)) {
					current_triangle = i;
					break;
				}
			}
			println("Triangle " + current_triangle);
		}
		else {
			Point A = (Point) path_list.get(path_list.size()-2),
			      B = p,
			      C, D;
			if (current_triangle < 0) {
				/* iterate over all corners */
				/* TODO: this hits every interior edge twice */
				for (int i=0; i < m.V.length; i++) {
					C = m.G[m.v(i)];
					D = m.G[m.v(m.n(i))];
					Point isect = line_segment_intersection(A, B, C, D);
					if (isect != null) {
						isect_list.add(isect);
						current_triangle = m.t(i);
						entry_edge = i % 3;
						entry_point = isect;
						println("Triangle " + current_triangle + "(" + entry_edge + ")");
						break;
					}
				}
			}
			else {
				/* iterate over edges of current_triangle */
				for (int exit_edge=0; exit_edge < 3; exit_edge++) {
					int exit_corner = m.c(current_triangle, exit_edge);
					C = m.G[m.v(exit_corner)];
					D = m.G[m.v(m.n(exit_corner))];
					Point exit_point = line_segment_intersection(A, B, C, D);
					if (exit_point != null) {
						isect_list.add(exit_point);

						if (entry_v1 >= 0) {
							/* enable entry vertices */
						}
						m.disable_triangle(current_triangle);
						/* split current triangle */
						if (entry_edge == -1) {
							entry_v1 = m.add_vertex(exit_point);
							entry_v2 = m.add_vertex(exit_point);
							/* disable entry vertices */
							m.add_triangle(entry_v1,
							               m.v(m.n(exit_corner)),
							               m.v(m.p(exit_corner)));
							m.add_triangle(entry_v2,
							               m.v(m.p(exit_corner)),
							               m.v(    exit_corner) );
						}
						else {
							int entry_corner = m.c(current_triangle, entry_edge);
							int exit_v1 = m.add_vertex(exit_point),
							    exit_v2 = m.add_vertex(exit_point);
							/* disable entry vertices */
							if (entry_edge == exit_edge) {
								Point p1, p2,
								      edge_vector = m.G[m.v(m.n(entry_corner))].minus(m.G[m.v(entry_corner)]);
								int p1v1, p1v2, p2v1, p2v2;
								if (edge_vector.dot(exit_point) > edge_vector.dot(entry_point)) {
									p1 = entry_point;
									p1v1 = entry_v1;
									p1v2 = entry_v2;
									p2 = exit_point;
									p2v1 = exit_v1;
									p2v2 = exit_v2;
								}
								else {
									p1 = exit_point;
									p1v1 = exit_v1;
									p1v2 = exit_v2;
									p2 = entry_point;
									p2v1 = entry_v1;
									p2v2 = entry_v2;
								}
								/* TODO: Unhandled case - entry_point = exit_point */
								/* TODO: split up other triangle? */
								m.add_triangle(p2v1,
								               m.v(m.n(entry_corner)),
								               m.v(m.p(entry_corner)));
								/* m.add_triangle(m.add_vertex(p1),
								               m.add_vertex(p2),
								               m.add_vertex(m.G[m.v(m.p(entry_corner))])); */
								m.add_triangle(m.v(entry_corner),
								               p1v2,
								               m.v(m.p(entry_corner)));
							}
							else {
								int c1, c2;
								Point p1, p2;
								int p1v1, p1v2, p2v1, p2v2;
								if (exit_corner == m.n(entry_corner)) {
									c1 = entry_corner;
									c2 = exit_corner;
									p1 = entry_point;
									p1v1 = entry_v1;
									p1v2 = entry_v2;
									p2 = exit_point;
									p2v1 = exit_v1;
									p2v2 = exit_v2;
								}
								else {
									c1 = exit_corner;
									c2 = entry_corner;
									p1 = exit_point;
									p1v1 = exit_v1;
									p1v2 = exit_v2;
									p2 = entry_point;
									p2v1 = entry_v1;
									p2v2 = entry_v2;
								}
								m.add_triangle(p1v2,
								               m.v(c2),
								               p2v1);
								m.add_triangle(m.v(c1),
								               p1v1,
								               p2v2);
								m.add_triangle(m.v(c1),
								               p2v2,
								               m.v(m.p(c1)));
							}
							entry_v1 = exit_v2;
							entry_v2 = exit_v1;
						}
						if (m.bs(m.n(exit_corner))) {
							current_triangle = -1;
							entry_edge = -1;
						}
						else {
							current_triangle = m.t(m.s(m.n(exit_corner)));
							entry_edge = m.s(m.n(exit_corner)) % 3;
						}
						println("Triangle " + current_triangle + "(" + entry_edge + ")");
						break;
					}
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
