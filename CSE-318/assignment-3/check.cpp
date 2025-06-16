#include <iostream>
#include <vector>
#include <queue>
#include <fstream>
#include <sstream>
#include <string>
#include <algorithm>
#include <limits>
#include <cmath>
#include <random>
#include <chrono>
#include <unordered_map>

enum class Player {
    NONE = 0,
    RED = 1,
    BLUE = 2
};

struct Cell {
    int orbs;
    Player owner;
    
    Cell() : orbs(0), owner(Player::NONE) {}
    Cell(int o, Player p) : orbs(o), owner(p) {}
    
    bool isEmpty() const {
        return orbs == 0 && owner == Player::NONE;
    }
};

struct Move {
    int row, col;
    Player player;
    double priority; // For move ordering
    
    Move() : row(-1), col(-1), player(Player::NONE), priority(0.0) {}
    Move(int r, int c, Player p, double pr = 0.0) : row(r), col(c), player(p), priority(pr) {}
    
    bool isValid() const {
        return row >= 0 && col >= 0;
    }
    
    // Comparison for sorting (higher priority first)
    bool operator<(const Move& other) const {
        return priority > other.priority;
    }
};

enum class HeuristicType {
    ORB_COUNT,
    CONTROL_ZONES,
    STABILITY,
    THREAT_ANALYSIS,
    POSITIONAL
};

class ChainReactionGame {
private:
    int rows, cols;
    std::vector<std::vector<Cell>> board;
    Player currentPlayer;
    int totalMoves;
    HeuristicType currentHeuristic;
    
    // Transposition table for memoization
    std::unordered_map<std::string, std::pair<double, int>> transpositionTable;
    
    // Get critical mass for a cell at position (row, col)
    int getCriticalMass(int row, int col) const {
        int mass = 4; // Default for interior cells
        
        if (row == 0 || row == rows - 1) mass--; // Top or bottom edge
        if (col == 0 || col == cols - 1) mass--; // Left or right edge
        
        return mass;
    }
    
