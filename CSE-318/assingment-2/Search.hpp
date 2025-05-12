#ifndef SEARCH_HPP
#define SEARCH_HPP

#include "Graph.hpp"
#include "Huristic.hpp"
#include <unordered_set>
#include <tuple>
#include <climits>
#include <vector>

using namespace std;

class Search
{
private:
    Graph &graph;
    Huristic huristic;

public:
    Search(Graph &g) : graph(g), huristic() {}

    // Helper function to compute the cut weight between two partitions
    long long computeCutWeight(const unordered_set<int> &X, const unordered_set<int> &Y)
    {
        long long cutWeight = 0;

        for (int x : X)
        {
            const auto &neighbors = graph.getAdjList()[x];
            for (int y : Y)
            {
                for (const auto &edge : neighbors)
                {
                    if (edge.first == y)
                    {
                        cutWeight += edge.second;
                        break;
                    }
                }
            }
        }

        return cutWeight;
    }

    // Local search algorithm for Max-Cut problem
    tuple<unordered_set<int>, unordered_set<int>, int> localSearchMaxCut(
        unordered_set<int> X, unordered_set<int> Y)
    {
        bool improved = true;
        int iteration = 0;

        while (improved)
        {
            iteration++;
            improved = false;
            long long bestDelta = 0;
            int bestDeltavertex = -1;
            bool movefromX = false;

            for (int v = 1; v <= graph.getNumVertices(); ++v)
            {
                long long delta = 0;
                bool vInX = X.count(v);

                // Calculate the change in cut weight if we move vertex v
                for (const auto &edge : graph.getAdjList()[v])
                {
                    int u = edge.first;
                    int w = edge.second;
                    bool uInX = X.count(u);

                    if ((vInX && uInX) || (!vInX && !uInX))
                    {
                        // Moving v would make these vertices in different partitions
                        delta += w;
                    }
                    else
                    {
                        // Moving v would put these vertices in the same partition
                        delta -= w;
                    }
                }

                if (delta > bestDelta)
                {
                    bestDelta = delta;
                    bestDeltavertex = v;
                    movefromX = vInX;
                }
            }

            // Move the vertex if it improves the solution
            if (bestDelta > 0)
            {
                improved = true;
                if (movefromX)
                {
                    X.erase(bestDeltavertex);
                    Y.insert(bestDeltavertex);
                }
                else
                {
                    Y.erase(bestDeltavertex);
                    X.insert(bestDeltavertex);
                }
            }
        }

        return {X, Y, iteration};
    }

    // Find the best solution from multiple starting points

    // GRASP algorithm for Max-Cut problem
    tuple<unordered_set<int>, unordered_set<int>, int> graspMaxCut(Graph& g, int iterations, double alpha)
    {
        unordered_set<int> bestX;
        unordered_set<int> bestY;
        long long bestWeight = LLONG_MIN;
        int totalIterations = 0;
        Huristic localHuristic;

        for (int i = 0; i < iterations; i++)
        {
            // Get semi-greedy solution
            auto semiGreedyResult = localHuristic.semiGreedyMaxCut(g, alpha);
            
            // Convert vector<int> to unordered_set<int>
            unordered_set<int> X(semiGreedyResult.first.begin(), semiGreedyResult.first.end());
            unordered_set<int> Y(semiGreedyResult.second.begin(), semiGreedyResult.second.end());
            
            // Apply local search to improve the solution
            // We need to use a new Search instance with the passed graph
            Search tempSearch(g);
            auto [improvedX, improvedY, localIterations] = tempSearch.localSearchMaxCut(X, Y);
            totalIterations += localIterations;
            
            // Calculate cut weight - using a helper function in the graph class
            long long weight = 0;
            for (int x : improvedX) {
                for (const auto& edge : g.getAdjList()[x]) {
                    if (improvedY.count(edge.first)) {
                        weight += edge.second;
                    }
                }
            }
            
            // Update best solution if current one is better
            if (weight > bestWeight)
            {
                bestWeight = weight;
                bestX = improvedX;
                bestY = improvedY;
            }
        }

        return {bestX, bestY, totalIterations / iterations};
    }
};

#endif // SEARCH_HPP
