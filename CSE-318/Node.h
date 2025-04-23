#ifndef NODE_H
#define NODE_H

#include <vector>
#include <iostream>
#include "Board_config.h"
#include "Huristic.h"

using namespace std;

class Node
{
public:
    Board_config board;
    int current_cost;
    Node *parent;

    // Adding a default constructor
    Node() : current_cost(0), parent(nullptr) {}

    Node(Board_config &board, int current_cost, Node *parent)
    {
        this->board = board;
        this->current_cost = current_cost;
        this->parent = parent;
    }

    int get_function_cost(int heuristic_type, Board_config &target_board) const
    {
        int heuristic_cost = 0;
        if (heuristic_type == 1)
        {
            heuristic_cost = Huristic::calculateHammingDistance(const_cast<Board_config &>(board));
        }
        else if (heuristic_type == 2)
        {
            heuristic_cost = Huristic::calculateManhattanDistance(const_cast<Board_config &>(board));
        }
        else if (heuristic_type == 3)
        {
            heuristic_cost = Huristic::calculateEuclideanDistance(const_cast<Board_config &>(board));
        }
        else
        {
            heuristic_cost = Huristic::calculateLinearConflict(const_cast<Board_config &>(board));
        }
        return current_cost + heuristic_cost;
    }

    vector<Node> getNeighbourNodes()
    {
        vector<Node> neighbours;
        Board_config *parent_board = nullptr;
        if (parent != nullptr)
        {
            parent_board = &(parent->board);
        }
        vector<Board_config> neighbour_boards = board.getNeighbours(parent_board);
        for (auto &neighbour_board : neighbour_boards)
        {
            neighbours.push_back(Node(neighbour_board, current_cost + 1, this));
        }
        return neighbours;
    }
    void printNode() const
    {
        for (int i = 0; i < board.k; i++)
        {
            for (int j = 0; j < board.k; j++)
            {
                cout << board.board[i][j] << " ";
            }
            cout << endl;
        }
    }
};

#endif // NODE_H