    // Get board hash for transposition table
    std::string getBoardHash() const {
        std::string hash;
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                hash += std::to_string(board[i][j].orbs);
                hash += (board[i][j].owner == Player::RED ? "R" : 
                        board[i][j].owner == Player::BLUE ? "B" : "N");
                hash += ",";
            }
        }
        hash += (currentPlayer == Player::RED ? "R" : "B");
        return hash;
    }
    
    // Get valid adjacent positions
    std::vector<std::pair<int, int>> getAdjacentPositions(int row, int col) const {
        std::vector<std::pair<int, int>> adjacent;
        
        // Check all 4 orthogonal directions
        int dr[] = {-1, 1, 0, 0};
        int dc[] = {0, 0, -1, 1};
        
        for (int i = 0; i < 4; i++) {
            int newRow = row + dr[i];
            int newCol = col + dc[i];
            
            if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols) {
                adjacent.push_back({newRow, newCol});
            }
        }
        
        return adjacent;
    }
    
    // Handle explosions and chain reactions
    void handleExplosions() {
        std::queue<std::pair<int, int>> explosionQueue;
        
        // Find all cells that need to explode
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].orbs >= getCriticalMass(i, j)) {
                    explosionQueue.push({i, j});
                }
            }
        }
        
        // Process explosions until no more chain reactions
        while (!explosionQueue.empty()) {
            auto [row, col] = explosionQueue.front();
            explosionQueue.pop();
            
            // Skip if cell is no longer critical
            if (board[row][col].orbs < getCriticalMass(row, col)) {
                continue;
            }
            
            Player explodingPlayer = board[row][col].owner;
            int orbsToDistribute = getCriticalMass(row, col);
            
            // Remove orbs from exploding cell
            board[row][col].orbs -= orbsToDistribute;
            if (board[row][col].orbs == 0) {
                board[row][col].owner = Player::NONE;
            }
            
            // Distribute orbs to adjacent cells
            auto adjacent = getAdjacentPositions(row, col);
            for (auto [adjRow, adjCol] : adjacent) {
                // Convert cell to exploding player's color and add orb
                board[adjRow][adjCol].owner = explodingPlayer;
                board[adjRow][adjCol].orbs++;
                
                // Check if this cell now needs to explode
                if (board[adjRow][adjCol].orbs >= getCriticalMass(adjRow, adjCol)) {
                    explosionQueue.push({adjRow, adjCol});
                }
            }
        }
    }
    
    // Copy constructor helper
    // ChainReactionGame(const ChainReactionGame& other) 
    //     : rows(other.rows), cols(other.cols), board(other.board), 
    //       currentPlayer(other.currentPlayer), totalMoves(other.totalMoves),
    //       currentHeuristic(other.currentHeuristic) {}
    
    // Quick evaluation for move ordering
    double quickEvaluateMove(int row, int col, Player player) const {
        double score = 0.0;
        
        // Prefer moves that are about to explode
        int criticalMass = getCriticalMass(row, col);
        if (board[row][col].orbs == criticalMass - 1) {
            score += 50.0;
        }
        
        // Prefer corner and edge positions
        if ((row == 0 || row == rows-1) && (col == 0 || col == cols-1)) {
            score += 20.0; // Corner
        } else if (row == 0 || row == rows-1 || col == 0 || col == cols-1) {
            score += 10.0; // Edge
        }
        
        // Prefer moves that threaten opponent cells
        auto adjacent = getAdjacentPositions(row, col);
        Player opponent = (player == Player::RED) ? Player::BLUE : Player::RED;
        
        for (auto [adjRow, adjCol] : adjacent) {
            if (board[adjRow][adjCol].owner == opponent) {
                score += 15.0;
            }
        }
        
        return score;
    }
    
    // HEURISTIC FUNCTIONS (simplified for speed)
    
    // Fast combined heuristic
    double fastEvaluateBoard(Player maximizingPlayer) const {
        // Check for terminal states first
        Player winner = getWinner();
        if (winner == maximizingPlayer) return 10000.0;
        if (winner != Player::NONE && winner != maximizingPlayer) return -10000.0;
        
        int maxPlayerOrbs = 0, minPlayerOrbs = 0;
        int maxPlayerCells = 0, minPlayerCells = 0;
        double maxPlayerThreat = 0, minPlayerThreat = 0;
        
        Player minPlayer = (maximizingPlayer == Player::RED) ? Player::BLUE : Player::RED;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].owner == maximizingPlayer) {
                    maxPlayerOrbs += board[i][j].orbs;
                    maxPlayerCells++;
                    
                    // Threat calculation
                    int criticalMass = getCriticalMass(i, j);
                    if (board[i][j].orbs == criticalMass - 1) {
                        maxPlayerThreat += 10.0;
                    }
                } else if (board[i][j].owner == minPlayer) {
                    minPlayerOrbs += board[i][j].orbs;
                    minPlayerCells++;
                    
                    // Threat calculation
                    int criticalMass = getCriticalMass(i, j);
                    if (board[i][j].orbs == criticalMass - 1) {
                        minPlayerThreat += 10.0;
                    }
                }
            }
        }
        
        // Weighted combination of factors
        double score = (maxPlayerOrbs - minPlayerOrbs) * 1.0 +
                      (maxPlayerCells - minPlayerCells) * 5.0 +
                      (maxPlayerThreat - minPlayerThreat) * 1.0;
        
        return score;
    }
    
    // Original evaluation function
    // double evaluateBoard(Player maximizingPlayer) const {
    //     // Check for terminal states first
    //     Player winner = getWinner();
    //     if (winner == maximizingPlayer) return 10000.0;
    //     if (winner != Player::NONE && winner != maximizingPlayer) return -10000.0;
        
    //     double score = 0.0;
        
    //     switch (currentHeuristic) {
    //         case HeuristicType::ORB_COUNT:
    //             score = orbCountHeuristic(maximizingPlayer);
    //             break;
    //         case HeuristicType::CONTROL_ZONES:
    //             score = controlZonesHeuristic(maximizingPlayer) * 10.0;
    //             break;
    //         case HeuristicType::STABILITY:
    //             score = stabilityHeuristic(maximizingPlayer) * 5.0;
    //             break;
    //         case HeuristicType::THREAT_ANALYSIS:
    //             score = threatAnalysisHeuristic(maximizingPlayer);
    //             break;
    //         case HeuristicType::POSITIONAL:
    //             score = positionalHeuristic(maximizingPlayer);
    //             break;
    //     }
        
    //     return score;
    // }
    
    // Heuristic functions (keeping original implementations)
    double orbCountHeuristic(Player maximizingPlayer) const {
        int maxPlayerOrbs = 0, minPlayerOrbs = 0;
        Player minPlayer = (maximizingPlayer == Player::RED) ? Player::BLUE : Player::RED;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].owner == maximizingPlayer) {
                    maxPlayerOrbs += board[i][j].orbs;
                } else if (board[i][j].owner == minPlayer) {
                    minPlayerOrbs += board[i][j].orbs;
                }
            }
        }
        
        return maxPlayerOrbs - minPlayerOrbs;
    }
    
    double controlZonesHeuristic(Player maximizingPlayer) const {
        int maxPlayerCells = 0, minPlayerCells = 0;
        Player minPlayer = (maximizingPlayer == Player::RED) ? Player::BLUE : Player::RED;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].owner == maximizingPlayer) {
                    maxPlayerCells++;
                } else if (board[i][j].owner == minPlayer) {
                    minPlayerCells++;
                }
            }
        }
        
        return maxPlayerCells - minPlayerCells;
    }
    
    double stabilityHeuristic(Player maximizingPlayer) const {
        double maxPlayerStability = 0, minPlayerStability = 0;
        Player minPlayer = (maximizingPlayer == Player::RED) ? Player::BLUE : Player::RED;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].owner != Player::NONE) {
                    int criticalMass = getCriticalMass(i, j);
                    double stability = (double)(criticalMass - board[i][j].orbs) / criticalMass;
                    
                    if (board[i][j].owner == maximizingPlayer) {
                        maxPlayerStability += stability;
                    } else {
                        minPlayerStability += stability;
                    }
                }
            }
        }
        
        return maxPlayerStability - minPlayerStability;
    }
    
    double threatAnalysisHeuristic(Player maximizingPlayer) const {
        double maxPlayerThreat = 0, minPlayerThreat = 0;
        Player minPlayer = (maximizingPlayer == Player::RED) ? Player::BLUE : Player::RED;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].owner != Player::NONE) {
                    int criticalMass = getCriticalMass(i, j);
                    
                    if (board[i][j].orbs == criticalMass - 1) {
                        double threat = 10.0;
                        
                        auto adjacent = getAdjacentPositions(i, j);
                        for (auto [adjRow, adjCol] : adjacent) {
                            if (board[adjRow][adjCol].owner == minPlayer) {
                                threat += 5.0;
                            }
                        }
                        
                        if (board[i][j].owner == maximizingPlayer) {
                            maxPlayerThreat += threat;
                        } else {
                            minPlayerThreat += threat;
                        }
                    }
                }
            }
        }
        
        return maxPlayerThreat - minPlayerThreat;
    }
    
    double positionalHeuristic(Player maximizingPlayer) const {
        double maxPlayerPos = 0, minPlayerPos = 0;
        Player minPlayer = (maximizingPlayer == Player::RED) ? Player::BLUE : Player::RED;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].owner != Player::NONE) {
                    double posValue = 1.0;
                    
                    if ((i == 0 || i == rows-1) && (j == 0 || j == cols-1)) {
                        posValue = 3.0;
                    } else if (i == 0 || i == rows-1 || j == 0 || j == cols-1) {
                        posValue = 2.0;
                    }
                    
                    posValue *= board[i][j].orbs;
                    
                    if (board[i][j].owner == maximizingPlayer) {
                        maxPlayerPos += posValue;
                    } else {
                        minPlayerPos += posValue;
                    }
                }
            }
        }
        
        return maxPlayerPos - minPlayerPos;
    }
    
    // Optimized Minimax with time limit and better pruning
    std::pair<double, Move> minimax(int depth, bool isMaximizing, double alpha, double beta, 
                                Player maximizingPlayer, int maxDepth, 
                                std::chrono::steady_clock::time_point startTime,
                                int timeLimit) {
        // Time check
        if (std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now() - startTime).count() > timeLimit) {
            return {fastEvaluateBoard(maximizingPlayer), Move()};
        }
        
        // Terminal conditions
        if (depth >= maxDepth || isGameOver()) {
            return {fastEvaluateBoard(maximizingPlayer), Move()};
        }
        
        // Check transposition table
        std::string boardHash = getBoardHash();
        if (transpositionTable.find(boardHash) != transpositionTable.end() &&
            transpositionTable[boardHash].second >= (maxDepth - depth)) {
            return {transpositionTable[boardHash].first, Move()};
        }
        
        std::vector<Move> validMoves = getValidMovesOrdered();
        if (validMoves.empty()) {
            return {fastEvaluateBoard(maximizingPlayer), Move()};
        }
        
        Move bestMove;
        
        if (isMaximizing) {
            double maxEval = std::numeric_limits<double>::lowest();
            
            for (const Move& move : validMoves) {
                ChainReactionGame tempGame(*this);
                tempGame.makeMove(move.row, move.col, move.player);
                
                auto [eval, _] = tempGame.minimax(depth + 1, false, alpha, beta, 
                                                 maximizingPlayer, maxDepth, startTime, timeLimit);
                
                if (eval > maxEval) {
                    maxEval = eval;
                    bestMove = move;
                }
                
                alpha = std::max(alpha, eval);
                if (beta <= alpha) {
                    break; // Alpha-beta pruning
                }
                
                // Time check during move evaluation
                if (std::chrono::duration_cast<std::chrono::milliseconds>(
                    std::chrono::steady_clock::now() - startTime).count() > timeLimit) {
                    break;
                }
            }
            
            // Store in transposition table
            transpositionTable[boardHash] = {maxEval, maxDepth - depth};
            return {maxEval, bestMove};
        } else {
            double minEval = std::numeric_limits<double>::max();
            
            for (const Move& move : validMoves) {
                ChainReactionGame tempGame(*this);
                tempGame.makeMove(move.row, move.col, move.player);
                
                auto [eval, _] = tempGame.minimax(depth + 1, true, alpha, beta, 
                                                 maximizingPlayer, maxDepth, startTime, timeLimit);
                
                if (eval < minEval) {
                    minEval = eval;
                    bestMove = move;
                }
                
                beta = std::min(beta, eval);
                if (beta <= alpha) {
                    break; // Alpha-beta pruning
                }
                
                // Time check during move evaluation
                if (std::chrono::duration_cast<std::chrono::milliseconds>(
                    std::chrono::steady_clock::now() - startTime).count() > timeLimit) {
                    break;
                }
            }
            
            // Store in transposition table
            transpositionTable[boardHash] = {minEval, maxDepth - depth};
            return {minEval, bestMove};
        }
    }
    
