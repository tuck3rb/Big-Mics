

class Point {
  double x, y;
  bool counted;
  Point(this.x, this.y) : counted = false;
}

class GameState {
  
  double bigMicX = 32.0;
  double bigMicY = 0; 
  bool isJumping = false;
  bool peaked = false;

  List<Point> obstacles;
  double speed = 2.0;

  bool isGameOver = false; 
  int score = -1;

  GameState(int rows, int columns) : obstacles = [] {
    generateInitialObstacles(columns);
    // print("GameState initialized with ${obstacles.length} obstacles");
  }


  void generateInitialObstacles(int columns) {

    for (int i = 0; i < 1; i++) {
      obstacles.add(Point(columns * (i + 1) * 3, 0));
    }
  }

  void moveObstacles() {
    for (var obstacle in obstacles) {
      obstacle.x += speed;
      if (obstacle.x >= 50) {
        if (!obstacle.counted) {
          score++;
          obstacle.counted = true;
          // print("Obstacle passed. New score: $score");
        }
        obstacle.x = 00;
        obstacle.counted = false;  // Reset the flag for the next round
      }
    }
  }

    void resetGame() {
      score = -1;
      isGameOver = false;
      for (var obstacle in obstacles) {
        obstacle.counted = false;
      }
      // print("Game reset. Score: $score");
    }

  void updateJump(double gravity, double timeStep) {
    if (isJumping) {
      if (isGameOver) {
        speed = 2.0;
        score = 0;
        isGameOver = false;
      }
      if(bigMicY <= 5.0 && !peaked){
        bigMicY -= timeStep * gravity;
      }
      else {
        peaked = true;
      }
      if(peaked){
        bigMicY += timeStep * gravity;
        if (bigMicY <= 0) { 
          bigMicY = 0;
          isJumping = false;
          peaked = false;
        }
      }
    }
  }

  void jump(double initialVelocity) {
    if (!isJumping) {
      isJumping = true;
      bigMicY += 0.1 * initialVelocity;
      peaked = false;
    }

  }
  void handleCollision() {
    for (var obstacle in obstacles){
      if (obstacle.x == bigMicX && bigMicY < 2.0){
        isGameOver = true;
        // print("Collision detected. Game over. Final score: $score");
        break; 
      }
      if (isGameOver) {
        speed = 0;
      }
    }
  }
  int getScore() {
    // print("Current score: $score");
    return score;
  }
}
