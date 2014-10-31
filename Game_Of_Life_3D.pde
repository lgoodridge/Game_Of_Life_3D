/*******************************
 * Title: Game_Of_Life_3D.pde  *
 * Author: Lance Goodridge     *
 * Date Created: 10/30/14      *
 * Description: Simulates      *
 * Conway's Game of Life in 3D *
 *******************************/

final int WIDTH = 500;
final int HEIGHT = 500;
final int DEPTH = 500;

final int VIEW_WIDTH = 1000;
final int VIEW_HEIGHT = 700;

final int CELL_SIZE = 10;

final int BACKGROUND_BRIGHTNESS = 20;
final int ALIVE_CELL_BRIGHTNESS = 200;

final int MAJORa_GRID_BRIGHTNESS = 100;
final int MINOR_GRID_BRIGHTNESS = 75;

final int RANDOMIZE_PERCENTAGE = 10;

final int DELAY = 0;

final int[] STAY_ALIVE_RULES = {3, 4, 5};
final int[] BIRTH_RULES = {3};

final float ZOOM_SENSITIVITY = 0.5;
final float TRANSLATE_SENSITIVITY = 5;

int[][][] grid;
boolean paused;
float zoom;
float tx;
float ty;
float tz;

void setup() {
  size(VIEW_WIDTH, VIEW_HEIGHT, P3D);
  grid = new int[WIDTH/CELL_SIZE][HEIGHT/CELL_SIZE][DEPTH/CELL_SIZE];
  paused = false;
  zoom = 1;
  tx = -(WIDTH / 2 - VIEW_WIDTH);
  ty = -(HEIGHT / 2 - VIEW_HEIGHT);
  tz = 0;
  randomizeGrid();
}

void draw() {
  if (!paused) updateGrid();
  background(BACKGROUND_BRIGHTNESS);
  updateView();
  drawGridLines();
  drawGrid();
  delay(DELAY);
}

void keyPressed() {
  if (key == 'p') paused = !paused;
  if (key == 'r') { paused = true; randomizeGrid(); }
  if (keyCode == ENTER) changeZoom(ZOOM_SENSITIVITY);
  if (keyCode == SHIFT) changeZoom(-1 * ZOOM_SENSITIVITY);
  if (key == 'a') tx += TRANSLATE_SENSITIVITY;
  if (key == 'd') tx -= TRANSLATE_SENSITIVITY;
  if (key == 'w') ty += TRANSLATE_SENSITIVITY;
  if (key == 's') ty -= TRANSLATE_SENSITIVITY;
  if (key == 'q') tz += TRANSLATE_SENSITIVITY;
  if (key == 'e') tz -= TRANSLATE_SENSITIVITY;
  //zoom = constrain(zoom, ZOOM_SENSITIVITY, 10);
  //tx = constrain(tx, -1 * (WIDTH - (2 * VIEW_WIDTH)) - 100, 20);
  //ty = constrain(ty, -1 * (HEIGHT - (2 * VIEW_HEIGHT)) - 100, 20);
  println(" => Tx: " + tx + " , Ty: " + ty + " , Tz: " + tz);
}

void updateGrid() {
  int[][][] temp = new int[WIDTH/CELL_SIZE][HEIGHT/CELL_SIZE][DEPTH/CELL_SIZE];
  for (int i = 0; i < WIDTH/CELL_SIZE; i++) {
    for (int j = 0; j < HEIGHT/CELL_SIZE; j++) {
      for (int k = 0; k < DEPTH/CELL_SIZE; k++) {
        temp[i][j][k] = matchesRules(grid[i][j][k], getNeighbors(i, j, k));
      }
    }
  }
  grid = temp;
}

void updateView() {
  scale(zoom);
  translate(tx, ty, tz);
}

