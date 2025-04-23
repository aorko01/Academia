#include <bits/stdc++.h>
#include "Solver.h"
#include "Board_config.h"
#include "Node.h"
#include "Huristic.h"

using namespace std;

int main()
{
    int k;
    cin >> k;
    vector<vector<int>> input_board(k, vector<int>(k));
    for (int i = 0; i < k; i++)
    {
        for (int j = 0; j < k; j++)
        {
            cin >> input_board[i][j];
        }
    }
    vector<vector<int>> goal_board(k, vector<int>(k));
    int num = 1;
    for (int i = 0; i < k; i++)
    {
        for (int j = 0; j < k; j++)
        {
            if (num == k * k)
                goal_board[i][j] = 0;
            else
                goal_board[i][j] = num++;
        }
    }
    Board_config goal(k, goal_board);
    Board_config start(k, input_board);
    Node start_node(start, 0, nullptr);
    Node goal_node(goal, 0, nullptr);

    // Choose heuristic type (1: Hamming, 2: Manhattan, 3: Euclidean, 4: Linear Conflict)
    int heuristic_type;
    cout << "Enter heuristic type (1-4): ";
    cin >> heuristic_type;

    // Check if the puzzle is solvable
    if (!start.isSolvable())
    {
        cout << "The puzzle is not solvable." << endl;
        return 0;
    }

    Solver solver(heuristic_type);
    solver.Solve(start_node, goal_node);

    return 0;
}
