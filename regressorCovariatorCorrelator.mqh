#property strict
class regressor_stat_item{
//y is the dependent variable 
//x is the independent variable
public:
double x,y;
regressor_stat_item(void){x=0.0;y=0.0;}
double get_dependent(){return(y);}
double get_independent(){return(x);}
void set_dependent(double _value){y=_value;}
void set_independent(double _value){x=_value;}
};
class regressor_stat{
regressor_stat_item samples[];
       public:
double covariance,correlation,avg_x,avg_y,std_x,std_y;
double slope,intercept;
int items;
bool full;
     regressor_stat(void){reset();}
     regressor_stat(int max_samples){reset(max_samples);}
    ~regressor_stat(void){reset(0);}
void reset(int max_samples=5){
     ArrayFree(samples);
     if(max_samples>0){ArrayResize(samples,max_samples,0);}
     covariance=0.0;
     correlation=0.0;
     avg_x=0.0;
     avg_y=0.0;
     std_x=0.0;
     std_y=0.0;
     slope=0.0;
     intercept=0.0;
     items=0;
     full=false;
     }
void add_sample(double _dependent_variable,double _independent_variable){
     items++;
     if(items<=ArraySize(samples)){
     samples[items-1].set_dependent(_dependent_variable);
     samples[items-1].set_independent(_independent_variable);
     if(items==ArraySize(samples)&&items>1){full=true;}
     }else{
     Print("Regressor stat cannot receive more samples , check the samples initialized with");
     }
     }
void calculate(){ 
     if(full)
     {
     //means 
       for(int i=0;i<items;i++){
       avg_x+=samples[i].get_independent();
       avg_y+=samples[i].get_dependent();
       }
       avg_x/=((double)items);
       avg_y/=((double)items);
     //standard deviations 
       for(int i=0;i<items;i++){
       std_x+=MathPow((samples[i].get_independent()-avg_x),2.0);
       std_y+=MathPow((samples[i].get_dependent()-avg_y),2.0);
       }
       std_x/=((double)items-1.0);
       std_y/=((double)items-1.0);
     //covariance 
       for(int i=0;i<items;i++){
       covariance+=(samples[i].x-avg_x)*(samples[i].y-avg_y);
       }
       covariance/=((double)items-1.0);
     //correlation
       correlation=0.0;
       if(std_x>0.0&&std_y>0.0){
       correlation=covariance/(MathSqrt(std_x)*MathSqrt(std_y));
       }
     //slope 
       double slope_a=0.0,slope_b=0.0;
       for(int i=0;i<items;i++){
       slope_a+=(samples[i].x-avg_x)*(samples[i].y-avg_y);
       slope_b+=MathPow((samples[i].x-avg_x),2.0);
       }
       slope=0.0;
       if(slope_b>0.0){
       slope=slope_a/slope_b;
       }
     //intercept
       intercept=avg_y-slope*avg_x;
     }
     }
bool get_estimate(double _for_x_or_independent,double &result_y){
     if(full){
     result_y=slope*_for_x_or_independent+intercept;
     return(true);
     }
     return(false);
     }
};

/*
int OnInit()
  {
//---
  //based on example : https://www.youtube.com/watch?v=Qa2APhWjQPc&list=PLIeGtxpvyG-LoKUpV0fSY8BGKIMIdmfCi&index=3
  regressor_stat BLA(6);
  BLA.add_sample(5,34);
  BLA.add_sample(17,108);
  BLA.add_sample(11,64);
  BLA.add_sample(8,88);
  BLA.add_sample(14,99);
  BLA.add_sample(5,51);
  BLA.calculate();
  Print("Mean X : "+BLA.avg_x);
  Print("Mean Y : "+BLA.avg_y);
  Print("Slope : "+BLA.slope);
  Print("Intercept : "+BLA.intercept);
  Print("Covariance : "+BLA.covariance);
  Print("Correlation : "+BLA.correlation);
  
//---
   return(INIT_SUCCEEDED);
  }
*/
