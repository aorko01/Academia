#include<bits/stdc++.h>
using namespace std;

class Board_config {
    public:
    int k, n;
    vector<vector<int>> board;
    map<int, pair<int,int>> config;
    Board_config(int k, vector<vector<int>>& input_board) {
        this->k = k;
        this->n = k * k - 1;
        board.resize(k, vector<int>(k));
        
        for(int i = 0; i < k; i++) {
            for(int j = 0; j < k; j++) {
                board[i][j] = input_board[i][j];
                config[board[i][j]] = make_pair(i, j);
            }
        }
    }
    vector<vector<int>> getBoard() {
        return board;
    }
    
    int countInversions() {
        int count = 0;
        vector<int> arr;
        
        // Flatten the board into a 1D array, ignoring the blank (0)
        for(int i = 0; i < k; i++) {
            for(int j = 0; j < k; j++) {
                if(board[i][j] != 0) {
                    arr.push_back(board[i][j]);
                }
            }
        }
        
        for(int i = 0; i < arr.size(); i++) {
            for(int j = i + 1; j < arr.size(); j++) {
                if(arr[i] > arr[j]) {
                    count++;
                }
            }
        }
        return count;
    }

    bool isSolvable() {
        int inversions = countInversions();
        int blankRow = config[0].first; // Row of the blank tile (0)
        
        // If k is odd, the number of inversions must be even
        if(k % 2 == 1) {
            return inversions % 2 == 0;
        } else {
            // If k is even, check the row of the blank tile
            int blankRowFromBottom = n - blankRow;
            return (inversions + blankRowFromBottom) % 2 == 0;
        }
    }
};