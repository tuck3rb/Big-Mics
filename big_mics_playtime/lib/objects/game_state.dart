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
  }

  void generateInitialObstacles(int columns) {
    for (int i = 0; i < 1; i++) {
      obstacles.add(Point(columns * (i + 1) * 3, 0));
    }
  }

  void moveObstacles() {
    if (isGameOver) return; // Don't move obstacles if game is over

    for (var obstacle in obstacles) {
      obstacle.x += speed;
      if (obstacle.x >= 50) {
        if (!obstacle.counted) {
          score++;
          obstacle.counted = true;
        }
        obstacle.x = 00;
        obstacle.counted = false;
      }
    }
  }

  void resetGame() {
    score = -1;
    isGameOver = false;
    speed = 2.0;
    bigMicY = 0;
    isJumping = false;
    peaked = false;

    // Reset obstacles
    obstacles.clear();
    generateInitialObstacles(20); // Reset to initial state
  }

  void updateJump(double gravity, double timeStep) {
    if (isGameOver) return; // Don't allow jumping if game is over

    if (isJumping) {
      if (!peaked && bigMicY <= 5.0) {
        // Jumping upwards
        bigMicY -= timeStep * gravity;
      } else {
        // Peaked, start falling
        peaked = true;
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
    if (!isJumping && !isGameOver) {
      isJumping = true;
      bigMicY += 0.1 * initialVelocity;
      peaked = false;
    }
  }

  void handleCollision() {
    if (isGameOver) return; // Skip collision check if game is already over

    for (var obstacle in obstacles) {
      if (obstacle.x == bigMicX && bigMicY < 2.0) {
        isGameOver = true;
        speed = 0; // Stop obstacles
        break;
      }
    }
  }

  int getScore() {
    return score;
  }
}
