// lab7.cpp : 定义控制台应用程序的入口点。
//

#define FREEGLUT_STATIC
#pragma comment(lib,"freeglut_staticd.lib")

#include "common.h"
#include "Geometry.h"
#include "KMeans.h"
#include "shapelib/shapefil.h"
#include "voronoi.h"

#include <gl\freeglut.h>       // Glut库头文件

#include <iostream>
#include <vector>
#include <cstdio> 
#include <time.h>
#include <map>
#include <list>
using namespace std;

extern void test(int t);
extern void QuadTreeAnalysis();

int screenWidth  = 640;
int screenHeight = 480;

double pointSize = 2.0;

int mode;

vector<Feature> features;
vector<Feature> roads;
bool showRoad = true;

QuadTree qtree;
bool showQuadTree = false;
bool showVoronoi = false;

Feature nearestFeature;

bool firstPoint = true;
Point corner[2];
Envelope selectedRect;
vector<Feature> selectedFeatures;

KMeans kmeans;

/*
 * shapefile文件中name和geometry属性读取
 */
vector<string> readName(const char* filename)
{
	DBFHandle file = DBFOpen(filename, "r");	
	vector<string> res;	
	int cct = DBFGetRecordCount(file);
	res.reserve(cct);

	for (int i = 0; i < cct; ++i){
		string a = DBFReadStringAttribute(file, i, 0);
		if (i%10000==0)
			cout << i << endl;
		res.push_back(a);
	}

	DBFClose(file);

	return res;
}

vector<Geometry *> readGeom(const char *filename)
{
	SHPHandle file = SHPOpen(filename, "r");

	int pnEntities, pnShapeType;
	double padfMinBound[4], padfMaxBound[4];
	SHPGetInfo(file, &pnEntities, &pnShapeType, padfMinBound, padfMaxBound);
	
	vector<Point> points;
	vector<Geometry *> geoms;
	geoms.reserve(pnEntities);
	switch (pnShapeType){
	case SHPT_POINT:
		for (int i = 0; i < pnEntities; ++i) {
			SHPObject *pt = SHPReadObject(file, i);
			geoms.push_back(new Point(pt->padfY[0], pt->padfX[0]));
			delete pt;
		}
		break;

	case SHPT_ARC:
		for (int i = 0; i < pnEntities; ++i) {
			points.clear();
			SHPObject *pt = SHPReadObject(file, i);
			for (int j = 0; j < pt->nVertices; ++j){
				points.push_back(Point(pt->padfY[j], pt->padfX[j]));
			}
			delete pt;
			geoms.push_back(new LineString(points));
		}
		break;

	case SHPT_POLYGON:
		for (int i = 0; i < pnEntities; ++i) {
			points.clear();
			SHPObject *pt = SHPReadObject(file, i);
			for (int j = 0; j < pt->nVertices; ++j){
				points.push_back(Point(pt->padfY[j], pt->padfX[j]));
			}
			delete pt;
			LineString line(points);
			Polygon1 *poly = new Polygon1(line);
			geoms.push_back(new Polygon1(line));
		}
		break;
	}
	
	SHPClose(file);
	return geoms;
}

/*
 * 输出几何信息
 */
void printGeom(vector<Geometry *>& geom)
{
	cout << "Geometry:" << endl;
	for (vector<Geometry *>::iterator it = geom.begin(); it != geom.end(); ++it) {
		(*it)->print();
	}
}

/*
 * 删除几何信息
 */
void deleteGeom(vector<Geometry *>& geom)
{
	for (vector<Geometry *>::iterator it = geom.begin(); it != geom.end(); ++it) {
		delete *it;
		*it = NULL;
	}
	geom.clear();
}

/*
 * 读取纽约自行车租赁点数据
 */
void loadStationData()
{
	vector<Geometry *> geom = readGeom(".//data/station");
	vector<string> name = readName(".//data/station");

	features.clear();
	for (size_t i = 0; i < geom.size(); ++i)
		features.push_back(Feature(name[i], geom[i]));

	cout << "station data cct: " << geom.size() << endl;
	qtree.setCapacity(5);
	qtree.constructQuadTree(features);
}

