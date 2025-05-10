#ifndef GRAPH_HPP
#define GRAPH_HPP
#include <vector>
using namespace std;

class Graph
{
    int n, m;
    string name;
    vector<pair<pair<int, int>, int>> edges;
    vector<vector<pair<int, int>>> adj;

public:
    Graph(int n, int m, string name)
    {
        this->n = n;
        this->m = m;
        this->name = name;
        edges.resize(m);

        adj.resize(n + 1);
    }
    void addEdge(int u, int v, int w)
    {
        edges.push_back({{u, v}, w});
        adj[u].push_back({v, w});
        adj[v].push_back({u, w});
    }

    // Get number of vertices
    int getNumVertices() const
    {
        return n;
    }

    // Get number of edges
    int getNumEdges() const
    {
        return m;
    }

    // Get adjacency list
    const vector<vector<pair<int, int>>> &getAdjList() const
    {
        return adj;
    }

    // Get graph name
    string getName() const
    {
        return name;
    }
};
#endif