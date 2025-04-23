#include <bits/stdc++.h>
using namespace std;

class Board_config
{
public:
    int k, n;
    vector<vector<int>> board;
    map<int, pair<int, int>> config;
    Board_config(int k, vector<vector<int>> &input_board)
    {
        this->k = k;
        this->n = k * k - 1;
        board.resize(k, vector<int>(k));

        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k; j++)
            {
                board[i][j] = input_board[i][j];
                config[board[i][j]] = make_pair(i, j);
            }
        }
    }
    vector<vector<int>> getBoard()
    {
        return board;
    }

    vector<Board_config> getNeighbours(Board_config *parent_node = nullptr)
    {
        vector<Board_config> neighbours;
        int blankRow = config[0].first;
        int blankCol = config[0].second;
        vector<pair<int, int>> directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};
        for (auto dir : directions)
        {
            int newRow = blankRow + dir.first;
            int newCol = blankCol + dir.second;
            if (newRow >= 0 && newRow < k && newCol >= 0 && newCol < k)
            {
                vector<vector<int>> newBoard = board;
                swap(newBoard[blankRow][blankCol], newBoard[newRow][newCol]);
                Board_config newConfig(k, newBoard);

                // Only add the neighbor if it's different from the parent
                if (parent_node == nullptr || newConfig.board != parent_node->board)
                {
                    neighbours.push_back(newConfig);
                }
            }
        }
        return neighbours;
    }

    int countInversions()
    {
        int count = 0;
        vector<int> arr;

        // Flatten the board into a 1D array, ignoring the blank (0)
        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k; j++)
            {
                if (board[i][j] != 0)
                {
                    arr.push_back(board[i][j]);
                }
            }
        }

        for (int i = 0; i < arr.size(); i++)
        {
            for (int j = i + 1; j < arr.size(); j++)
            {
                if (arr[i] > arr[j])
                {
                    count++;
                }
            }
        }
        return count;
    }

    bool isSolvable()
    {
        int inversions = countInversions();
        int blankRow = config[0].first; // Row of the blank tile (0)

        // If k is odd, the number of inversions must be even
        if (k % 2 == 1)
        {
            return inversions % 2 == 0;
        }
        else
        {
            // If k is even, check the row of the blank tile
            int blankRowFromBottom = n - blankRow;
            return (inversions + blankRowFromBottom) % 2 == 0;
        }
    }

    // Convert board configuration to string representation
    string toString() const
    {
        string result = "";
        for (int i = 0; i < k; i++)
        {
            for (int j = 0; j < k; j++)
            {
                result += to_string(board[i][j]);
                if (j < k - 1 || i < k - 1)
                    result += ",";
            }
        }
        return result;
    }
};