public:
    ChainReactionGame(int r = 9, int c = 6) 
        : rows(r), cols(c), currentPlayer(Player::RED), totalMoves(0), 
          currentHeuristic(HeuristicType::THREAT_ANALYSIS) {
        board.resize(rows, std::vector<Cell>(cols));
    }
    
    // Set heuristic type
    void setHeuristic(HeuristicType hType) {
        currentHeuristic = hType;
    }
    
    // Get heuristic name
    std::string getHeuristicName() const {
        switch (currentHeuristic) {
            case HeuristicType::ORB_COUNT: return "Orb Count";
            case HeuristicType::CONTROL_ZONES: return "Control Zones";
            case HeuristicType::STABILITY: return "Stability Analysis";
            case HeuristicType::THREAT_ANALYSIS: return "Threat Analysis";
            case HeuristicType::POSITIONAL: return "Positional Advantage";
            default: return "Unknown";
        }
    }
    
    // Get valid moves ordered by priority (for better alpha-beta pruning)
    std::vector<Move> getValidMovesOrdered() const {
        std::vector<Move> moves;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (isValidMove(i, j, currentPlayer)) {
                    double priority = quickEvaluateMove(i, j, currentPlayer);
                    moves.push_back(Move(i, j, currentPlayer, priority));
                }
            }
        }
        
        // Sort moves by priority (higher priority first)
        std::sort(moves.begin(), moves.end());
        
        return moves;
    }
    
    // Optimized AI move with configurable difficulty
    Move getAIMove(int difficulty = 2, int timeLimit = 2000) {
        auto start = std::chrono::steady_clock::now();
        
        // Clear transposition table if it gets too large
        if (transpositionTable.size() > 10000) {
            transpositionTable.clear();
        }
        
        // Adjust depth based on difficulty (1=easy, 2=medium, 3=hard)
        int depthLimit = 2 + difficulty;
        
        // For early game, use lower depth
        if (totalMoves < 10) {
            depthLimit = std::max(2, depthLimit - 1);
        }
        
        auto [value, bestMove] = minimax(0, true, std::numeric_limits<double>::lowest(), 
                                        std::numeric_limits<double>::max(), currentPlayer, 
                                        depthLimit, start, timeLimit);
        
        auto end = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        std::cout << "AI thinking time: " << duration.count() << "ms" << std::endl;
        std::cout << "Best move evaluation: " << value << std::endl;
        std::cout << "Transposition table size: " << transpositionTable.size() << std::endl;
        
        return bestMove;
    }
    
    // Quick AI move for very fast gameplay
    Move getQuickAIMove() {
        auto start = std::chrono::steady_clock::now();
        
        std::vector<Move> validMoves = getValidMovesOrdered();
        if (validMoves.empty()) {
            return Move();
        }
        
        // Just pick the best move based on quick evaluation
        Move bestMove = validMoves[0];
        
        auto end = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        std::cout << "Quick AI thinking time: " << duration.count() << "ms" << std::endl;
        
        return bestMove;
    }
    
    // Check if a move is valid
    bool isValidMove(int row, int col, Player player) const {
        if (row < 0 || row >= rows || col < 0 || col >= cols) {
            return false;
        }
        
        Cell cell = board[row][col];
        return cell.isEmpty() || cell.owner == player;
    }
    
    // Make a move
    bool makeMove(int row, int col, Player player) {
        if (!isValidMove(row, col, player)) {
            return false;
        }
        
        board[row][col].orbs++;
        board[row][col].owner = player;
        totalMoves++;
        
        handleExplosions();
        currentPlayer = (currentPlayer == Player::RED) ? Player::BLUE : Player::RED;
        
        return true;
    }
    
    // Check for winner
    Player getWinner() const {
        if (totalMoves < 2) {
            return Player::NONE;
        }
        
        bool hasRed = false, hasBlue = false;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].owner == Player::RED) {
                    hasRed = true;
                } else if (board[i][j].owner == Player::BLUE) {
                    hasBlue = true;
                }
                
                if (hasRed && hasBlue) {
                    return Player::NONE;
                }
            }
        }
        
        if (hasRed && !hasBlue) return Player::RED;
        if (hasBlue && !hasRed) return Player::BLUE;
        
        return Player::NONE;
    }
    
    // Check if game is over
    bool isGameOver() const {
        return getWinner() != Player::NONE;
    }
    
    // Get current player
    Player getCurrentPlayer() const {
        return currentPlayer;
    }
    
    // Print board to console
    void printBoard() const {
        std::cout << "\n  ";
        for (int j = 0; j < cols; j++) {
            std::cout << j << " ";
        }
        std::cout << "\n";
        
        for (int i = 0; i < rows; i++) {
            std::cout << i << " ";
            for (int j = 0; j < cols; j++) {
                if (board[i][j].isEmpty()) {
                    std::cout << ". ";
                } else {
                    char color = (board[i][j].owner == Player::RED) ? 'R' : 'B';
                    std::cout << board[i][j].orbs << color << " ";
                }
            }
            std::cout << "\n";
        }
        std::cout << "\n";
    }
    
    // Get all valid moves for current player
    std::vector<Move> getValidMoves() const {
        std::vector<Move> moves;
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (isValidMove(i, j, currentPlayer)) {
                    moves.push_back(Move(i, j, currentPlayer));
                }
            }
        }
        
        return moves;
    }
    
    // Save game state to file
    void saveToFile(const std::string& filename, const std::string& moveType) const {
        std::ofstream file(filename);
        file << moveType << "\n";
        
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (board[i][j].isEmpty()) {
                    file << "0";
                } else {
                    char color = (board[i][j].owner == Player::RED) ? 'R' : 'B';
                    file << board[i][j].orbs << color;
                }
                
                if (j < cols - 1) file << " ";
            }
            file << "\n";
        }
        file.close();
    }
    
    // Load game state from file
    bool loadFromFile(const std::string& filename) {
        std::ifstream file(filename);
        if (!file.is_open()) return false;
        
        std::string moveType;
        std::getline(file, moveType);
        
        for (int i = 0; i < rows; i++) {
            std::string line;
            std::getline(file, line);
            std::istringstream iss(line);
            
            for (int j = 0; j < cols; j++) {
                std::string cellStr;
                iss >> cellStr;
                
                if (cellStr == "0") {
                    board[i][j] = Cell();
                } else {
                    int orbs = cellStr[0] - '0';
                    Player owner = (cellStr[1] == 'R') ? Player::RED : Player::BLUE;
                    board[i][j] = Cell(orbs, owner);
                }
            }
        }
        
        file.close();
        return true;
    }
    
    std::pair<int, int> getDimensions() const {
        return {rows, cols};
    }
    
    Cell getCell(int row, int col) const {
        if (row >= 0 && row < rows && col >= 0 && col < cols) {
            return board[row][col];
        }
        return Cell();
    }
};

