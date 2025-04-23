#include <queue>
#include <vector>
#include <functional>
#include <unordered_set>
#include <iostream>
#include "Huristic.h"
#include "Node.h"
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
        priority_queue<Node, vector<Node>, function<bool(Node, Node)>> open_list(
            [&goal_node, this](Node a, Node b)
            {
                return a.get_function_cost(this->huristic_type, goal_node.board) >
                       b.get_function_cost(this->huristic_type, goal_node.board);
            });
        unordered_set<string> closed_list;

        open_list.push(start_node);

        int explored = 1; // Count the initial state
        int expanded = 0;

        while (!open_list.empty())
        {
            Node current_node = open_list.top();
            current_node.printNode();
            open_list.pop();
            expanded++; // Increment expanded count when a node is taken from open list

            if (current_node.board == goal_node.board)
            {
                // Solution found
                cout << "Solution found!" << endl;

                // Print statistics about the search
                cout << "Number of Explored Nodes = " << explored << endl;
                cout << "Number of Expanded Nodes = " << expanded << endl;

                // Reconstruct the solution path and count steps
                int steps = 0;
                Node *node_ptr = &current_node;
                // Would need to implement a way to store/track the path
                // In the current implementation, we can't do this directly
                // since current_node is a copy, not the actual node in memory

                return;
            }

            closed_list.insert(current_node.board.toString());

            vector<Node> neighbours = current_node.getNeighbourNodes();
            for (Node &neighbour : neighbours)
            {
                if (closed_list.find(neighbour.board.toString()) == closed_list.end())
                {
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
