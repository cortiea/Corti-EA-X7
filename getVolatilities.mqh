enum volatFindMode{
volat_atr=0,//by atr
volat_pct=1//by % (pct)
};
enum volatCore{
volat_vol=0,//volatility
volat_bias=1,//bias
volat_reactivity=2//reactivity
};
//system for keeping tabs on correlation load first 
  //we will add the symbols and load them
    class corr_symbol{
                  public:
    user_text_var symbol;
             bool loaded;
              int attempts;
                  corr_symbol(void){reset();}
                 ~corr_symbol(void){reset();}
             void reset(){
                  symbol.reset();
                  loaded=false;
                  attempts=0;
                  } 
             void save(int file_handle){
                  symbol.save(file_handle);
                  FileWriteInteger(file_handle,((int)loaded),INT_VALUE);
                  FileWriteInteger(file_handle,attempts,INT_VALUE);
                  }
             void load(int file_handle){
                  reset();
                  symbol.load(file_handle);
                  loaded=(bool)FileReadInteger(file_handle,INT_VALUE);
                  attempts=(int)FileReadInteger(file_handle,INT_VALUE);
                  }
             
    };
    struct corr_symbols_loader{
    corr_symbol symbols[];
            int current;
                corr_symbols_loader(void){reset();}
               ~corr_symbols_loader(void){reset();}
           void reset(){
                ArrayFree(symbols);
                current=-1;
                }
           void add_symbol(string _symbol){
                int ns=ArraySize(symbols)+1;
                ArrayResize(symbols,ns,0);
                symbols[ns-1].symbol=_symbol;
                }
         string get_symbol_not_this(string _not_this){
                for(int i=0;i<ArraySize(symbols);i++){ 
                   if(symbols[i].symbol!=_not_this){
                     return(symbols[i].symbol.to_string());
                     }
                   }
                return(NULL);
                }
           bool needs_load(){
                for(int i=0;i<ArraySize(symbols);i++){
                   if(symbols[i].loaded==false){
                     return(true);
                     }
                   }
                return(false);
                }
            int test_data(ENUM_TIMEFRAMES _tf,int _total){
                for(int i=0;i<ArraySize(symbols);i++){
                   symbols[i].loaded=test_data(symbols[i].symbol.to_string(),_tf,_total);
                     if(symbols[i].loaded==false){
                     return(i);
                     }
                   }
                return(-1);//-1 means okay all
                }
           void save(string folder,string filename){
                string location=folder+"\\"+filename;
                if(FileIsExist(location)){FileDelete(location);}
                int f=FileOpen(location,FILE_WRITE|FILE_BIN);
                if(f!=INVALID_HANDLE){
                //#
                FileWriteInteger(f,ArraySize(symbols),INT_VALUE);
                //
                for(int i=0;i<ArraySize(symbols);i++){ 
                   symbols[i].save(f);
                   }
                FileWriteInteger(f,current,INT_VALUE);
                FileClose(f);
                }
                }
           bool load(string folder,string filename){
                bool loaded=false;
                reset();
                string location=folder+"\\"+filename;
                if(FileIsExist(location)){
                int f=FileOpen(location,FILE_READ|FILE_BIN);
                if(f!=INVALID_HANDLE){
                //#
                int total=(int)FileReadInteger(f,INT_VALUE);
                //
                if(total>0){
                  ArrayResize(symbols,total,0);
                  for(int i=0;i<total;i++){
                     symbols[i].load(f);
                     }
                  }
                current=(int)FileReadInteger(f,INT_VALUE);
                loaded=true;
                FileClose(f);
                //check consistency
                  /*
                  if a symbol is in marketwatch but not here , false
                  if a symbol is here and not in marketwatch , remove it
                  
                  */
                  corr_symbol test_symbols[];
                  int test_total=0;
                  //pass 1 how many are in market watch ? 
                    for(int i=0;i<ArraySize(symbols);i++){
                       string search=symbols[i].symbol.to_string();
                       if(is_in_market_watch(search)){
                         test_total++;
                         ArrayResize(test_symbols,test_total,0);
                         test_symbols[test_total-1]=symbols[i];
                         }
                       }
                  //pass back
                    ArrayResize(symbols,ArraySize(test_symbols),0);
                    if(ArraySize(symbols)==0){return(false);}
                    for(int i=0;i<ArraySize(symbols);i++){
                    symbols[i]=test_symbols[i];
                    }
                  //pass 2 are there symbols in mw not in here ?
                    int mw=SymbolsTotal(true);
                    for(int i=0;i<mw;i++){
                    string search=SymbolName(i,true);
                    bool found=false;
                    for(int j=0;j<ArraySize(symbols);j++){
                       if(symbols[j].symbol==search){
                         found=true;
                         break;
                         }
                       }
                    if(found==false){return(false);}
                    }
                //
                }}
                return(loaded);
                }
    };
    bool has_2_currencies(string _name){
         int currencies=0;
         string currs[]={"EUR","USD","CAD","CHF","JPY","AUD","NZD","GBP"};
         for(int i=0;i<ArraySize(currs);i++){ 
            if(StringFind(_name,currs[i],0)!=-1){
              currencies++;
              }
            } 
         return((bool)(currencies>=2));
         }
    bool is_in_market_watch(string _symbol){
         int syt=SymbolsTotal(true);
         for(int i=0;i<syt;i++){
            if(SymbolName(i,true)==_symbol){
              return(true);
              }
            }
         return(false);
         }
    bool is_probably_forex(string _name,string _prefix,string _suffix){
         if(StringLen(_prefix)>0){int rep=StringReplace(_name,_prefix,"");}
         if(StringLen(_suffix)>0){int rep=StringReplace(_name,_suffix,"");}
         string more_currs[]={"AUD","CAD","CHF","CNH","DKK",
                              "EUR","GBP","HUF","HKD","JPY",
                              "MXN","NOK","NZD","PLN","SGD",
                              "SEK","TRY","USD","ZAR"};
         int currencies=0;
         for(int i=0;i<ArraySize(more_currs);i++){
            //base
              if(StringFind(_name,more_currs[i],0)==0){currencies++;}
            //quote
              else if(StringFind(_name,more_currs[i],3)==3){currencies++;}
            }
         return((bool)(currencies==2));
         }
    bool test_data(string _symbol,ENUM_TIMEFRAMES _tf,int total){
         bool okay=true;
         int errors=0;
         for(int i=0;i<=total;i++){
            ResetLastError();
            double o=iOpen(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            double h=iHigh(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            double l=iLow(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            double c=iClose(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            }
         if(errors!=0){okay=false;}
         return(okay);
         }

bool findSymbol(string first,
                string second,
                string prefix="",
                string suffix=""){
string seeking=prefix+first+second+suffix;
for(int i=0;i<SymbolsTotal(false);i++){
if(SymbolName(i,false)==seeking){
  return(true);
  }
}
return(false);
}

bool checkVolatilities(ENUM_TIMEFRAMES _tf,int _max_period,volatFindMode mode,volatCore core,string &result_symbol){
result_symbol="";
  if(CORR_LOADING){
  EventKillTimer();
  //loop
    int move_to=CORRLOADER.test_data(_tf,_max_period);
    //if move to is -1 we loaded 
      if(move_to==-1){
      CORR_LOADING=false;
      CORRLOADER.save(CORR_Folder,CORR_File);
      }
      else if(move_to!=-1){
        //case a : we are not on the symbol to load - > go to it
          if(CORRLOADER.symbols[move_to].symbol!=_Symbol){
            CORRLOADER.current=move_to;
            CORRLOADER.save(CORR_Folder,CORR_File);
            ChartSetSymbolPeriod(ChartID(),CORRLOADER.symbols[move_to].symbol.to_string(),_tf);
            }
        //case b : we are on the symbol to load -> go to another one and come back
          else if(CORRLOADER.symbols[move_to].symbol==_Symbol){
            CORRLOADER.save(CORR_Folder,CORR_File);
            string newsymbol=CORRLOADER.get_symbol_not_this(_Symbol);
            ChartSetSymbolPeriod(ChartID(),newsymbol,_tf);
            }
        }
  
  }
  if(CORR_LOADING==false){
  //find volatilities 
    double max_correlation=-1.0;
    string max_a=NULL,max_b=NULL;

    //loop to symbols a 
      int max_i=-1;
      double max=0.0;
    for(int a=0;a<ArraySize(CORRLOADER.symbols);a++){   
       //all of them are based on volatility ! 
       double this_value=0.0;
       //if atr
         if(mode==volat_atr){
         this_value=iATR(CORRLOADER.symbols[a].symbol.to_string(),_tf,_max_period,1);
         }
       //if pct
         else{
         double this_div=0.0;
         for(int i=1;i<=_max_period;i++){
            double range=iHigh(CORRLOADER.symbols[a].symbol.to_string(),_tf,i)-iLow(CORRLOADER.symbols[a].symbol.to_string(),_tf,i);
            range/=iClose(CORRLOADER.symbols[a].symbol.to_string(),_tf,i+1);
            this_div+=1.0;
            this_value+=range;
            }
         if(this_div>0.0){
           this_value/=this_div;
           }
         }
       if(this_value>max&&core==volat_vol){
         max_i=a;
         max=this_value;
         }
       //bias 
         if(core==volat_bias){
         double up_bias=0.0,dw_bias=0.0,full_bias=0.0;
         for(int i=1;i<=_max_period;i++){
            double _c=iClose(CORRLOADER.symbols[a].symbol.to_string(),_tf,i);
            double _o=iOpen(CORRLOADER.symbols[a].symbol.to_string(),_tf,i);
            if(_c>_o){
              up_bias+=_c-_o;
              }
            else{
              dw_bias+=_o-_c;
              }
            full_bias+=MathAbs(_o-_c);
            }
         if(full_bias>0.0){
           //we get "how much is an up how much is a down"
             up_bias/=full_bias;
             dw_bias/=full_bias;
             double bias_=MathMax(up_bias,dw_bias)*this_value;
             if(bias_>max){
             max_i=a;
             max=bias_;
             }
           }         
         }
       //reac
         if(core==volat_reactivity){
         double up_r=0.0,dw_r=0.0,full_r=0.0;
         for(int i=1;i<=_max_period;i++){
            double _c=iClose(CORRLOADER.symbols[a].symbol.to_string(),_tf,i);
            double _o=iOpen(CORRLOADER.symbols[a].symbol.to_string(),_tf,i);
            double _h=iHigh(CORRLOADER.symbols[a].symbol.to_string(),_tf,i);
            double _l=iLow(CORRLOADER.symbols[a].symbol.to_string(),_tf,i);
            if(_c>_o){
              /*
              if bar is bullish the reactivity is what ?
              the open to the low (so what did the bears push for)
              */
              dw_r+=(_o-_l)/(_c-_o);
              full_r+=(_o-_l)/(_c-_o);
              }
            else if(_o>_c){
              /*
              if bar is bearish the reactivity is the high to the open
              */
              up_r+=(_h-_o)/(_o-_c);
              full_r+=(_h-_o)/(_o-_c);
              }
            }
         if(full_r>0.0){
             /*
             why we don't get the total reactivity ? 
             a high total reactivity may indicate a ranger!
             */
             up_r/=full_r;
             dw_r/=full_r;
             double reac_=MathMax(up_r,dw_r)*this_value;
             if(reac_>max){
             max_i=a;
             max=reac_;
             }
           }         
         }
       }
       //so we come out here we have the max 
       //we should do what ? send it to the main ea
       result_symbol=CORRLOADER.symbols[max_i].symbol.to_string();
       EventKillTimer();
       while(!EventSetTimer(1)){
       Sleep(100);
       }
       return(true);
  }//if correlation not loading ends here
return(false);
}