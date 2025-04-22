#include<bits/stdc++.h>
#include "Board_config.h"
using namespace std;

class Huristic {

private:
    int k;
    vector<vector<int>> targetboard;
public:
    Huristic(int k)
    {
        this->k = k;
        targetboard.resize(k, vector<int>(k));
        int num = 1;
        for(int i = 0; i < k; i++)
        {
            for(int j = 0; j < k; j++)
            {
                if(num == k*k)
                    targetboard[i][j] = 0;
                else
                    targetboard[i][j] = num++;
            }
        }
    }
    int calculateHammingDistance(Board_config &board)
    {
        int hammingDistance = 0;
        for(int i = 0; i < k; i++)
        {
            for(int j = 0; j < k; j++)
            {
                if(board[i][j] != targetboard[i][j] && board[i][j] != 0)
                {
                    hammingDistance++;
                }
            }
        }
        return hammingDistance;
    }
    int calculateManhattanDistance(Board_config &board)
    {
        int manhattanDistance = 0;
        for(int i = 0; i < k; i++)
        {
            for(int j = 0; j < k; j++)
            {
                if(board[i][j] != targetboard[i][j] && board[i][j] != 0)
                {
                    int targetRow = (board[i][j] - 1) / k;
                    int targetCol = (board[i][j] - 1) % k;
                    manhattanDistance += abs(i - targetRow) + abs(j - targetCol);
                }
            }
        }
        return manhattanDistance;
    }
    int calculateEuclideanDistance(Board_config &board)
    {
        int euclideanDistance = 0;
        for(int i = 0; i < k; i++)
        {
            for(int j = 0; j < k; j++)
            {
                if(board[i][j] != targetboard[i][j] && board[i][j] != 0)
                {
                    int targetRow = (board[i][j] - 1) / k;
                    int targetCol = (board[i][j] - 1) % k;
                    euclideanDistance += sqrt(pow(i - targetRow, 2) + pow(j - targetCol, 2));
                }
            }
        }
        return euclideanDistance;
    }
    int calculateLinearConflict(Board_config &board)
    {
        int linearConflict = 0;
        for(int i = 0; i < k; i++)
        {
            for(int j = 0; j < k; j++)
            {
                if(board[i][j] != targetboard[i][j] && board[i][j] != 0)
                {
                    int targetRow = (board[i][j] - 1) / k;
                    int targetCol = (board[i][j] - 1) % k;
                    if(targetRow == i)
                    {
                        linearConflict += abs(j - targetCol);
                    }
                }
            }
        }
        return linearConflict;
    }
}
