#include <sys/stat.h>
#include <stdio.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <datawarp.h>

double dclock(void)
{
  struct timeval tv;
  gettimeofday(&tv,0);
  return (double) tv.tv_sec + (double) tv.tv_usec * 1e-6;
}


int stage_query(const char *dw_file)
{
  int step;
  for (step=1;step <= 20;step++) {
    sleep(10);
    int complete;
    int pending;
    int deferred;
    int failed;
    int r = dw_query_file_stage(dw_file,&complete,&pending,&deferred,&failed);
    if (r != 0) {
      fprintf(stderr,"dw_query_file_stage(%s) = %d\n",dw_file,r);
      return -1;
    }
//    printf("Stage step %d: complete %d, pending %d, deferred %d, failed %d\n",
//      step,complete,pending,deferred,failed);
    if (complete != 0) return 0;
    if (failed != 0) return -1;
  }
  return -1; // time out
}

int main(int argc, char **argv)
{

    char *infile, *outfile;
    int stage_out,stage_in,quer;
    double start,end;
    infile = argv[1];
    outfile = argv[2];
    start = dclock();
    stage_in = dw_stage_file_in(outfile, infile);
    quer = stage_query(outfile);

    end = dclock() -start;
    printf("Stage in API duration %lf seconds\n",end);

    if (stage_in != 0) {
    fprintf(stderr,"dw_stage_file_in(%s,%s) = %d\n",outfile,infile,stage_in);
     }
    return 0;
}
