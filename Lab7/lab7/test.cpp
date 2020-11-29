#include "common.h"
#include "Geometry.h"
#include "time.h"

extern int mode;
extern vector<Geometry *> readGeom(const char *filename);
extern vector<string> readName(const char* filename);

void transformValue(double &res, const char* format = "%.2lf"){

	char buf[20];
	sprintf(buf, format, res);
	sscanf(buf, "%lf", &res);
}

void wrongMessage(Envelope e1, Envelope e2, bool cal)
{
	cout << "Your answer is " << cal << "for test ";
	e1.print();
	cout << " and ";
	e2.print();
	cout << ", but the answer is " << !cal << endl;
}

void wrongMessage(const Point& pt1, const Point& pt2, double dis, double res)
{
	cout << "Your answer is " << dis << "for test ";
	pt1.print();
	cout << " and ";
	pt2.print();
	cout << ", but the answer is " << res << endl;
}

void wrongMessage(Envelope e1, Envelope e2, Envelope cal, Envelope res)
{
	cout << "Your answer is ";
	cal.print();
	cout << "for test ";
	e1.print();
	cout << " and ";
	e2.print();
	cout << ", but the answer is ";
	res.print();
	cout << endl;
}

void test(int t)
{
	cout << "***********************************************" << endl;
	if (t == TEST1) //distanceOnSphere
	{
		cout << "测试1: Point DistanceOnSphere" << endl;
		int ncase, cct;
		ncase = cct = 2;

		Point pt1(100.5, 20.7), pt2(100.3, 20.6);
		double dis = pt1.distanceOnSphere(&pt2);
		transformValue(dis);

		if (fabs(dis - 696.59) > 1e-6) {
			--cct;
			wrongMessage(pt1, pt2, dis, 696.59);
		}

		pt1 = Point(90.5, 30.5);
		pt2 = Point(20.7, 99.9);

		dis = pt1.distanceOnSphere(&pt2);
		transformValue(dis);
		
		if (fabs(dis - 3547.6) > 1e-6) {
			--cct;
			wrongMessage(pt1, pt2, dis, 3547.6);
		}
		cout << cct << " / " << ncase << endl;
	}
	else if (t == TEST2) //contain
	{
		cout << "测试2: Envelope Contain" << endl;
		int ncase, cct;
		ncase = cct = 2;
		vector<Point> pts1, pts2;
		pts1.push_back(Point(0, 0));
		pts1.push_back(Point(2, 2));
		pts2.push_back(Point(1, 1));
		pts2.push_back(Point(0, 0));
		pts2.push_back(Point(-1, -1));
		LineString line1(pts1), line2(pts2);
		if (line1.getEnvelope().contain(line2.getEnvelope())) {
			wrongMessage(line1.getEnvelope(), line2.getEnvelope(), true);
			--cct;
		}
		pts2.pop_back();
		line2 = LineString(pts2);
		if (!line1.getEnvelope().contain(line2.getEnvelope())) {
			wrongMessage(line1.getEnvelope(), line2.getEnvelope(), false);
			--cct;
		}
		cout << cct << " / " << ncase << endl;
	}
	else if (t == TEST3) //intersect
	{
		cout << "测试3: Envelope Intersect" << endl;
		int ncase, cct;
		ncase = cct = 2;
		vector<Point> pts1, pts2;
		pts1.push_back(Point(0, 0));
		pts1.push_back(Point(2, 2));
		pts2.push_back(Point(-1, -1));
		pts2.push_back(Point(1, 1));
		LineString line1(pts1), line2(pts2);
		if (!line1.getEnvelope().intersect(line2.getEnvelope())) {
			wrongMessage(line1.getEnvelope(), line2.getEnvelope(), false);
			--cct;
		}
		pts2.pop_back();
		pts2.push_back(Point(-0.1, -0.1));
		line2 = LineString(pts2);
		if (line1.getEnvelope().intersect(line2.getEnvelope())) {
			wrongMessage(line1.getEnvelope(), line2.getEnvelope(), true);
			--cct;
		}
		cout << cct << " / " << ncase << endl;
	}
	else if (t == TEST4) //union
	{
		cout << "测试4: Envelope Union" << endl;
		int ncase, cct;
		ncase = cct = 2;
		vector<Point> pts1;
		pts1.push_back(Point(0, 0));
		pts1.push_back(Point(1, 1));
		Point pt(2, 2);
		
		LineString line1(pts1);
		Envelope res = Envelope(0, 2, 0, 2);
		Envelope e = line1.getEnvelope().unionA(pt.getEnvelope());

		if (e != res) {
			wrongMessage(line1.getEnvelope(), pt.getEnvelope(), e, res);
			--cct;
		}

		vector<Point> pts2;
		pts2.push_back(Point(0.5, 0.5));
		pts2.push_back(Point(2, 2));
		LineString line2(pts2);
		res = Envelope(0, 2, 0, 2);
		e = line1.getEnvelope().unionA(line2.getEnvelope());
		
		if (e != res) {
			wrongMessage(line1.getEnvelope(), line2.getEnvelope(), e, res);
			--cct;
		}
		cout << cct << " / " << ncase << endl;
	}
	else if (t == TEST5) {
		cout << "测试5: QuadTree Test" << endl;
		int ncase, cct;
		ncase = cct = 1;
		QuadTree qtree;
		vector<Geometry *> geom = readGeom(".//data/polygon");
		vector<Feature> features;

		for (size_t i = 0; i < geom.size(); ++i)
			features.push_back(Feature("", geom[i]));

		qtree.setCapacity(1);
		qtree.constructQuadTree(features);

		int height, interiorNum, leafNum;
		qtree.countHeight(height);
		qtree.countQuadNode(interiorNum, leafNum);

		if (!(height == 6 && interiorNum == 8 && leafNum == 25)){
			cout << "Your answer is height: " << height << ", interiorNum: " << interiorNum <<
				", leafNum: " << leafNum << " for case1, but the answer is height: 6, interiorNum: 8, leafNum: 25\n";
			--cct;
		}
		cout << cct << " / " << ncase << endl;
	}

	cout << "***********************************************" << endl;
}