void drawGridLines() {
  for (int i = 1; i < HEIGHT/CELL_SIZE; i++) {
    for (int j = 1; j < DEPTH/CELL_SIZE; j++) {
      if (i % 5 == 0 || j % 5 == 0) {
        stroke(MAJOR_GRID_BRIGHTNESS);
      } else {
        stroke(MINOR_GRID_BRIGHTNESS);
      }
      line(0, i * CELL_SIZE, j * CELL_SIZE, WIDTH, i * CELL_SIZE, j * CELL_SIZE);
    }
  }
  for (int i = 1; i < WIDTH/CELL_SIZE; i++) {
    for (int j = 1; j < DEPTH/CELL_SIZE; j++) {
      if (i % 5 == 0 || j % 5 == 0) {
        stroke(MAJOR_GRID_BRIGHTNESS);
      } else {
        stroke(MINOR_GRID_BRIGHTNESS);
      }
      line(i * CELL_SIZE, 0, j * CELL_SIZE, i * CELL_SIZE, HEIGHT, j * CELL_SIZE);
    }
  }
  for (int i = 1; i < WIDTH/CELL_SIZE; i++) {
    for (int j = 1; j < HEIGHT/CELL_SIZE; j++) {
      if (i % 5 == 0 || j % 5 == 0) {
        stroke(MAJOR_GRID_BRIGHTNESS);
      } else {
        stroke(MINOR_GRID_BRIGHTNESS);
      }
      line(i * CELL_SIZE, j * CELL_SIZE, 0, i * CELL_SIZE, j * CELL_SIZE, DEPTH);
    }
  }
}

void drawGrid() {
  stroke(ALIVE_CELL_BRIGHTNESS);
  for (int i = 0; i < WIDTH/CELL_SIZE; i++) {
    for (int j = 0; j < HEIGHT/CELL_SIZE; j++) {
      for (int k = 0; k < DEPTH/CELL_SIZE; k++) {
        if (grid[i][j][k] == 1) {
          pushMatrix();
          translate((i * CELL_SIZE), (j * CELL_SIZE), (k * CELL_SIZE));
          box(CELL_SIZE);
          popMatrix();
        }
      }
    }
  }
}

void changeZoom(float dZoom) {
  if ((zoom + dZoom) <= 0 || (zoom + dZoom) >= 10) return;
  float originalWidth = VIEW_WIDTH / zoom/ 2.0;
  float originalHeight = VIEW_HEIGHT / zoom / 2.0;
  zoom += dZoom;
  float newWidth = VIEW_WIDTH / zoom / 2.0;
  float newHeight = VIEW_HEIGHT / zoom / 2.0;
  tx = tx + newWidth - originalWidth;
  ty = ty + newHeight - originalHeight;
  print("W: " + originalWidth + " , w: " + newWidth);
  print(" , H: " + originalHeight + " , h: " + newHeight);
}

void randomizeGrid() {
  grid = new int[WIDTH/CELL_SIZE][HEIGHT/CELL_SIZE][DEPTH/CELL_SIZE];
  for (int i = 0; i < WIDTH/CELL_SIZE; i++) {
    for (int j = 0; j < HEIGHT/CELL_SIZE; j++) {
      for (int k = 0; k < DEPTH/CELL_SIZE; k++) {
        int rand = (int) random(100);
        if (rand < RANDOMIZE_PERCENTAGE) grid[i][j][k] = 1;
      }
    }
  }
}

int matchesRules(int state, int neighbors) {
  int[] rules;
  if (state == 1) rules = STAY_ALIVE_RULES;
  else rules = BIRTH_RULES;
  for (int rule : rules) {
    if (neighbors == rule) return 1;
  }
  return 0;
}

int getNeighbors(int x, int y, int z) {
  int neighbors = 0;
  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j <= y+1; j++) {
      for (int k = z-1; k <= z+1; k++) {
        if (i < 0 || i >= WIDTH/CELL_SIZE) continue;
        if (j < 0 || j >= HEIGHT/CELL_SIZE) continue;
        if (k < 0 || k >= DEPTH/CELL_SIZE) continue;
        if (i == x && j == y && k == z) continue;
        neighbors += grid[i][j][k];
      }
    }
  }
  return neighbors;
}