// Human vs AI game with difficulty selection
void playHumanVsAI() {
    ChainReactionGame game;
    
    std::cout << "=== Chain Reaction: Human vs AI ===\n";
    
    // Select difficulty
    std::cout << "Choose AI difficulty:\n";
    std::cout << "1. Easy (Quick moves)\n";
    std::cout << "2. Medium (Balanced)\n";
    std::cout << "3. Hard (Thorough analysis)\n";
    std::cout << "4. Expert (Deep analysis)\n";
    std::cout << "Enter choice (1-4): ";
    
    int difficulty;
    std::cin >> difficulty;
    if (difficulty < 1 || difficulty > 4) difficulty = 2;
    
    // Select heuristic
    std::cout << "Choose AI heuristic:\n";
    std::cout << "1. Orb Count\n2. Control Zones\n3. Stability Analysis\n";
    std::cout << "4. Threat Analysis\n5. Positional Advantage\n";
    std::cout << "Enter choice (1-5): ";
    
    int choice;
    std::cin >> choice;
    
    HeuristicType heuristics[] = {
        HeuristicType::ORB_COUNT,
        HeuristicType::CONTROL_ZONES,
        HeuristicType::STABILITY,
        HeuristicType::THREAT_ANALYSIS,
        HeuristicType::POSITIONAL
    };
    
    if (choice >= 1 && choice <= 5) {
        game.setHeuristic(heuristics[choice - 1]);
    }
    
    std::cout << "Selected difficulty: " << (difficulty == 1 ? "Easy" : 
                                           difficulty == 2 ? "Medium" :
                                           difficulty == 3 ? "Hard" : "Expert") << std::endl;
    std::cout << "Selected heuristic: " << game.getHeuristicName() << std::endl;
    std::cout << "You are Red, AI is Blue. Red goes first.\n";
    
    while (!game.isGameOver()) {
        game.printBoard();
        
        Player current = game.getCurrentPlayer();
        
        if (current == Player::RED) {
            // Human move
            std::cout << "Your turn! Enter move (row col): ";
            int row, col;
            std::cin >> row >> col;
            
            if (std::cin.fail()) {
                std::cin.clear();
                std::cin.ignore(10000, '\n');
                std::cout << "Invalid input! Please enter two numbers.\n";
                continue;
            }
            
            if (!game.makeMove(row, col, current)) {
                std::cout << "Invalid move! Try again.\n";
                continue;
            }
            
            game.saveToFile("gamestate.txt", "Human Move:");
        } else {
            // AI move with difficulty-based strategy
            std::cout << "AI is thinking...\n";
            Move aiMove;
            
            if (difficulty == 1) {
                // Easy: Use quick move
                aiMove = game.getQuickAIMove();
            } else {
                // Medium to Expert: Use minimax with different time limits
                int timeLimit = (difficulty == 2) ? 1000 :   // Medium: 1 second
                               (difficulty == 3) ? 3000 :   // Hard: 3 seconds
                               5000;                         // Expert: 5 seconds
                
                aiMove = game.getAIMove(difficulty, timeLimit);
            }
            
            if (aiMove.isValid()) {
                std::cout << "AI plays: (" << aiMove.row << ", " << aiMove.col << ")\n";
                game.makeMove(aiMove.row, aiMove.col, current);
                game.saveToFile("gamestate.txt", "AI Move:");
            } else {
                std::cout << "AI couldn't find a valid move!\n";
                break;
            }
        }
    }
    
    game.printBoard();
    Player winner = game.getWinner();
    if (winner == Player::RED) {
        std::cout << "🎉 You win!\n";
    } else if (winner == Player::BLUE) {
        std::cout << "🤖 AI wins!\n";
    } else {
        std::cout << "Game ended in a draw.\n";
    }
}

