#include "Geometry.h"
#include <cmath>
#include <gl\glut.h> 

#define  min(a,b) (((a) < (b)) ? (a) : (b))
#define  max(a,b) (((a) > (b)) ? (a) : (b))
/*
 * Envelope functions
 */
bool Envelope::contain(double x, double y) const
{
	return x >= minX && x <= maxX && y >= minY && y <= maxY;
}

bool Envelope::contain(const Envelope& envelope) const
{
	// Task 2.1 测试Envelope是否包含关系
	// Write your code here
	double tminx = envelope.getMinX();
	double tmaxx = envelope.getMaxX();
	double tminy = envelope.getMinY();
	double tmaxy = envelope.getMaxY();
	if (minX <= tminx&&maxX >= tmaxx&&minY <= tminy&&maxY >= tmaxy)
		return true;
	return false;
}

bool Envelope::intersect(const Envelope& envelope) const
{
	// Task 2.2 测试Envelope是否相交
	// Write your code here
	double tminx = envelope.minX;
	double tmaxx = envelope.maxX;
	double tminy = envelope.minY;
	double tmaxy = envelope.maxY;
	int flagx = 0, flagy = 0;
	if ((tminx >= minX && tminx <= maxX) 
		|| (tmaxx >= minX && tmaxx <= maxX)
		||(tminx<=minX&&tmaxx>=maxX))
		flagx = 1;
	if ((tminy >= minY && tminy <= maxY) 
		|| (tmaxy >= minY && tmaxy <= maxY)
		|| (tminy <= minY&&tmaxy >= maxY))
		flagy = 1;
	if (flagx&&flagy)
		return true;
	return false;
}

Envelope Envelope::unionA(const Envelope& envelope) const
{
	// Task 2.3 合并两个Envelope生成一个新的Envelope
	// Write your code here
	double tminx = envelope.getMinX();
	double tmaxx = envelope.getMaxX();
	double tminy = envelope.getMinY();
	double tmaxy = envelope.getMaxY();
	Envelope t(min(tmaxx, minX), max(tmaxx, maxX), min(tminy, minY), max(tmaxy, maxY));
	return t;
}

void Envelope::draw() const
{
	glBegin(GL_LINE_STRIP);

	glVertex2f(minX, minY);
	glVertex2f(minX, maxY);
	glVertex2f(maxX, maxY);
	glVertex2f(maxX, minY);
	glVertex2f(minX, minY);

	glEnd();
}


/*
 * Points functions
 */
double Point::distanceOnSphere(const Point* point) const	
{
	// Task 1 计算两点之间的球面距离(km)
	double R = 6367;
	// Write your code here
	double wa, ja, wb,jb;
	ja = x; wa = y;
	jb = point->x; wb = point->y;
	return R*acos(cos(wa)*cos(wb)*cos(jb-ja)+sin(wa)*sin(wb));
}

double Point::distance(const Point* point) const
{
	return sqrt((x - point->x) * (x - point->x) + (y - point->y) * (y - point->y));
}

double Point::distance(const LineString* line) const
{
	cout << "to be implemented: Point::distance(const LineString* line)\n"; 
	return NOT_IMPLEMENT;
}

double Point::distance(const Polygon1* polygon) const 
{
	cout << "to be implemented: Point::distance(const Polygon* polygon)\n"; 
	return NOT_IMPLEMENT;
}

void Point::draw()  const
{
	glBegin(GL_POINTS);
	glVertex2f(x, y);
	glEnd();
}


/*
 * LineString functions
 */
void LineString::constructEnvelope() 
{
	double minX, minY, maxX, maxY;
	maxX = minX = points[0].getX();
	maxY = minY = points[0].getY();
	for (size_t i = 1; i < points.size(); ++i) {
		maxX = max(maxX, points[i].getX());
		maxY = max(maxY, points[i].getY());
		minX = min(minX, points[i].getX());
		minY = min(minY, points[i].getY());
	}
	envelope = Envelope(minX, maxX, minY, maxY);
}

double LineString::distance(const LineString* line) const
{
	cout << "to be implemented: LineString::distance(const LineString* line)\n"; 
	return NOT_IMPLEMENT;
}

double LineString::distance(const Polygon1* polygon) const
{
	cout << "to be implemented: LineString::distance(const Polygon* polygon)\n"; 
	return NOT_IMPLEMENT;
}

void LineString::print() const 
{
	cout << "LineString(";
	for (size_t i = 0; i < points.size(); ++i) {
		if (i != 0)
			cout << ", ";
		cout << points[i].getX() << " " << points[i].getY();
	}
	cout << ")";
}

void LineString::draw()  const
{
	glBegin(GL_LINE_STRIP);
	for (size_t i = 1; i < points.size(); ++i)
		glVertex2d(points[i].getX(), points[i].getY());
	glEnd();
}


/*
 * Polygon
 */
double Polygon1::distance(const Polygon1* polygon) const
{
	cout << "to be implemented: Polygon::distance(const Polygon* polygon)\n"; 
	return NOT_IMPLEMENT;
}

void Polygon1::print() const
{
	cout << "Polygon(";
	for (size_t i = 0; i < exteriorRing.numPoints(); ++i) {
		if (i != 0)
			cout << ", ";
		Point p = exteriorRing.getPointN(i);
		cout << p.getX() << " " << p.getY();
	}
	cout << ")";
}

void Polygon1::draw() const
{
	exteriorRing.draw();
}
