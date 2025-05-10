#ifndef SOLVER_H
#define SOLVER_H

#include <queue>
#include <vector>
#include <functional>
#include <unordered_set>
#include <iostream>
#include <stack>
#include <unordered_map>
#include "Node.h"
#include "Board_config.h"

using namespace std;

class Solver
{
public:
    int huristic_type;

    Solver(int huristic_type)
    {
        this->huristic_type = huristic_type;
    }

    void Solve(Node &start_node, Node &goal_node)
    {
        // Use a custom comparator for the priority queue
        auto comparator = [&goal_node, this](const Node &a, const Node &b)
        {
            return a.get_function_cost(this->huristic_type, const_cast<Board_config &>(goal_node.board)) >
                b.get_function_cost(this->huristic_type, const_cast<Board_config &>(goal_node.board));
        };

        // Create the priority queue with the custom comparator
        priority_queue<Node, vector<Node>, decltype(comparator)> open_list(comparator);
        unordered_set<string> closed_list;

        // Create a map to store parent pointers for reconstructing the path
        unordered_map<string, pair<Node, string>> parent_map;

        open_list.push(start_node);

        int explored = 1; // Count the initial state
        int expanded = 0;

        while (!open_list.empty())
        {
            Node current_node = open_list.top();
            // current_node.printNode();
            open_list.pop();
            expanded++; // Increment expanded count when a node is taken from open list

            string current_state = current_node.board.toString();

            if (current_node.board.toString() == goal_node.board.toString())
            {
                // Solution found
                cout << "Solution found!" << endl;

                // Print statistics about the search
                cout << "Number of Explored Nodes = " << explored << endl;
                cout << "Number of Expanded Nodes = " << expanded << endl;

                // Reconstruct the solution path and count steps
                int steps = 0;
                stack<Node> path;

                string state = current_state;
                while (state != start_node.board.toString())
                {
                    path.push(parent_map[state].first);
                    state = parent_map[state].second; // Get the parent state
                    steps++;
                }

                cout << "Number of steps: " << steps << endl;
                cout << "Solution path:" << endl;

                cout << "Initial state:" << endl;
                start_node.printNode();
                cout << endl;

                int step_count = 1;
                while (!path.empty())
                {
                    cout << "Step " << step_count++ << ":" << endl;
                    path.top().printNode();
                    cout << endl;
                    path.pop();
                }

                return;
            }

            closed_list.insert(current_state);

            vector<Node> neighbours = current_node.getNeighbourNodes();
            for (Node &neighbour : neighbours)
            {
                string neighbour_state = neighbour.board.toString();
                if (closed_list.find(neighbour_state) == closed_list.end())
                {
                    // Store the parent information before pushing to open list
                    parent_map[neighbour_state] = make_pair(neighbour, current_state);

                    open_list.push(neighbour);
                    explored++; // Increment explored count when a node is added to open list
                }
            }
        }

        cout << "No solution found." << endl;
        cout << "Number of Explored Nodes = " << explored << endl;
        cout << "Number of Expanded Nodes = " << expanded << endl;
    }
};

#endif // SOLVER_H
