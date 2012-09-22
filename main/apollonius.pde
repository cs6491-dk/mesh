/* not really the Apollonius problem but close
 * This can be considered a degenerate Apollonius problem
 * in which all circles have zero radius. At this point
 * inside or outside tangency means nothing, so no
 * multiple solutions to choose from */

Disk
apollonius(Point p1, Point p2, Point p3)
{
	if ((p1.x-p3.x)*(p1.y-p2.y) == (p1.x-p2.x)*(p1.y-p3.y)) {
		return new Disk(0.0, 0.0, 1e10);
	}

	if (p1.x == p2.x) {
		/* Swap 2 & 3 */
		Point tmp = p2;
		p2 = p3;
		p3 = tmp;
	}
	else if (p2.x == p3.x) {
		/* Swap 1 & 2 */
		Point tmp = p2;
		p2 = p1;
		p1 = tmp;
	}

	float dx12 = p1.x - p2.x;
	float dx23 = p2.x - p3.x;
	float dy21 = p2.y - p1.y;
	float dy32 = p3.y - p2.y;

	float n12 = sq(p1.x) - sq(p2.x) + sq(p1.y) - sq(p2.y);
	float n23 = sq(p2.x) - sq(p3.x) + sq(p2.y) - sq(p3.y);

	float y = (n23/dx23 - n12/dx12)/2/(dy21/dx12 - dy32/dx23);
	float x = y*dy21/dx12 + n12/dx12/2;
	float r = sqrt(sq(p1.x-x)+sq(p1.y-y));

	return new Disk(x, y, r);
}
