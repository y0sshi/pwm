#include <stdio.h>
#include <math.h>

#define SCALE 256
#define RANGE 1024
#define MID (RANGE / 2)

int main() {
  int x;
  double y;
  char filename[] = "duty.tab";
  FILE *fp;

  fp = fopen(filename, "w");
  fprintf(fp, "  reg [$clog2(SCALE):0] duty [DIV - 1:0];\n");
  fprintf(fp, "  initial begin\n");
  for (x = 0; x < RANGE; x++) {
    if (x < MID) {
      y = (SCALE - 1) * pow(10, (double)2 * (x - MID - 1)/ (MID - 1));
      printf("%d, %lf\n", x - MID - 1, pow(10, (x - MID - 1)));
    }
    else {
      y = (SCALE - 1) * pow(10, (double)2 * -(x - MID) / MID);
    }
    fprintf(fp, "    duty[%d] = 'd%.0lf;\n", x, y);
  }
  fprintf(fp, "  end\n");

  fclose(fp);
  return 0;
}
