#ifndef RANDOMIZED_HURISTIC_HPP
#define RANDOMIZED_HURISTIC_HPP

#include <vector>
#include <cstdlib>
#include <ctime>
#include <limits>
#include "Graph.hpp"

using namespace std;

class Huristic
{
public:
    // Find partitions of vertices that maximize the cut weight
    pair<vector<int>, vector<int>> greedyMaxCut(const Graph &graph)
    {
        int n = graph.getNumVertices();
        vector<int> X, Y;  // The two partitions
        vector<bool> assigned(n + 1, false);  // Track assigned vertices
        
        // Find edge with maximum weight
        int maxU = -1, maxV = -1;
        int maxWeight = -1;
        
        for (int u = 1; u <= n; u++)
        {
            for (const auto &edge : graph.getAdjList()[u])
            {
                int v = edge.first;
                int w = edge.second;
                
                if (w > maxWeight && u < v)  // Check u < v to avoid counting edges twice
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
            if (assigned[z]) continue;  // Skip already assigned vertices
            
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
    
    // Semi-greedy version of MAX-CUT with RCL (Restricted Candidate List)
    pair<vector<int>, vector<int>> semiGreedyMaxCut(const Graph &graph, double alpha = 0.5, int runs = 10)
    {
        int n = graph.getNumVertices();
        vector<int> bestX, bestY;
        double bestCutWeight = -1;
        
        for (int run = 0; run < runs; run++) {
            vector<int> X, Y;  // The two partitions
            vector<bool> assigned(n + 1, false);  // Track assigned vertices
            
            // Find edge with maximum weight for initial partition
            int maxU = -1, maxV = -1;
            int maxWeight = -1;
            
            for (int u = 1; u <= n; u++) {
                for (const auto &edge : graph.getAdjList()[u]) {
                    int v = edge.first;
                    int w = edge.second;
                    
                    if (w > maxWeight && u < v) {
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
            
            // Process the remaining vertices using semi-greedy approach
            while (true) {
                // Get candidate list - all unassigned vertices
                vector<int> candidates;
                for (int v = 1; v <= n; v++) {
                    if (!assigned[v]) {
                        candidates.push_back(v);
                    }
                }
                
                // If no more candidates, we're done
                if (candidates.empty()) {
                    break;
                }
                
                // Calculate sigma values for each candidate
                vector<pair<int, pair<double, double>>> candidateValues; // (vertex, (sigmaX, sigmaY))
                double minValue = std::numeric_limits<double>::max();
                double maxValue = -std::numeric_limits<double>::max();
                
                for (int v : candidates) {
                    // Calculate sigmaX(v) - sum of weights to vertices in X
                    double sigmaX = 0.0;
                    for (int x : X) {
                        for (const auto &edge : graph.getAdjList()[v]) {
                            if (edge.first == x) {
                                sigmaX += edge.second;
                                break;
                            }
                        }
                    }
                    
                    // Calculate sigmaY(v) - sum of weights to vertices in Y
                    double sigmaY = 0.0;
                    for (int y : Y) {
                        for (const auto &edge : graph.getAdjList()[v]) {
                            if (edge.first == y) {
                                sigmaY += edge.second;
                                break;
                            }
                        }
                    }
                    
                    // Store the values and update min/max
                    double greedyValue = max(sigmaX, sigmaY);
                    candidateValues.push_back({v, {sigmaX, sigmaY}});
                    
                    minValue = min(minValue, greedyValue);
                    maxValue = max(maxValue, greedyValue);
                }
                
                // Calculate cutoff value for RCL using equation (1)
                double mu = minValue + alpha * (maxValue - minValue);
                
                // Create RCL from candidates meeting cutoff value
                vector<pair<int, pair<double, double>>> rcl;
                for (const auto &candidate : candidateValues) {
                    int v = candidate.first;
                    double sigmaX = candidate.second.first;
                    double sigmaY = candidate.second.second;
                    double greedyValue = max(sigmaX, sigmaY);
                    
                    if (greedyValue >= mu) {
                        rcl.push_back(candidate);
                    }
                }
                
                // Randomly select a candidate from RCL
                if (!rcl.empty()) {
                    int randomIndex = rand() % rcl.size();
                    int selectedVertex = rcl[randomIndex].first;
                    double selectedSigmaX = rcl[randomIndex].second.first;
                    double selectedSigmaY = rcl[randomIndex].second.second;
                    
                    // Assign the selected vertex to X or Y based on greedy criterion
                    if (selectedSigmaX > selectedSigmaY) {
                        X.push_back(selectedVertex);
                    } else {
                        Y.push_back(selectedVertex);
                    }
                    assigned[selectedVertex] = true;
                }
            }
            
            // Calculate cut weight for this run's solution
            double cutWeight = calculateCutWeight(graph, X, Y);
            
            // Update best solution if this one is better
            if (cutWeight > bestCutWeight) {
                bestCutWeight = cutWeight;
                bestX = X;
                bestY = Y;
            }
        }
        
        return {bestX, bestY};
    }
    
    // Function to run the semi-greedy algorithm and return the cut weight
    double semiGreedyMaxCutWeight(const Graph &graph, double alpha = 0.5, int runs = 10)
    {
        auto [X, Y] = semiGreedyMaxCut(graph, alpha, runs);
        return calculateCutWeight(graph, X, Y);
    }
    
    // Calculate the cut weight given two partitions
    double calculateCutWeight(const Graph &graph, const vector<int> &X, const vector<int> &Y)
    {
        double cutWeight = 0.0;
        
        // Create sets for faster lookup
        vector<bool> inX(graph.getNumVertices() + 1, false);
        for (int v : X) inX[v] = true;
        
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

    double randomizedMaxCut(const Graph &graph, int n)
    {
        double totalCutWeight = 0.0;
        for (int i = 1; i <= n; i++)
        {
            vector<bool> inX(graph.getNumVertices() + 1, false);

            for (int v = 1; v <= graph.getNumVertices(); v++)
            {
                if (rand() % 2 == 0)
                {
                    inX[v] = true;
                }
            }

            double cutWeight = 0.0;
            for (int u = 1; u <= graph.getNumVertices(); u++)
            {
                for (const auto &edge : graph.getAdjList()[u])
                {
                    int v = edge.first;
                    int w = edge.second;

                    if (inX[u] != inX[v])
                    {
                        cutWeight += w;
                    }
                }
            }
            
            cutWeight /= 2;

            totalCutWeight += cutWeight;
        }

        double averageCutWeight = totalCutWeight / n;
        return averageCutWeight;
    }
};

#endif
