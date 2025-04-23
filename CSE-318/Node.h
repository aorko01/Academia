#include <vector>
#include<iostream>
#include "Board_config.h"
#include "Huristic.h"

using namespace std;

class Node
{
public:
    Board_config board;
    int current_cost;
    Node *parent;

    Node(Board_config &board, int current_cost, Node *parent)
    {
        this->board = board;
        this->current_cost = current_cost;
        this->parent = parent;
    }

    int get_function_cost(int heuristic_type, Board_config &target_board)
    {
        int heuristic_cost = 0;
        if (heuristic_type == 1)
        {
            heuristic_cost = Huristic::calculateHammingDistance(board);
        }
        else if (heuristic_type == 2)
        {
            heuristic_cost = Huristic::calculateManhattanDistance(board);
        }
        else if (heuristic_type == 3)
        {
            heuristic_cost = Huristic::calculateEuclideanDistance(board);
        }
        else
        {
            heuristic_cost = Huristic::calculateLinearConflict(board);
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
    void printNode()
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
