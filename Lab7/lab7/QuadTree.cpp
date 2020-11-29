#include "QuadTree.h"

/*
 * QuadNode
 */
void QuadNode::split(size_t capacity)
{
	int num = getFeatureNum();
	if (num <= capacity)
		return;

	for (int i = 0; i < 4; ++i) {
		delete []nodes[i];
		nodes[i] = NULL;
		//nodes[i]->features.reserve(features.size());
	}
	// Task 3.2
	// Write your code here
	
	Envelope tenvelope = getEnvelope();
	double tminx = tenvelope.getMinX();
	double tmaxx = tenvelope.getMaxX();
	double tminy = tenvelope.getMinY();
	double tmaxy = tenvelope.getMaxY();
	
	double tmidx = (tminx + tmaxx) / 2;
	double tmidy = (tminy + tmaxy) / 2;
	
	Envelope sw(tminx, tmidx, tminy, tmidy);
	Envelope nw(tminx, tmidx, tmidy, tmaxy);
	Envelope se(tmidx, tmaxx, tminy, tmidy);
	Envelope ne(tmidx, tmaxx, tmidy, tmaxy);

	nodes[0] = new QuadNode(nw);
	nodes[1] = new QuadNode(ne);
	nodes[2] = new QuadNode(se);
	nodes[3] = new QuadNode(sw);

	for (int i = 0; i < 4;i++)
		nodes[i]->features.reserve(features.size());
	
	for (int i = 0; i < 4; i++)
		for (int j = 0; j < features.size(); j++)
		{
// 		if (nodes[i]->getEnvelope().contain(features[j].getEnvelope())
// 			&& features[j].getEnvelope().contain(nodes[i]->getEnvelope()))
		if (nodes[i]->getEnvelope().intersect(features[j].getEnvelope()))
			nodes[i]->add(features[j]);
		}

	for (int i = 0; i < 4; i++)
		nodes[i]->split(capacity);

	features.clear();
	
}

void QuadNode::countNode(int& interiorNum, int& leafNum)
{
	if (isLeafNode()) {
		++leafNum;
	}
	else {
		++interiorNum;
		for (int i = 0; i < 4; ++i)
			nodes[i]->countNode(interiorNum, leafNum);
	}
}

int QuadNode::countHeight(int height)
{
	++height;
	if (!isLeafNode()) {
		int cur = height;
		for (int i = 0; i < 4; ++i) {
			height = max(height, nodes[i]->countHeight(cur));
		}
	}
	return height;
}

void QuadNode::rangeQuery(Envelope& rect, vector<Feature>& features)
{
	if (!bbox.intersect(rect))
		return;

	// Task 4.2
	// Write your code here
	if (isLeafNode())
	{
		for (int i = 0; i < getFeatureNum(); i++)
		{
			if (getFeature(i).getEnvelope().intersect(rect))
				features.push_back(getFeature(i));
		}
		return;
	}
	for (int i = 0; i < 4; i++)
	{
		if (getChildNode(i)->getEnvelope().intersect(rect))
			getChildNode(i)->rangeQuery(rect, features);
	}
}

QuadNode* QuadNode::pointInLeafNode(double x, double y)
{
	// Task 5.2
	// Write your code here
	Envelope tenvelope(x, x, y, y);
	QuadNode* tnode;
	if (bbox.intersect(tenvelope))
	{
		if (isLeafNode())
			return this;
		else
			for (int i = 0; i < 4; i++)
			{
			tnode = nodes[i]->pointInLeafNode(x, y);
			if (tnode != NULL)
			{
				return tnode;
				break;
			}
			}				
	}
	
	return  NULL;
}

void QuadNode::draw()
{
	if (isLeafNode()) {
		bbox.draw();
	}
	else {
		for (int i = 0; i < 4; ++i)
			nodes[i]->draw();
	}
}

/*
 * QuadTree
 */
bool QuadTree::constructQuadTree(vector<Feature>& features)
{
	if (features.empty())
		return false;

	// Task 3.1
	// Write your code here
	double tminx = features[0].getEnvelope().getMinX();
	double tmaxx = features[0].getEnvelope().getMaxX();
	double tminy = features[0].getEnvelope().getMinY();
	double tmaxy = features[0].getEnvelope().getMaxY();
	for (int i = 0; i < features.size(); i++)
	{
		if (features[i].getEnvelope().getMinX() < tminx)
			tminx = features[i].getEnvelope().getMinX();
		if (features[i].getEnvelope().getMaxX()>tmaxx)
			tmaxx = features[i].getEnvelope().getMaxX();
		if (features[i].getEnvelope().getMinY()<tminy)
			tminy = features[i].getEnvelope().getMinY();
		if (features[i].getEnvelope().getMaxY() > tmaxy)
			tmaxy = features[i].getEnvelope().getMaxY();
	}
	bbox =  Envelope(tminx, tmaxx, tminy, tmaxy);
	root = new QuadNode(bbox);
	for (int i = 0;i < features.size(); i++)
	{
		if (bbox.intersect(features[i].getEnvelope()))
		{
			root->add(features[i]);			
		}
	}

	if (root->getFeatureNum()>capacity)
	{
		root->split(capacity);
	}

	return true;
}

void QuadTree::countQuadNode(int& interiorNum, int& leafNum)
{
	interiorNum = 0;
	leafNum = 0;
	if (root)
		root->countNode(interiorNum, leafNum);
}

void QuadTree::countHeight(int &height)
{
	height = 0;
	if (root)
		height = root->countHeight(0);
}

void QuadTree::rangeQuery(Envelope& rect, vector<Feature>& features) 
{ 
	// Task 4.1
	// Write your code here
	root->rangeQuery(rect, features);
	int i = 0;
	return;
}

bool QuadTree::NNQuery(double x, double y, Feature& feature)
{
	if (!root || !(root->getEnvelope().contain(x, y)))
		return false;

	// Task 5.1
	// Write your code here
	QuadNode* leaf = root->pointInLeafNode(x, y);
	double minDist = 1000000;
	
	for (int i = 0; i < leaf->getFeatureNum(); i++)
	{
		Feature tfeature = leaf->getFeature(i);
		
		if ( tfeature.calcDist(x,y)<minDist)
		{
			minDist = tfeature.calcDist(x, y);
		}
	}

// 	const Envelope& envelope = root->getEnvelope();
// 	double minDist = max(envelope.getWidth(), envelope.getHeight());
	if (minDist == 1000000)
	{
		minDist = max(leaf->getEnvelope().getWidth(), leaf->getEnvelope().getHeight()) * 2;
	}
	
	// Write your code here
	Envelope tEnvelope(x - minDist, x + minDist, y - minDist, y + minDist);
	vector<Feature> features;
	features.clear();
	rangeQuery(tEnvelope, features);
	feature = features[0];
	for (int i = 0; i < features.size(); i++)
	{
		if (features[i].calcDist(x, y) < minDist)
		{
			minDist = features[i].calcDist(x, y);
			feature = features[i];
		}

	}

	return true;
}

void QuadTree::draw()
{
	if (root)
		root->draw();
}