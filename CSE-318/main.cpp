#include<bits/stdc++.h>
#include"Solver.h"
using namespace std;

int main()
{
    int k;
    cin>>k;
    vector<vector<int>> input_board(k, vector<int>(k));
    for (int i = 0; i < k; i++)
    {
        for (int j = 0; j < k; j++)
        {
            cin>>input_board[i][j];
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
    Board_config start_board(k, input_board);
    Board_config goal_board_config(k, goal_board);
    int huristic_type;
    cin>>huristic_type;
    Solver solver(huristic_type);
    if (start_board.isSolvable())
    {
        solver.Solve(start_board, goal_board_config);
    }
    else
    {
        cout << "No solution exists for the given board configuration." << endl;
    }
    return 0;
}