/*
 * 读取纽约出租车打车点数据
 */
void loadTaxiData()
{
	vector<Geometry *> geom = readGeom(".//data/taxi");
	vector<string> name = readName(".//data/taxi");

	features.clear();
	for (size_t i = 0; i < geom.size(); ++i)
		features.push_back(Feature(name[i], geom[i]));

	cout << "taxi data cct: " << geom.size() << endl;
	qtree.setCapacity(100);
	qtree.constructQuadTree(features);
}

/*
 * 从屏幕坐标转换到地理坐标
 */
void transfromPt(Point &pt)
{
	const Envelope bbox = qtree.getEnvelope();
	double width = bbox.getMaxX() - bbox.getMinX() + 0.002;
	double height = bbox.getMaxY() - bbox.getMinY() + 0.002;

	double x = pt.getX() * width / screenWidth + bbox.getMinX() - 0.001;
	double y = pt.getY() * height / screenHeight + bbox.getMinY() - 0.001;
	
	x = max(bbox.getMinX(), x);
	x = min(bbox.getMaxX(), x);
	y = max(bbox.getMinY(), y);
	y = min(bbox.getMaxY(), y);
	pt = Point(x, y);
}

/*
 * 绘制代码
 */
void display()
{	
	glClear(GL_COLOR_BUFFER_BIT);
	//glClearColor(241 / 255.0, 238 / 255.0, 232 / 255.0, 0.0); 
	glClearColor(1.0, 1.0, 1.0, 0.0);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	const Envelope bbox = qtree.getEnvelope();
	gluOrtho2D(bbox.getMinX() - 0.001, bbox.getMaxX() + 0.001, bbox.getMinY() - 0.001, bbox.getMaxY() + 0.001);

	// 道路绘制
	if (showRoad) {
		glColor3d(252 / 255.0, 214 / 255.0, 164 / 255.0);
		for (size_t i = 0; i < roads.size(); ++i)
			roads[i].draw();
	}
	
	// 点绘制
	glPointSize(pointSize);
	glColor3d(0.0, 146 / 255.0, 247 / 255.0);
	for (size_t i = 0; i < features.size(); ++i)
		features[i].draw();

	// 四叉树绘制
	if (showQuadTree)
		qtree.draw();

	// 离鼠标最近点绘制
	if (mode == NN) {
		glPointSize(5.0);
		glColor3d(0.9, 0.0, 0.0);
		nearestFeature.draw();
	}

	// 区域选择绘制
	if (mode == RANGE) {
		glColor3d(0.0, 0.0, 0.0);
		selectedRect.draw();
		glColor3d(1.0, 0.0, 0.0);
		for (size_t i = 0; i < selectedFeatures.size(); ++i)
			selectedFeatures[i].draw();
	}

	// K-Means聚类结果绘制
	if (mode == CLUSTER)
		kmeans.draw();

	if (showVoronoi)
		print_output();
	glFlush();
	glutSwapBuffers();
}

/*
 * 鼠标和键盘交互
 */
void mouse(int button, int state, int x, int y)
{
	if (button == GLUT_LEFT_BUTTON && state == GLUT_DOWN) {
		if (mode == RANGE) {
			if (firstPoint) {
				selectedFeatures.clear();
				corner[0] = Point(x, screenHeight - y);
				transfromPt(corner[0]);
			}
			else {
				corner[1] = Point(x, screenHeight - y); 
				transfromPt(corner[1]);
				selectedRect = Envelope(min(corner[0].getX(), corner[1].getX()), max(corner[0].getX(), corner[1].getX()), 
										min(corner[0].getY(), corner[1].getY()), max(corner[0].getY(), corner[1].getY()));
				qtree.rangeQuery(selectedRect, selectedFeatures);
			}
			firstPoint = !firstPoint;
			glutPostRedisplay();
		}
	}
}

