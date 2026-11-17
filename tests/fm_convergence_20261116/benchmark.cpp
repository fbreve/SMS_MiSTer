#include "Vtriad.h"
#include "verilated.h"
#include <cstdio>
#include <cstdlib>
#include <chrono>
int main(int argc,char**argv){Verilated::commandArgs(argc,argv);Vtriad m;m.clk=0;m.ena=0;m.reset_n=0;m.hold=0;m.cs_n=1;m.a=0;m.d=0;m.addr=255;m.rd=0;m.wr=0;m.wd=0;auto start=std::chrono::steady_clock::now();unsigned n=argc>1?atoi(argv[1]):1000000;for(unsigned i=0;i<n;i++){m.reset_n=i>5;m.ena=i%15==0;m.clk=0;m.eval();m.clk=1;m.eval();}auto dt=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();printf("host=%u seconds=%.6f host_per_second=%.0f ready=%u y=%u\n",n,dt,n/dt,m.ready,m.y0);return 0;}
double sc_time_stamp(){return 0;}
