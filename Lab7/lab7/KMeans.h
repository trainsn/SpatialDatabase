#ifndef KMEANS_H_INCLUDED
#define KMEANS_H_INCLUDED

#include "common.h"

#include <vector>
#include <iostream>
#include <algorithm>
#include <cstdio> 
#include <ctime> 
using namespace std;

class Cluster {
private:
	Point mean;
	vector<Feature> features;

public:
	Cluster(Point mean) : mean(mean) {}

	const Point& getMean()            { return mean; }
	void addFeature(Feature& feature) {	features.push_back(feature); }
	void clearFeatures()              { features.clear(); }

	// Task 6.2
	bool resetMean();

	void draw();

	void print();
};

class KMeans {
public:
	vector<Cluster> clusters;

	KMeans() {}

	// Task 6.1
	void cluster(vector<Feature>& features, int k, int maxIterNum = 100000);

	void draw();

	void print();
};
#endif