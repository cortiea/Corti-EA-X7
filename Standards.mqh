//Period to Timeframe 
ENUM_TIMEFRAMES PeriodToTF(int period)
{
if(period==1) return(PERIOD_M1);
if(period==5) return(PERIOD_M5);
if(period==15) return(PERIOD_M15);
if(period==30) return(PERIOD_M30);
if(period==60) return(PERIOD_H1);
if(period==240) return(PERIOD_H4);
if(period==1440) return(PERIOD_D1);
if(period==10080) return(PERIOD_W1);
if(period==43200) return(PERIOD_MN1);
return(PERIOD_CURRENT);
}
int TFToPeriod(ENUM_TIMEFRAMES tf)
{
if(tf==PERIOD_CURRENT) return(Period());
if(tf==PERIOD_M1) return(1);
if(tf==PERIOD_M5) return(5);
if(tf==PERIOD_M15) return(15);
if(tf==PERIOD_M30) return(30);
if(tf==PERIOD_H1) return(60);
if(tf==PERIOD_H4) return(240);
if(tf==PERIOD_D1) return(1440);
if(tf==PERIOD_W1) return(10080);
if(tf==PERIOD_MN1) return(43200);
return(Period());
}
//Timeframe To String 
string TFtoString(ENUM_TIMEFRAMES TF)
{
string returnio="";
if(TF==PERIOD_M1) returnio="M1";
if(TF==PERIOD_M5) returnio="M5";
if(TF==PERIOD_M15) returnio="M15";
if(TF==PERIOD_M30) returnio="M30";
if(TF==PERIOD_H1) returnio="H1";
if(TF==PERIOD_H4) returnio="H4";
if(TF==PERIOD_D1) returnio="D1";
if(TF==PERIOD_W1) returnio="W1";
if(TF==PERIOD_MN1) returnio="MN1";
return(returnio);
}

ENUM_TIMEFRAMES StringToTF(string tf)
{
if(tf=="M1"){return(PERIOD_M1);}
if(tf=="M5"){return(PERIOD_M5);}
if(tf=="M15"){return(PERIOD_M15);}
if(tf=="M30"){return(PERIOD_M30);}
if(tf=="H1"){return(PERIOD_H1);}
if(tf=="H4"){return(PERIOD_H4);}
if(tf=="D1"){return(PERIOD_D1);}
if(tf=="W1"){return(PERIOD_W1);}
if(tf=="MN1"){return(PERIOD_MN1);}
return(PERIOD_CURRENT);
}

//For Save Load
bool StringToBoolean(string value){
bool tu=StringToUpper(value);
if(tu)
  {
  if(StringFind(value,"TRUE",0)!=-1){return(true);}
  if(StringFind(value,"FALSE",0)!=-1){return(false);}
  if(StringFind(value,"0",0)!=-1){return(false);}
  if(StringFind(value,"1",0)!=-1){return(true);}
  }
return(false);
}

string BooleanToString(bool v){
if(v){return("TRUE");}
return("FALSE");
}

string TimeToTimestampString(datetime time){
ulong v=(ulong)time;
return(IntegerToString(v));
}

datetime TimeStampStringToTime(string value){
ulong v=(ulong)StringToInteger(value);
return((datetime)v);
}

ENUM_TIMEFRAMES FindHigherTimeframe(ENUM_TIMEFRAMES tf)
{
if(tf==PERIOD_M1){return(PERIOD_M5);}
if(tf==PERIOD_M5){return(PERIOD_M15);}
if(tf==PERIOD_M15){return(PERIOD_M30);}
if(tf==PERIOD_M30){return(PERIOD_H1);}
if(tf==PERIOD_H1){return(PERIOD_H4);}
if(tf==PERIOD_H4){return(PERIOD_D1);}
if(tf==PERIOD_D1){return(PERIOD_W1);}
if(tf==PERIOD_W1){return(PERIOD_MN1);}
if(tf==PERIOD_MN1){return(PERIOD_MN1);}
return(PERIOD_CURRENT);
}

 
struct two_ints
{
int left,right;
two_ints(void){left=0;right=0;}
};
two_ints LongTwoInts(long v)
{
two_ints result;
result.right=(int)(v);
if(v>=0){result.left=(int)(v>>32);}
if(v<0){result.left=(int)((v*(-1))>>32)*(-1);}
return(result);
}
two_ints DatetimeTwoInts(datetime v)
{
two_ints result;
result.right=(int)(v);
result.left=(int)(v>>32);
return(result);
}
long TwoIntsLong(int left,int right)
{
long result=(((long)left)<<32)+((long)right);
return(result);
}
datetime TwoIntsDatetime(int left,int right)
{
datetime result=(datetime)((((ulong)left)<<32)+((ulong)right));
return(result);
}
bool DoesSymbolExist(string the_symbol,bool selected)
{
int sytotal=SymbolsTotal(selected);
for(int s=0;s<sytotal;s++){
if(the_symbol==SymbolName(s,selected)){return(true);}
}
return(false);
}

string get_program_location_and_name_indicators(){
  string at=__PATH__;
  int leng=StringLen(at);
  string seek_what="\\MQL5\\Indicators\\";
  int sw_leng=StringLen(seek_what);
  int find=StringFind(at,seek_what,0);
  string ne=StringSubstr(at,find+sw_leng,leng-(sw_leng));
  int rep=StringReplace(ne,".mq5",".ex5");
  return(ne);
}
string get_program_location_and_name_experts(){
  string at=__PATH__;
  int leng=StringLen(at);
  string seek_what="\\MQL5\\Experts\\";
  int sw_leng=StringLen(seek_what);
  int find=StringFind(at,seek_what,0);
  string ne=StringSubstr(at,find+sw_leng,leng-(sw_leng));
  int rep=StringReplace(ne,".mq5",".ex5");
  return(ne);
}

int TimeUnixWeek(datetime time){
MqlDateTime mt;
bool turn=TimeToStruct(time,mt);
//go back X days depending on day of week
int backtrack=(mt.day_of_week+1)*86400;
datetime a_saturday=(datetime)(time-backtrack);
//divide by weekly seconds 7*86400 ,mathfloor is the unix week index !
int week_seconds=7*86400;
double week_index=MathFloor(((double)a_saturday)/((double)(week_seconds)));
return(((int)week_index));
}

int TimeUnix4H(datetime time){
int seconds_4h=60*60*4;
double index_4h=MathFloor(((double)time)/((double)(seconds_4h)));
return(((int)index_4h));
}

int TimeUnixMinutesSlot(datetime time,int slot_duration_in_minutes){
int seconds_slot=slot_duration_in_minutes*60;
double index_slot=MathFloor(((double)time)/((double)(seconds_slot)));
return(((int)index_slot));
}
