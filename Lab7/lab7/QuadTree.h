#ifndef QUADTREE_H_INCLUDED
#define QUADTREE_H_INCLUDED

#include <string>
#include "Geometry.h"

class Feature {
private:
	string name;
	Geometry* geom;

public:
	Feature() : geom(NULL) {}
	Feature(string name, Geometry* geom) : name(name), geom(geom) {}

	const string&   getName()     { return name; }
	
	const Geometry* getGeom()     { return geom; }

	const Envelope& getEnvelope() { return geom->getEnvelope(); }

	double calcDist(double x, double y) const { 
		Point point(x, y);
		return geom->distance(&point);
	}

	void print() const {
		cout << "Feature: " << name << " ";
		geom->print();
	}

	void draw() const {
		if (geom)
			geom->draw();
	}
};


class QuadNode {
private:
	Envelope bbox;
	QuadNode* nodes[4];
	vector<Feature> features;

	QuadNode() {}

public:
	QuadNode(Envelope& box) {
		bbox = box;
		nodes[0] = nodes[1] = nodes[2] = nodes[3] = NULL;
	}

	~QuadNode() {
		for (int i = 0; i < 4; ++i) {
			delete nodes[i];
			nodes[i] = NULL;
		}
	}

	bool isLeafNode()                  { return nodes[0] == NULL; }

	const Envelope& getEnvelope()      { return bbox; }

	QuadNode* getChildNode(size_t i)   { return i < 4 ? nodes[i] : NULL; }

	size_t    getFeatureNum()          { return features.size(); }

	Feature&  getFeature(size_t i)     { return features[i]; }

	void add(Feature& f)               { features.push_back(f); }

	void add(vector<Feature>& fs)      { features.insert(features.begin(), fs.begin(), fs.end()); }

	void countNode(int& interiorNum, int& leafNum);

	int countHeight(int height);

	void draw();

	// Task 3.2
	// split the node into four child nodes, assign each feature to its overlaped child node(s),
	// clear feature vector, and split child node(s) if its number of features is larger than capacity 
	void split(size_t capacity);

	// Task 4.2
	void rangeQuery(Envelope& rect, vector<Feature>& features);

	// Task 5.2
	QuadNode* pointInLeafNode(double x, double y);
};


class QuadTree {
private:
	QuadNode* root;
	size_t capacity;
	Envelope bbox;

public:
	QuadTree() : root(NULL), capacity(5) {}
	QuadTree(size_t cap) : root(NULL), capacity(cap) {}
	~QuadTree() {
		delete root;
		root = NULL;
	}

	void setCapacity(int capacity) { this->capacity = capacity; }
	int  getCapacity() const       { return capacity;           }

	const Envelope& getEnvelope() const { return bbox; }

	// Task 3.1
	bool constructQuadTree(vector<Feature>& features);

	void countQuadNode(int& interiorNum, int& leafNum);

	void countHeight(int &height);

	// Task 4.1
	void rangeQuery(Envelope& rect, vector<Feature>& features);

	// Task 5.1
	bool NNQuery(double x, double y, Feature& feature);

	void draw();
};

#endif