

class Point {
  double x, y;
  Point(this.x, this.y);
}

class GameState {
  
  double bigMicX = 32.0;
  double bigMicY = 0; 
  bool isJumping = false;
  bool peaked = false;

  List<Point> obstacles;
  double speed = 2.0;

  bool isGameOver = false; 
  int score = 0;

  GameState(int rows, int columns) : obstacles = [] {
    generateInitialObstacles(columns);
  }


  void generateInitialObstacles(int columns) {

    for (int i = 0; i < 5; i++) {
      obstacles.add(Point(columns * (i + 1) * 3, 0));
    }
  }

  void moveObstacles() {
    for (var obstacle in obstacles) {
      obstacle.x += speed;
      if (obstacle.x >= 50) {
        obstacle.x = 0; 
        score++; 
      }
    }
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
        break; 
      }
      if (isGameOver) {
        speed = 0;
      }
    }
  }
  int getScore() {
    return score;
  }
}