void passiveMotion(int x, int y)
{
	corner[1] = Point(x, screenHeight - y);
	if (mode == NN) {
		Point p(x, screenHeight - y);
		transfromPt(p);
		qtree.NNQuery(p.getX(), p.getY(), nearestFeature);
		glutPostRedisplay();
	}
	else if (mode == RANGE && !firstPoint) {
		corner[1] = Point(x, screenHeight - y); 
		transfromPt(corner[1]);
		selectedRect = Envelope(min(corner[0].getX(), corner[1].getX()), max(corner[0].getX(), corner[1].getX()), 
								min(corner[0].getY(), corner[1].getY()), max(corner[0].getY(), corner[1].getY()));
		qtree.rangeQuery(selectedRect, selectedFeatures);
		glutPostRedisplay();
	}
}

void changeSize(int w, int h)
{
	screenWidth = w;
	screenHeight = h;
	glViewport(0, 0, w, h);
	glutPostRedisplay();
}

void processNormalKeys(unsigned char key, int x, int y)
{
	switch(key) {
		case 27:exit(0); break;
		case 'N':
		case 'n':
			mode = NN; break;
		case 'S':
		case 's':
			mode = RANGE; 
			firstPoint = true; 
			break;
		case 'K':
		case 'k':
			//kmeans.cluster(features, 5, 100); 
			kmeans.cluster(features, 5, 10000);
			mode = CLUSTER; 
			break;
		case 'B':
		case 'b':
			loadStationData();
			mode = Default;
			break;
		case 'T':
		case 't':
			loadTaxiData();
			mode = Default;
			break;
		case 'R':
		case 'r':
			showRoad = !showRoad;
			break;
		case 'Q':
		case 'q':
			showQuadTree = !showQuadTree;
			break;
		case 'U':
		case 'u':
			showVoronoi = !showVoronoi;
			break;
		case '+':
			pointSize *= 1.1;
			break;
		case '-':
			pointSize /= 1.1;
			break;
		case '1':
			test(TEST1); break;
		case '2':
			test(TEST2); break;
		case '3':
			test(TEST3); break;
		case '4':
			test(TEST4); break;
		case '5':
			test(TEST5); break;
		case '6':
			QuadTreeAnalysis();
			break;
			
		default: 
			mode = Default; break;
	}
	glutPostRedisplay();
}

int main(int argc, char* argv[])
{
	cout << "Key Usage:\n"
		<< "  S/s: range search\n"
		<< "  N/n: nearest point search\n"
		<< "  K/k: K-means clustering\n"
		<< "  B/b: Bicycle data\n"
		<< "  T/t: Taxi data\n"
		<< "  R/r: show Road\n"
		<< "  Q/q: show QuadTree\n"
		<< "  U/u: show Voronoi diagram\n"
		 << "  +  : increase point size\n"
		 << "  -  : decrease point size\n"
		 << "  1  : Test distanceOnSphere\n"
		 << "  2  : Test envelope.contain\n"
		 << "  3  : Test envelope.intersect\n"
		 << "  4  : Test envelope.union\n"
		 << "  5  : Test count height, leaves\n"
		 << "  6  : NNQuery Time Test\n"
		 << "  ESC: quit\n"
		 << endl;

	loadStationData();

	vector<Geometry *> geom = readGeom(".//data/highway");
	for (size_t i = 0; i < geom.size(); ++i)
		roads.push_back(Feature("", geom[i]));
	voronoi();

	glutInit(&argc, argv);
	glutInitWindowSize(screenWidth, screenHeight);
	glutInitWindowPosition(0, 0);
	glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE);
	glutCreateWindow("New York");

	glutMouseFunc(mouse);
	glutDisplayFunc(display);
	glutPassiveMotionFunc(passiveMotion);
	glutReshapeFunc(changeSize);
	glutKeyboardFunc(processNormalKeys);

	glutMainLoop();

	return 0;
}

