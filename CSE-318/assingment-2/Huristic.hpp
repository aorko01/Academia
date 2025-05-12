#ifndef RANDOMIZED_HURISTIC_HPP
#define RANDOMIZED_HURISTIC_HPP

#include <vector>
#include <cstdlib>
#include <ctime>
#include <limits>
#include <random>
#include <unordered_set>
#include <unordered_map>
#include <climits>
#include "Graph.hpp"

using namespace std;

class Huristic
{
private:
    // Helper function to calculate sum of weights between a vertex and a set of vertices
    double sumWeightsBetween(const Graph &graph, int vertex, const unordered_set<int>& vertexSet)
    {
        double totalWeight = 0.0;
        
        for (const auto &edge : graph.getAdjList()[vertex])
        {
            int adjVertex = edge.first;
            int weight = edge.second;
            
            if (vertexSet.count(adjVertex) > 0)
            {
                totalWeight += weight;
            }
        }
        
        return totalWeight;
    }

public:
    // Find partitions of vertices that maximize the cut weight
    pair<vector<int>, vector<int>> greedyMaxCut(const Graph &graph)
    {
        int n = graph.getNumVertices();
        vector<int> X, Y;                    // The two partitions
        vector<bool> assigned(n + 1, false); // Track assigned vertices

        // Find edge with maximum weight
        int maxU = -1, maxV = -1;
        int maxWeight = -1;

        for (int u = 1; u <= n; u++)
        {
            for (const auto &edge : graph.getAdjList()[u])
            {
                int v = edge.first;
                int w = edge.second;

                if (w > maxWeight && u < v) // Check u < v to avoid counting edges twice
                {
                    maxWeight = w;
                    maxU = u;
                    maxV = v;
                }
            }
        }

        // Initialize partitions with the endpoints of the max weight edge
        X.push_back(maxU);
        Y.push_back(maxV);
        assigned[maxU] = true;
        assigned[maxV] = true;

        // Process the remaining vertices
        for (int z = 1; z <= n; z++)
        {
            if (assigned[z])
                continue; // Skip already assigned vertices

            // Compute weight if z is in X
            double weightX = 0.0;
            for (int y : Y)
            {
                // Check if there's an edge between z and y
                for (const auto &edge : graph.getAdjList()[z])
                {
                    if (edge.first == y)
                    {
                        weightX += edge.second;
                        break;
                    }
                }
            }

            // Compute weight if z is in Y
            double weightY = 0.0;
            for (int x : X)
            {
                // Check if there's an edge between z and x
                for (const auto &edge : graph.getAdjList()[z])
                {
                    if (edge.first == x)
                    {
                        weightY += edge.second;
                        break;
                    }
                }
            }

            // Assign z to the partition that maximizes the cut weight
            if (weightX > weightY)
            {
                X.push_back(z);
            }
            else
            {
                Y.push_back(z);
            }
            assigned[z] = true;
        }

        return {X, Y};
    }

    // Calculate the cut weight given two partitions
    double calculateCutWeight(const Graph &graph, const vector<int> &X, const vector<int> &Y)
    {
        double cutWeight = 0.0;

        // Create sets for faster lookup
        vector<bool> inX(graph.getNumVertices() + 1, false);
        for (int v : X)
            inX[v] = true;

        // Calculate the total weight of edges crossing the cut
        for (int u = 1; u <= graph.getNumVertices(); u++)
        {
            for (const auto &edge : graph.getAdjList()[u])
            {
                int v = edge.first;
                int w = edge.second;

                if ((inX[u] && !inX[v]) || (!inX[u] && inX[v]))
                {
                    cutWeight += w;
                }
            }
        }

        return cutWeight / 2; // Divide by 2 as each edge is counted twice
    }

    // Function to run the greedy algorithm and return the cut weight
    double greedyMaxCutWeight(const Graph &graph)
    {
        auto [X, Y] = greedyMaxCut(graph);
        return calculateCutWeight(graph, X, Y);
    }

