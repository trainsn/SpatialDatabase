#include "KMeans.h"
#include <gl\glut.h> 

/*
 * Cluster functions
 */
bool Cluster::resetMean()
{
	double x = 0, y = 0, _x = mean.getX(), _y = mean.getY();

	// Task 6.2
	// Write your code here
	for (int i = 0; i < features.size(); i++)
	{
		x += ((Point*)features[i].getGeom())->getX();
		y += ((Point*)features[i].getGeom())->getY();
	}
	x /= features.size();
	y /= features.size();
	mean = Point(x, y);
	
	return (!(fabs(mean.getX() - _x) < 1e-6 && fabs(mean.getY() - _y) < 1e-6));
}

void Cluster::draw()
{
	for (size_t i = 0; i < features.size(); ++i)
		features[i].draw();
}

void Cluster::print()
{
	cout << "mean is (";
	mean.print();
	cout << ")";
	for (size_t i = 0; i < features.size(); ++i)
		features[i].print();
}

/*
 * KMeans functions
 */
void KMeans::cluster(vector<Feature>& features, int k, int maxIterNum)
{
	clusters.clear();
	if (k <= 0 || k > 5) 
		k = 5;
	
	srand((unsigned)time(NULL));
	int num = features.size();
	for (int i = 0; i < k; ++i) {
		Point *pt = (Point *)(features[rand() % num].getGeom());
		clusters.push_back(Cluster(*pt));
	}

	// Task 6.1
	// Write your code here
	for (int test = 0; test < maxIterNum; test++)
	{
		for (int i = 0; i < features.size(); i++)
		{
			double minDist = 10000;
			int tCluster;
			for (int j = 0; j < k; j++)
			{
				double dist = features[i].calcDist(clusters[j].getMean().getX(), clusters[j].getMean().getY());
				if (dist < minDist)
				{
					minDist = dist;
					tCluster = j;
				}
			}
			clusters[tCluster].addFeature(features[i]);
		}
		bool flag = true;
		for (int i = 0; i < k; i++)
		{
			if (clusters[i].resetMean())
				flag = false;
		}
		if (!flag)
		{
			for (int i = 0; i < clusters.size(); i++)
				clusters[i].clearFeatures();
		}
		else 
			break;
	}
	
}

void KMeans::draw()
{
	int r[5] = { 27, 217, 117, 231, 102 };
	int g[5] = { 158, 95, 112, 41, 166 };
	int b[5] = { 119, 2, 179, 138, 30 };

	for (size_t i = 0; i < clusters.size(); ++i) {
		glColor3d(r[i] / 255.0, g[i] / 255.0, b[i] / 255.0);
		clusters[i].draw();
	}
}

void KMeans::print()
{
	for (size_t i = 0; i < clusters.size(); ++i) {
		cout << "Cluster " << i << ":" << endl;
		clusters[i].print();
		cout << endl;
	}
}