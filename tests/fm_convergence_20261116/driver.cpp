#include "Vtriad.h"
#include "verilated.h"
#include <array>
#include <vector>
#include <string>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cmath>
#include <algorithm>
#include <chrono>
#include <fstream>
#include <iomanip>
#include <stdexcept>
static uint64_t hostclock=0;
double sc_time_stamp(){return double(hostclock*10);}
static constexpr double FMHZ=3579545.0;
static int signed14(unsigned x){return (x&8192)?int(x)-16384:int(x);}
static int clamp13(int x){return std::max(-4096,std::min(4095,x));}
struct Stat{uint64_t n=0,bad=0,first=0,last=0,nzref=0,nzcand=0,clipref=0,clipcand=0;long double sq=0,refsq=0,candsq=0;int peak=0,refpeak=0,candpeak=0;void add(int ref,int cand,uint64_t t){int df=abs(cand-ref);if(df){bad++;if(!first)first=t;last=t;}peak=std::max(peak,df);refpeak=std::max(refpeak,abs(ref));candpeak=std::max(candpeak,abs(cand));sq+=(long double)df*df;refsq+=(long double)ref*ref;candsq+=(long double)cand*cand;n++;nzref+=ref!=0;nzcand+=cand!=0;clipref+=(ref>=4095||ref<=-4096);clipcand+=(cand>=4095||cand<=-4096);}
 void json(std::ostream&o)const{o<<"{\"n\":"<<n<<",\"bad\":"<<bad<<",\"first\":"<<first<<",\"last\":"<<last<<",\"first_seconds\":"<<first/FMHZ<<",\"last_seconds\":"<<last/FMHZ<<",\"peak\":"<<peak<<",\"rms\":"<<(n?sqrt(double(sq/n)):0)<<",\"reference_rms\":"<<(n?sqrt(double(refsq/n)):0)<<",\"candidate_rms\":"<<(n?sqrt(double(candsq/n)):0)<<",\"reference_nonzero\":"<<nzref<<",\"candidate_nonzero\":"<<nzcand<<",\"reference_peak\":"<<refpeak<<",\"candidate_peak\":"<<candpeak<<",\"reference_at_output_rail\":"<<clipref<<",\"candidate_at_output_rail\":"<<clipcand<<"}";}
};
struct Pair{Stat raw,clamped,full_control,reduced_control;void add(int u,int f,int r,uint64_t t){raw.add(f,r,t);clamped.add(clamp13(f),clamp13(r),t);full_control.add(u,f,t);reduced_control.add(u,r,t);}void json(std::ostream&o)const{o<<"{\"raw\":";raw.json(o);o<<",\"clamped\":";clamped.json(o);o<<",\"full_vs_uninterrupted\":";full_control.json(o);o<<",\"reduced_vs_uninterrupted\":";reduced_control.json(o);o<<"}";}};
struct Sim{Vtriad m;Sim(){m.clk=0;m.ena=0;m.reset_n=0;m.hold=0;m.cs_n=1;m.a=0;m.d=0;m.addr=255;m.rd=0;m.wr=0;m.wd=0;m.eval();}void host(){m.clk=0;m.eval();m.clk=1;m.eval();hostclock++;}void tick(unsigned n=1){while(n--){m.ena=1;host();m.ena=0;for(int i=1;i<15;i++)host();}}void regwrite(int reg,int value){m.a=0;m.d=reg;m.cs_n=0;tick();m.cs_n=1;tick(5);m.a=1;m.d=value;m.cs_n=0;tick();m.cs_n=1;tick(150);}uint32_t response(int i){return i==0?m.r0:i==1?m.r1:m.r2;}int audio(int i){return signed14(i==0?m.y0:i==1?m.y1:m.y2);}std::array<uint32_t,100> capture(int instance){std::array<uint32_t,100>x;for(int w=0;w<100;w++){m.addr=w;m.rd=1;tick(3);x[w]=response(instance);}m.rd=0;return x;}};
static std::array<uint32_t,100> mask_for(const std::string&v){std::array<uint32_t,100>x;x.fill(~0u);auto omit=[&](int lo,int hi){for(int i=lo;i<=hi;i++)x[i]=0;};if(v=="control"){}else if(v=="attack")omit(91,92);else if(v=="sine")omit(98,99);else if(v=="writeback")omit(79,79);else if(v=="envelope")omit(31,48);else if(v=="phase")omit(13,30);else if(v=="feedback")omit(49,57);else if(v=="controller"){omit(80,85);x[84]=0x3f;x[85]=0x04000000;}else if(v=="macro"){omit(58,99);for(int i:{76,77,78,80,88,90,95})x[i]=~0u;x[81]=0xf;x[84]=0x3f;x[85]=0x04000000;x[87]=0x7fffe000;x[93]=0xfff80000;}else throw std::runtime_error("unknown variant");return x;}
int main(int argc,char**argv){try{Verilated::commandArgs(argc,argv);std::string variant=argc>1?argv[1]:"control";int profile=argc>2?atoi(argv[2]):0,point=argc>3?atoi(argv[3]):1;uint64_t follow=argc>4?strtoull(argv[4],0,10):7517045;int events=argc>5?atoi(argv[5]):0;int trace=argc>6?atoi(argv[6]):1;auto masks=mask_for(variant);Sim s;auto start=std::chrono::steady_clock::now();
 s.tick(5);s.m.reset_n=1;s.tick(1000);if(s.m.ready!=7)throw std::runtime_error("initializer");
 s.regwrite(0,0xe1);s.regwrite(1,0xe1);s.regwrite(2,0);s.regwrite(3,7);int ardr=profile==1?0x54:profile==2?0xf7:0xf0;int slrr=profile==2?0x85:profile==3?0x05:profile==1?0x44:0;
 s.regwrite(4,ardr);s.regwrite(5,ardr);s.regwrite(6,slrr);s.regwrite(7,slrr);s.regwrite(0x30,6);s.regwrite(0x10,0x91);s.regwrite(0x20,0x19);
 if(profile==4){for(int ch=6;ch<9;ch++){s.regwrite(0x30+ch,0x66);s.regwrite(0x10+ch,0x80+ch*11);s.regwrite(0x20+ch,0x19);}s.regwrite(14,0x3f);}
 if(profile==3){s.tick(2000);s.regwrite(0x20,0x09);}
 s.tick(1000+point);s.m.hold=7;s.tick();auto image=s.capture(0);s.m.hold=1;
 // Stale future differs musically, but no fresh commands are issued after LOAD
 // in events=0. The uninterrupted control ignores these writes while held.
 s.regwrite(0x20,0x09);s.regwrite(0x10,0x37);s.regwrite(0x30,0x10);s.regwrite(4,0x25);s.regwrite(5,0x24);s.regwrite(14,profile==4?0x20:0x3f);s.tick(21347);s.m.hold=7;s.tick();auto stale=s.capture(2);
 int changed=0,bits=0;for(int w=0;w<100;w++){uint32_t d=(image[w]^stale[w])&~masks[w];changed+=d!=0;bits+=__builtin_popcount(d);s.m.addr=w;s.m.wd=image[w];s.m.wr=2;if(masks[w]){s.m.wd=(image[w]&masks[w])|(stale[w]&~masks[w]);} // Separate writes allow partial-word masks without changing the full image.
 s.m.wd=image[w];s.m.wr=2;s.tick();s.m.wr=0;s.tick();if(masks[w]){s.m.wd=(image[w]&masks[w])|(stale[w]&~masks[w]);s.m.wr=4;s.tick();s.m.wr=0;s.tick();}}
 auto checkfull=s.capture(1),checkred=s.capture(2);for(int w=0;w<100;w++){if(checkfull[w]!=image[w])throw std::runtime_error("full roundtrip "+std::to_string(w));uint32_t expected=(image[w]&masks[w])|(stale[w]&~masks[w]);if(checkred[w]!=expected)throw std::runtime_error("reduced roundtrip "+std::to_string(w));}
 if(variant!="control"&&!changed)throw std::runtime_error("omission not exercised");
 {std::ofstream o("state.csv");o<<"word,image,stale,mask,full,reduced\n";for(int w=0;w<100;w++)o<<w<<','<<image[w]<<','<<stale[w]<<','<<masks[w]<<','<<checkfull[w]<<','<<checkred[w]<<'\n';}
 if(s.m.p0_1!=image[13]||s.m.p1_1!=image[14]||s.m.e0_1!=image[31]||s.m.e1_1!=image[32]||s.m.fb1!=image[49]||s.m.ek1!=((image[87]>>13)&0x3ffff)||s.m.pk1!=(image[95]&0x3ffff))throw std::runtime_error("debug observation packing");
 s.m.rd=0;s.m.addr=255;s.tick(8);s.m.hold=0;
 FILE*audio=fopen("audio.csv","wb");fprintf(audio,"ce,uninterrupted,full,reduced,uninterrupted_clamped,full_clamped,reduced_clamped\n");uint32_t previous_ek[3]={s.m.ek0,s.m.ek1,s.m.ek2},previous_pk[3]={s.m.pk0,s.m.pk1,s.m.pk2};uint64_t eg_on[3]={0},eg_off[3]={0},pg_on[3]={0},last_eg_on[3]={0},first_eg_on[3]={0};
 FILE*internal=fopen("internals.csv","wb");fprintf(internal,"ce,p0_u,p0_f,p0_r,p1_u,p1_f,p1_r,e0_u,e0_f,e0_r,e1_u,e1_f,e1_r,fb_u,fb_f,fb_r,egstates_u,egstates_f,egstates_r,egkey_u,egkey_f,egkey_r,pgkey_u,pgkey_f,pgkey_r\n");
 Pair total;std::array<Pair,5>segments;std::array<Pair,4>residual;std::array<uint64_t,4>marks={357955,1789773,3579545,7159090};uint64_t afterEvents=0;int eventIndex=0;const double times[]={2.10,2.12,2.20,2.30,2.40};const int regs[]={0x20,0x20,0x10,0x0e,4},values[]={0x09,0x19,0xb7,0x3f,0xf4};std::ofstream ev("events.csv");ev<<"ce,register,value\n";
 for(uint64_t t=1;t<=follow;t++){if(events&&eventIndex<5&&t>=(uint64_t)ceil(times[eventIndex]*FMHZ)){// Schedule a full ordinary I/O transaction without skipping metric clocks.
 afterEvents=1;}
 // Event state machine: address/data strobes span one enabled clock; the held
 // command then remains available until the next event, as in the old bench.
 if(events&&eventIndex<5){uint64_t e=(uint64_t)ceil(times[eventIndex]*FMHZ);if(t==e){s.m.a=0;s.m.d=regs[eventIndex];s.m.cs_n=0;ev<<t<<','<<regs[eventIndex]<<','<<values[eventIndex]<<'\n';}if(t==e+1)s.m.cs_n=1;if(t==e+6){s.m.a=1;s.m.d=values[eventIndex];s.m.cs_n=0;}if(t==e+7){s.m.cs_n=1;eventIndex++;}}
 s.tick();uint32_t ek[3]={s.m.ek0,s.m.ek1,s.m.ek2},pk[3]={s.m.pk0,s.m.pk1,s.m.pk2};for(int j=0;j<3;j++){unsigned on=__builtin_popcount(ek[j]&~previous_ek[j]);eg_on[j]+=on;eg_off[j]+=__builtin_popcount(previous_ek[j]&~ek[j]);pg_on[j]+=__builtin_popcount(pk[j]&~previous_pk[j]);if(on){last_eg_on[j]=t;if(!first_eg_on[j])first_eg_on[j]=t;}previous_ek[j]=ek[j];previous_pk[j]=pk[j];}
 if(trace&&(t%72==0||follow<=50000))fprintf(internal,"%llu,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%llu,%llu,%llu,%u,%u,%u,%u,%u,%u\n",(unsigned long long)t,s.m.p0_0,s.m.p0_1,s.m.p0_2,s.m.p1_0,s.m.p1_1,s.m.p1_2,s.m.e0_0,s.m.e0_1,s.m.e0_2,s.m.e1_0,s.m.e1_1,s.m.e1_2,s.m.fb0,s.m.fb1,s.m.fb2,(unsigned long long)s.m.estates0,(unsigned long long)s.m.estates1,(unsigned long long)s.m.estates2,ek[0],ek[1],ek[2],pk[0],pk[1],pk[2]);
 int u=s.audio(0),f=s.audio(1),r=s.audio(2);total.add(u,f,r,t);int bucket=t<=marks[0]?0:t<=marks[1]?1:t<=marks[2]?2:t<=marks[3]?3:4;segments[bucket].add(u,f,r,t);for(int j=0;j<4;j++)if(t>marks[j]-(uint64_t)ceil(.05*FMHZ)&&t<=marks[j])residual[j].add(u,f,r,t);if(trace&&(t%72==0||follow<=50000))fprintf(audio,"%llu,%d,%d,%d,%d,%d,%d\n",(unsigned long long)t,u,f,r,clamp13(u),clamp13(f),clamp13(r));if(t%1000000==0){printf("PROGRESS ce=%llu simulated_seconds=%.6f\n",(unsigned long long)t,t/FMHZ);fflush(stdout);}}
 fclose(audio);fclose(internal);s.m.hold=7;s.tick();{auto eu=s.capture(0),ef=s.capture(1),er=s.capture(2);std::ofstream end("final_state.csv");end<<"word,uninterrupted,full,reduced\n";for(int w=0;w<100;w++)end<<w<<','<<eu[w]<<','<<ef[w]<<','<<er[w]<<'\n';}{std::ofstream k("key_events.json");k<<"[";for(int j=0;j<3;j++){if(j)k<<",";k<<"{\"trajectory\":"<<j<<",\"eg_key_on_bits\":"<<eg_on[j]<<",\"eg_key_off_bits\":"<<eg_off[j]<<",\"pg_key_on_bits\":"<<pg_on[j]<<",\"first_eg_key_on\":"<<first_eg_on[j]<<",\"last_eg_key_on\":"<<last_eg_on[j]<<"}";}k<<"]\n";}double wall=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();std::ofstream o("result.json");o<<std::setprecision(16)<<"{\"variant\":\""<<variant<<"\",\"profile\":"<<profile<<",\"point\":"<<point<<",\"fm_hz\":"<<FMHZ<<",\"host_per_enable\":15,\"follow\":"<<follow<<",\"seconds\":"<<follow/FMHZ<<",\"changed_words\":"<<changed<<",\"changed_bits\":"<<bits<<",\"captured_envelopes\":[";for(int i=31;i<=48;i++)o<<(i==31?"":",")<<(image[i]>>23);o<<"],\"external_post_load_writes\":"<<eventIndex<<",\"host_clocks\":"<<hostclock<<",\"wall_seconds\":"<<wall<<",\"total\":";total.json(o);o<<",\"segments\":[";for(int i=0;i<5;i++){if(i)o<<',';segments[i].json(o);}o<<"],\"residual_50ms\":[";for(int i=0;i<4;i++){if(i)o<<',';residual[i].json(o);}o<<"]}\n";printf("PASS variant=%s profile=%d point=%d ce=%llu seconds=%.6f changed=%d last=%llu peak=%d rms=%.6f wall=%.3f\n",variant.c_str(),profile,point,(unsigned long long)follow,follow/FMHZ,changed,(unsigned long long)total.raw.last,total.raw.peak,sqrt(double(total.raw.sq/total.raw.n)),wall);return 0;
 }catch(const std::exception&e){fprintf(stderr,"FAIL %s\n",e.what());return 1;}}