    // Semi-greedy approach to Max-Cut problem
    pair<vector<int>, vector<int>> semiGreedyMaxCut(const Graph &graph, double alpha)
    {
        int n = graph.getNumVertices();
        
        unordered_set<int> X;         // First partition
        unordered_set<int> Y;         // Second partition
        unordered_set<int> assigned;  // Track assigned vertices
        
        // Find edge with maximum weight to initialize partitions
        int maxU = -1, maxV = -1;
        int maxWeight = -1;

        for (int u = 1; u <= n; u++)
        {
            for (const auto &edge : graph.getAdjList()[u])
            {
                int v = edge.first;
                int w = edge.second;

                if (w > maxWeight && u < v) // Check u < v to avoid counting edges twice
                {
                    maxWeight = w;
                    maxU = u;
                    maxV = v;
                }
            }
        }
        
        // Initialize partitions with the endpoints of the max weight edge
        X.insert(maxU);
        Y.insert(maxV);
        
        assigned.insert(maxU);
        assigned.insert(maxV);
        
        // Process the remaining vertices
        while (assigned.size() < n)
        {
            vector<int> candidates;
            
            unordered_map<int, double> sigmaX;   // Weight between vertex and X
            unordered_map<int, double> sigmaY;   // Weight between vertex and Y
            unordered_map<int, double> greedyScore; // Max of the two weights
            
            double wmin = numeric_limits<double>::max();
            double wmax = numeric_limits<double>::lowest();
            
            // Calculate scores for each unassigned vertex
            for (int j = 1; j <= n; j++)
            {
                if (assigned.count(j) > 0)
                {
                    continue;
                }
                
                double sX = sumWeightsBetween(graph, j, Y);  // Weight to Y partition
                double sY = sumWeightsBetween(graph, j, X);  // Weight to X partition
                double gval = max(sX, sY);
                
                sigmaX[j] = sX;
                sigmaY[j] = sY;
                greedyScore[j] = gval;
                
                wmin = min(wmin, gval);
                wmax = max(wmax, gval);
                
                candidates.push_back(j);
            }
            
            // Calculate threshold for Restricted Candidate List
            double mu = wmin + alpha * (wmax - wmin);
            
            // Build the Restricted Candidate List (RCL)
            vector<int> RCL;
            for (auto v : candidates)
            {
                if (greedyScore[v] >= mu)
                {
                    RCL.push_back(v);
                }
            }
            
            // Randomly select a vertex from RCL
            mt19937 gen(random_device{}());
            uniform_int_distribution<> dis(0, RCL.size() - 1);
            int chosen = RCL[dis(gen)];
            
            // Assign the chosen vertex to the appropriate partition
            if (sigmaX[chosen] > sigmaY[chosen])
            {
                X.insert(chosen);
            }
            else
            {
                Y.insert(chosen);
            }
            
            assigned.insert(chosen);
        }
        
        // Convert the sets to vectors for the return value
        vector<int> vectorX(X.begin(), X.end());
        vector<int> vectorY(Y.begin(), Y.end());
        
        return {vectorX, vectorY};
    }
    
    // Function to run the semi-greedy algorithm and return the cut weight
    double semiGreedyMaxCutWeight(const Graph &graph, double alpha)
    {
        auto [X, Y] = semiGreedyMaxCut(graph, alpha);
        return calculateCutWeight(graph, X, Y);
    }

    double randomizedMaxCut(const Graph &graph, int iterations)
    {
        // Initialize random number generator with better randomization
        mt19937 gen(random_device{}());
        uniform_real_distribution<> dis(0.0, 1.0);

        double totalCutWeight = 0.0;

        for (int i = 0; i < iterations; i++)
        {
            // Initialize partitions
            unordered_set<int> X;
            unordered_set<int> Y;

            // Randomly assign each vertex to X or Y with equal probability
            for (int v = 1; v <= graph.getNumVertices(); ++v)
            {
                if (dis(gen) >= 0.5)
                {
                    X.insert(v);
                }
                else
                {
                    Y.insert(v);
                }
            }

            // Calculate cut weight for this random partition
            double cutWeight = 0.0;

            for (int u = 1; u <= graph.getNumVertices(); u++)
            {
                for (const auto &edge : graph.getAdjList()[u])
                {
                    int v = edge.first;
                    int w = edge.second;

                    // If one vertex is in X and the other is in Y
                    if ((X.count(u) && Y.count(v)) || (Y.count(u) && X.count(v)))
                    {
                        cutWeight += w;
                    }
                }
            }

            cutWeight /= 2; // Divide by 2 because each edge is counted twice
            totalCutWeight += cutWeight;
        }

        // Return the average cut weight across all iterations
        double averageCutWeight = totalCutWeight / iterations;
        return averageCutWeight;
    }
};

#endif