void QuadTreeAnalysis()
{
	cout << "***********************************************" << endl;
	cout << "测试6: QuadTreeAnalysis" << endl;

	vector<Feature> features;

	vector<Geometry *> geom = readGeom(".//data/taxi");
	vector<string> name;
	name.reserve(geom.size());
	name=readName(".//data/taxi");

	features.clear();
	features.reserve(geom.size());
	for (size_t i = 0; i < geom.size(); ++i)
	{
		features.push_back(Feature(name[i], geom[i]));
		if (i % 10000 == 0)
			cout << i << endl;
	}
		

	cout << "taxi data cct: " << geom.size() << endl;

	
	srand(time(NULL));
	for (int cap = 70; cap <= 200; cap+=10) {
		// Task 7
		// Write your code here
		// 构造四叉树，输出四叉树的节点数目和高度
		QuadTree qtree;
		qtree.setCapacity(cap);
		qtree.constructQuadTree(features);
		int height;
		qtree.countHeight(height);
		int interiorNum, leafNum;
		qtree.countQuadNode(interiorNum, leafNum);

		double x, y;
		Feature f;
		clock_t start_time = clock();
		for (int i = 0; i < 100000; ++i) {
			x = -((rand() % 225) / 10000.0 + 73.9812);
			y = (rand() % 239) / 10000.0 + 40.7247;
			qtree.NNQuery(x, y, f);
		}
		clock_t end_time = clock();

		cout << "Running time for capacity " << cap << " is: " << static_cast<double>(end_time - start_time) / CLOCKS_PER_SEC << "s" << endl;
		cout << "The height is " << height << ". The interiorNum is " << interiorNum << ". The leafNum is " << leafNum << endl;
	}
	cout << "***********************************************" << endl;
}