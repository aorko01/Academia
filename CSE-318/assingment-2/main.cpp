#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <chrono>
#include <iomanip>
#include <unordered_set>
#include "Graph.hpp"
#include "Huristic.hpp"
#include "Search.hpp"

using namespace std;
using namespace chrono;

// Function to read a graph from a file
Graph readGraphFromFile(const string &filePath)
{
    ifstream file(filePath);
    if (!file.is_open())
    {
        cerr << "Error: Unable to open file " << filePath << endl;
        exit(1);
    }

    int n, m;
    file >> n >> m;

    Graph graph(n, m, filePath);

    for (int i = 0; i < m; i++)
    {
        int u, v, w;
        file >> u >> v >> w;
        graph.addEdge(u, v, w);
    }

    file.close();
    return graph;
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        cout << "Usage: " << argv[0] << " <input_file_path> [-v] [-i <iterations>]" << endl;
        cout << "Or: " << argv[0] << " all [-v] [-i <iterations>]" << endl;
        cout << "Options:" << endl;
        cout << "  -v               Verbose output with execution times" << endl;
        cout << "  -i <iterations>  Number of iterations for GRASP (default: 10)" << endl;
        return 1;
    }

    string input = argv[1];
    vector<string> files;
    
    // Default values
    int graspIterations = 10;
    bool verboseMode = false;
    
    // Parse command line arguments
    for (int i = 2; i < argc; i++) {
        string arg = argv[i];
        if (arg == "-v") {
            verboseMode = true;
        }
        else if (arg == "-i" && i + 1 < argc) {
            try {
                graspIterations = stoi(argv[i + 1]);
                i++; // Skip the next argument as we've processed it
            } catch (const exception& e) {
                cerr << "Invalid number of iterations: " << argv[i + 1] << endl;
                return 1;
            }
        }
    }

    if (input == "all")
    {
        // Process all files in the set1 directory
        for (int i = 1; i <= 54; i++)
        {
            files.push_back("set1/g" + to_string(i) + ".rud");
        }
    }
    else
    {
        // Process a single file
        files.push_back(input);
    }

    Huristic heuristic;

    cout << setw(10) << "File" << setw(15) << "Greedy" << setw(15) << "SemiGreedy"
         << setw(15) << "Randomized" << setw(15) << "LocalSearch" << setw(15) << "GRASP" 
         << setw(15) << "LS Iters" << setw(15) << "GRASP Iters" << endl;
    cout << string(115, '-') << endl;

    for (const auto &filePath : files)
    {
        try
        {
            // Extract file name from path
            string fileName = filePath;
            size_t lastSlash = fileName.find_last_of("/\\");
            if (lastSlash != string::npos)
            {
                fileName = fileName.substr(lastSlash + 1);
            }

            // Read graph from file
            Graph graph = readGraphFromFile(filePath);

            // Calculate max cut using different heuristics
            auto startGreedy = high_resolution_clock::now();
            double greedyMaxCut = heuristic.greedyMaxCutWeight(graph);
            auto endGreedy = high_resolution_clock::now();

            auto startSemiGreedy = high_resolution_clock::now();
            double semiGreedyMaxCut = heuristic.semiGreedyMaxCutWeight(graph, 0.5); // Using alpha = 0.5
            auto endSemiGreedy = high_resolution_clock::now();

            auto startRandomized = high_resolution_clock::now();
            double randomizedMaxCut = heuristic.randomizedMaxCut(graph, 100); // Using 100 iterations
            auto endRandomized = high_resolution_clock::now();

            // Run local search
            auto startLocalSearch = high_resolution_clock::now();

            // Create the Search object
            Search search(graph);

            // Use greedy solution as starting point for local search
            auto [greedyX, greedyY] = heuristic.greedyMaxCut(graph);

            // Convert vector partitions to unordered_sets for local search
            unordered_set<int> setX(greedyX.begin(), greedyX.end());
            unordered_set<int> setY(greedyY.begin(), greedyY.end());

            // Run local search from the greedy starting point
            auto [improvedX, improvedY, iterations] = search.localSearchMaxCut(setX, setY);

            // Calculate the max cut weight
            long long localSearchWeight = search.computeCutWeight(improvedX, improvedY);
            auto endLocalSearch = high_resolution_clock::now();

            // Run GRASP
            auto startGRASP = high_resolution_clock::now();
            auto [graspX, graspY, graspLocalIterations] = search.graspMaxCut(graph, graspIterations, 0.5); // User-defined iterations, alpha = 0.5
            long long graspWeight = search.computeCutWeight(graspX, graspY);
            auto endGRASP = high_resolution_clock::now();

            // Output results
            cout << setw(10) << fileName
                 << setw(15) << fixed << setprecision(2) << greedyMaxCut
                 << setw(15) << fixed << setprecision(2) << semiGreedyMaxCut
                 << setw(15) << fixed << setprecision(2) << randomizedMaxCut
                 << setw(15) << fixed << setprecision(2) << static_cast<double>(localSearchWeight)
                 << setw(15) << fixed << setprecision(2) << static_cast<double>(graspWeight)
                 << setw(15) << iterations
                 << setw(15) << graspLocalIterations
                 << endl;

            // Print execution times if verbose mode
            if (verboseMode)
            {
                cout << "  Execution times (ms):" << endl;
                cout << "  Greedy: " << duration_cast<milliseconds>(endGreedy - startGreedy).count() << endl;
                cout << "  SemiGreedy: " << duration_cast<milliseconds>(endSemiGreedy - startSemiGreedy).count() << endl;
                cout << "  Randomized: " << duration_cast<milliseconds>(endRandomized - startRandomized).count() << endl;
                cout << "  LocalSearch: " << duration_cast<milliseconds>(endLocalSearch - startLocalSearch).count()
                     << " (iterations: " << iterations << ")" << endl;
                cout << "  GRASP: " << duration_cast<milliseconds>(endGRASP - startGRASP).count()
                     << " (avg iterations: " << graspLocalIterations << ")" << endl;
                cout << endl;
            }
        }
        catch (const exception &e)
        {
            cerr << "Error processing file " << filePath << ": " << e.what() << endl;
        }
    }

    return 0;
}