// Human vs Human game
void playHumanVsHuman() {
    ChainReactionGame game;
    
    std::cout << "=== Chain Reaction: Human vs Human ===\n";
    std::cout << "Red player starts. Enter row and column (0-indexed).\n";
    
    while (!game.isGameOver()) {
        game.printBoard();
        
        Player current = game.getCurrentPlayer();
        std::string playerName = (current == Player::RED) ? "Red" : "Blue";
        
        std::cout << playerName << " player's turn. Enter move (row col): ";
        
        int row, col;
        std::cin >> row >> col;
        
        if (std::cin.fail()) {
            std::cin.clear();
            std::cin.ignore(10000, '\n');
            std::cout << "Invalid input! Please enter two numbers.\n";
            continue;
        }
        
        if (!game.makeMove(row, col, current)) {
            std::cout << "Invalid move! Try again.\n";
            continue;
        }
        
        std::string moveType = (current == Player::RED) ? "Red Move:" : "Blue Move:";
        game.saveToFile("gamestate.txt", moveType);
    }
    
    game.printBoard();
    Player winner = game.getWinner();
    if (winner == Player::RED) {
        std::cout << "🎉 Red player wins!\n";
    } else if (winner == Player::BLUE) {
        std::cout << "🎉 Blue player wins!\n";
    }
}

int main() {
    std::cout << "Chain Reaction Game - Optimized Version\n";
    std::cout << "1. Human vs Human\n";
    std::cout << "2. Human vs AI\n";
    std::cout << "Choose game mode: ";
    
    int mode;
    std::cin >> mode;
    
    if (mode == 1) {
        playHumanVsHuman();
    } else if (mode == 2) {
        playHumanVsAI();
    } else {
        std::cout << "Invalid choice!\n";
    }
    
    return 0;
}