#ifndef HURISTIC_H
#define HURISTIC_H

#include <vector>
#include <cmath>          // for sqrt and pow
#include "Board_config.h" // Added this include
using namespace std;

class Huristic
{

private:
    int k;
    vector<vector<int>> targetboard;

public:
    Huristic(int k)
    {
        this->k = k;
        targetboard.resize(k, vector<int>(k));
        int num = 1;
        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k; j++)
            {
                if (num == k * k)
                    targetboard[i][j] = 0;
                else
                    targetboard[i][j] = num++;
            }
        }
    }

    static int calculateHammingDistance(Board_config &board)
    {
        int hammingDistance = 0;
        vector<vector<int>> currentBoard = board.getBoard();
        int k = board.k;

        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k; j++)
            {
                int expectedValue = (i * k + j + 1) % (k * k); // Calculate the expected value at position i,j
                if (currentBoard[i][j] != expectedValue && currentBoard[i][j] != 0)
                {
                    hammingDistance++;
                }
            }
        }
        return hammingDistance;
    }

    static int calculateManhattanDistance(Board_config &board)
    {
        int manhattanDistance = 0;
        vector<vector<int>> currentBoard = board.getBoard();
        int k = board.k;

        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k; j++)
            {
                if (currentBoard[i][j] != 0) // Skip the blank tile
                {
                    int targetRow = (currentBoard[i][j] - 1) / k;
                    int targetCol = (currentBoard[i][j] - 1) % k;
                    manhattanDistance += abs(i - targetRow) + abs(j - targetCol);
                }
            }
        }
        return manhattanDistance;
    }

    static int calculateEuclideanDistance(Board_config &board)
    {
        int euclideanDistance = 0;
        vector<vector<int>> currentBoard = board.getBoard();
        int k = board.k;

        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k; j++)
            {
                if (currentBoard[i][j] != 0) // Skip the blank tile
                {
                    int targetRow = (currentBoard[i][j] - 1) / k;
                    int targetCol = (currentBoard[i][j] - 1) % k;
                    euclideanDistance += sqrt(pow(i - targetRow, 2) + pow(j - targetCol, 2));
                }
            }
        }
        return euclideanDistance;
    }

    static int calculateLinearConflict(Board_config &board)
    {
        int linearConflict = calculateManhattanDistance(board);
        vector<vector<int>> currentBoard = board.getBoard();
        int k = board.k;

        // Check for conflicts in rows
        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k - 1; j++)
            {
                for (int jNext = j + 1; jNext < k; jNext++)
                {
                    // Skip blank tiles
                    if (currentBoard[i][j] != 0 && currentBoard[i][jNext] != 0)
                    {
                        int targetRowJ = (currentBoard[i][j] - 1) / k;
                        int targetRowJNext = (currentBoard[i][jNext] - 1) / k;

                        // If both tiles belong in the current row and the one on the right should be on the left
                        if (targetRowJ == targetRowJNext && targetRowJ == i &&
                            (currentBoard[i][j] - 1) % k > (currentBoard[i][jNext] - 1) % k)
                        {
                            linearConflict += 2;
                        }
                    }
                }
            }
        }

        // Check for conflicts in columns
        for (int j = 0; j < k; j++)
        {
            for (int i = 0; i < k - 1; i++)
            {
                for (int iNext = i + 1; iNext < k; iNext++)
                {
                    // Skip blank tiles
                    if (currentBoard[i][j] != 0 && currentBoard[iNext][j] != 0)
                    {
                        int targetColI = (currentBoard[i][j] - 1) % k;
                        int targetColINext = (currentBoard[iNext][j] - 1) % k;

                        // If both tiles belong in the current column and the one on the bottom should be on the top
                        if (targetColI == targetColINext && targetColI == j &&
                            (currentBoard[i][j] - 1) / k > (currentBoard[iNext][j] - 1) / k)
                        {
                            linearConflict += 2;
                        }
                    }
                }
            }
        }

        return linearConflict;
    }
};

#endif // HURISTIC_H
