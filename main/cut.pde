class Cut {
	float node_radius = 2;
	int current_triangle;

	ArrayList<Point> path_list;
	ArrayList<Point> isect_list;
	Mesh m;

	int entry_edge;
	Point entry_point;
	int entry_v1, entry_v2;

	Cut(Mesh arg_m) {
		path_list = new ArrayList();
		isect_list = new ArrayList();
		m = arg_m;
		current_triangle = -1;
		/* edge numbers correspond to the number (%3) of the first endpoint corner */
		entry_edge = -1;
		entry_point = null;
		entry_v1 = -1;
		entry_v2 = -1;
	}

	void add_point(Point p) {
		path_list.add(p);

		if (path_list.size() == 1) {
			/* First point - figure out where we are */
			for (int i=0; i < m.triangle_count; i++) {
				if (triangle_contains(m.g(m.v(m.c(i,0))),
				                      m.g(m.v(m.c(i,1))),
				                      m.g(m.v(m.c(i,2))),
				                      p)) {
					current_triangle = i;
					break;
				}
			}
		}
		else {
			Point A = path_list.get(path_list.size()-2),
			      B = p,
			      C, D;
			if (current_triangle < 0) {
				/* If we were outside, check every triangle */

				/* iterate over all corners */
				/* TODO: this hits every interior edge twice */
				int corner;
				for (int i=0; i < m.triangle_count; i++) {
					if (m.enabled_triangle(i)) {
						for (int j=0; j < 3; j++) {
							corner = m.c(i,j);
							C = m.g(m.v(corner));
							D = m.g(m.v(m.n(corner)));
							Point isect = line_segment_intersection(A, B, C, D);
							if (isect != null) {
								isect_list.add(isect);
								entry_point = isect;
								current_triangle = i;
								entry_edge = j;
								entry_v1 = m.add_vertex(entry_point);
								entry_v2 = m.add_vertex(new Point(entry_point));
								break;
							}
						}
					}
				}
			}
			else {
				/* If we're inside a triangle now, check intersections with its edges */
				/* iterate over edges of current_triangle */
				for (int exit_edge=0; exit_edge < 3; exit_edge++) {
					int exit_corner = m.c(current_triangle, exit_edge);
					C = m.g(m.v(exit_corner));
					D = m.g(m.v(m.n(exit_corner)));
					Point exit_point = line_segment_intersection(A, B, C, D);
					if (exit_point != null) {
						isect_list.add(exit_point);

						/* go ahead and compute next triangles and entry edge
						 * while everything is still consistent */
						int next_triangle, next_entry_edge;
						if (m.bs(m.n(exit_corner))) {
							next_triangle = -1;
							next_entry_edge = -1;
						}
						else {
							next_triangle = m.t(m.s(m.n(exit_corner)));
							next_entry_edge = m.s(m.n(exit_corner)) % 3;
						}

						/* Cut up current triangle */
						m.disable_triangle(current_triangle);
						/* split current triangle */
						int exit_v1 = m.add_vertex(exit_point),
						    exit_v2 = m.add_vertex(new Point(exit_point));
						if (entry_point == null) {
							/* no entry point - must have started in this triangle */
							m.add_triangle(exit_v2,
							               m.v(m.n(exit_corner)),
							               m.v(m.p(exit_corner)));
							m.add_triangle(exit_v1,
							               m.v(m.p(exit_corner)),
							               m.v(    exit_corner) );
						}
						else {
							m.enable_physics(entry_v1);
							m.enable_physics(entry_v2);
							int entry_corner = m.c(current_triangle, entry_edge);
							if (entry_edge == exit_edge) {
								Point p1, p2,
								      edge_vector = m.g(m.v(m.n(entry_corner))).minus(m.g(m.v(entry_corner)));
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
								/* TODO: Unhandled case - entry_point == exit_point */
								m.add_triangle(p2v1,
								               m.v(m.n(entry_corner)),
								               m.v(m.p(entry_corner)));
								/* m.add_triangle(m.add_vertex(p1),
								               m.add_vertex(p2),
								               m.add_vertex(m.g(m.v(m.p(entry_corner))))); */
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
						}
						if (next_triangle == -1) {
							m.enable_physics(exit_v1);
							m.enable_physics(exit_v2);
						}
						current_triangle = next_triangle;
						entry_edge = next_entry_edge;
						entry_point = exit_point;
						entry_v1 = exit_v2;
						entry_v2 = exit_v1;
						break;
					}
				}
			}
		}
	}

	void terminate(Point p) {
		if (current_triangle >= 0) {
			/* Cut up current triangle */
			m.disable_triangle(current_triangle);
			/* split current triangle */
			if (entry_point != null) {
				m.enable_physics(entry_v1);
				m.enable_physics(entry_v2);
				int entry_corner = m.c(current_triangle, entry_edge);
				/* disable entry vertices */
				m.add_triangle(entry_v2,
				               m.v(m.n(entry_corner)),
				               m.v(m.p(entry_corner)));
				m.add_triangle(entry_v1,
				               m.v(m.p(entry_corner)),
				               m.v(    entry_corner) );
			}
			else {
				/* no entry point - must have started and ended in this triangle - do nothing */
			}
		}
	}

	void draw() {
		Point prev, cursor;

		strokeWeight(1);
		cursor = null;
		for (int i=0; i < path_list.size(); i++) {
			prev = cursor;
			cursor = path_list.get(i);

			if (prev != null) {
				line(prev.x, prev.y, cursor.x, cursor.y);
			}
		}

		/* strokeWeight(2);
		fill(0, 0, 255);
		cursor = null;
		for (int i=0; i < isect_list.size(); i++) {
			prev = cursor;
			cursor = isect_list.get(i);

			ellipse(cursor.x, cursor.y, 2*node_radius, 2*node_radius);
			if (prev != null) {
				line(prev.x, prev.y, cursor.x, cursor.y);
			}
		} */
	}
}
