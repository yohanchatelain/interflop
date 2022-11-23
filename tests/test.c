#include <stdio.h>
#include <stdlib.h>

#define PRINT2(A, OP, B, C)                                                    \
  C = A OP B;                                                                  \
  fprintf(stderr, #A " " #OP " " #B " = " #C);                                 \
  fprintf(stderr, " : %.13a %s %.13a = %.13a\n", A, #OP, B, C);

#define PRINT3(A, OP1, B, OP2, C, D)                                           \
  D = A OP1 B OP2 C;                                                           \
  fprintf(stderr, #A " " #OP1 " " #B " " #OP2 " " #C " = " #D);                \
  fprintf(stderr, " : %.13a %s %.13a %s %.13a = %.13a\n", A, #OP1, B, #OP2, C, \
          D);

int main(int argc, char *argv[]) {
  double a = atof(argv[1]);
  double b = atof(argv[2]);

  double c = 0;
  int cmp = 0;

  PRINT2(a, +, b, c);
  PRINT2(a, -, b, c);
  PRINT2(a, *, b, c);
  PRINT2(a, /, b, c);
  PRINT3(a, *, b, +, c, c);

  PRINT2(a, ==, b, c);
  PRINT2(a, !=, b, c);
  PRINT2(a, <, b, c);
  PRINT2(a, <=, b, c);
  PRINT2(a, >, b, c);
  PRINT2(a, >=, b, c);
}