#ifndef COMMON_H_INCLUDED
#define COMMON_H_INCLUDED

#include "QuadTree.h"

#define KCLUSTER 5

#define Default 0
#define NN 1
#define RANGE 2
#define CLUSTER 3
#define QUADTREE 4
#define TEST1 1
#define TEST2 2
#define TEST3 3
#define TEST4 4
#define TEST5 5
#define TEST6 6

extern QuadTree qtree;
extern vector<Feature> features;
extern double X0, X1, Y0, Y1;
#endif