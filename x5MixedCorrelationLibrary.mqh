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
           bool load(string folder,string filename,string prefix,string suffix){
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
                    if(is_probably_forex(search,prefix,suffix)&&AllowSymbol(search,prefix,suffix)){
                    bool found=false;
                    for(int j=0;j<ArraySize(symbols);j++){
                       if(symbols[j].symbol==search){
                         found=true;
                         break;
                         }
                       }
                    if(found==false){return(false);}
                    }
                    }
                //
                }}
                return(loaded);
                }
    };
    bool is_in_market_watch(string _symbol){
         int syt=SymbolsTotal(true);
         for(int i=0;i<syt;i++){
            if(SymbolName(i,true)==_symbol){
              return(true);
              }
            }
         return(false);
         }
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
bool definately_different(string a,string b){
if(StringFind(a,b,0)!=-1){return(false);}
if(StringFind(b,a,0)!=-1){return(false);}
return(true);
}
bool both_tradable(string a,string b,datetime now){
if(IsTradeAllowed(a,now)&&IsTradeAllowed(b,now)){return(true);}
return(false);
}
class swap_correlated_pair{
       public:
string symbol_a,symbol_b;
double correlation;
double symbol_a_swap_buy,symbol_a_swap_sell,symbol_b_swap_buy,symbol_b_swap_sell;
string a_swap_calc_mode,b_swap_calc_mode;
string a_base,a_margin,b_base,b_margin;
double point_a,point_b;
double spread_a,spread_b;
double spread_a_cost,spread_b_cost;
double swap_a_buy_cost,swap_a_sell_cost,swap_b_buy_cost,swap_b_sell_cost;
double covariance;
       swap_correlated_pair(void){reset();}
      ~swap_correlated_pair(void){reset();}
  void reset(){
       a_swap_calc_mode=NULL;
       b_swap_calc_mode=NULL;
       symbol_a=NULL;
       symbol_b=NULL;
       correlation=0.0;
       symbol_a_swap_buy=0.0;
       symbol_a_swap_sell=0.0;
       symbol_b_swap_buy=0.0;
       symbol_b_swap_sell=0.0;
       }
  void setup(string _symbol_a,
             string _symbol_b,
             double _correlation,
             double _covariance,
             string prefix="",
             string suffix=""){
       symbol_a=_symbol_a;
       symbol_b=_symbol_b;
       correlation=_correlation;
       covariance=_covariance;
       int errors=1;ResetLastError();
       while(errors>0){
       errors=0;
       double a_buy_swap=(double)SymbolInfoDouble(symbol_a,SYMBOL_SWAP_LONG);
       errors+=GetLastError();ResetLastError();
       double a_sell_swap=(double)SymbolInfoDouble(symbol_a,SYMBOL_SWAP_SHORT);
       errors+=GetLastError();ResetLastError();
       double b_buy_swap=(double)SymbolInfoDouble(symbol_b,SYMBOL_SWAP_LONG);
       errors+=GetLastError();ResetLastError();
       double b_sell_swap=(double)SymbolInfoDouble(symbol_b,SYMBOL_SWAP_SHORT);
       errors+=GetLastError();ResetLastError();   
       int swap_a_mode=(int)MarketInfo(symbol_a,MODE_SWAPTYPE);
       errors+=GetLastError();ResetLastError();
       int swap_b_mode=(int)MarketInfo(symbol_b,MODE_SWAPTYPE); 
       errors+=GetLastError();ResetLastError();
       a_base=(string)SymbolInfoString(symbol_a,SYMBOL_CURRENCY_BASE);
       errors+=GetLastError();ResetLastError();
       a_margin=(string)SymbolInfoString(symbol_a,SYMBOL_CURRENCY_MARGIN);
       errors+=GetLastError();ResetLastError();
       b_base=(string)SymbolInfoString(symbol_b,SYMBOL_CURRENCY_BASE);
       errors+=GetLastError();ResetLastError();
       b_margin=(string)SymbolInfoString(symbol_b,SYMBOL_CURRENCY_MARGIN);
       errors+=GetLastError();ResetLastError();
       point_a=(double)SymbolInfoDouble(symbol_a,SYMBOL_POINT);
       errors+=GetLastError();ResetLastError();
       point_b=(double)SymbolInfoDouble(symbol_b,SYMBOL_POINT);
       errors+=GetLastError();ResetLastError();
       spread_a=(double)SymbolInfoDouble(symbol_a,SYMBOL_ASK);
       errors+=GetLastError();ResetLastError();
       spread_a-=(double)SymbolInfoDouble(symbol_a,SYMBOL_BID);
       errors+=GetLastError();ResetLastError();
       if(point_a>0.0){spread_a/=point_a;}else{errors++;}
       spread_b=(double)SymbolInfoDouble(symbol_b,SYMBOL_ASK);
       errors+=GetLastError();ResetLastError();
       spread_b-=(double)SymbolInfoDouble(symbol_b,SYMBOL_BID);
       errors+=GetLastError();ResetLastError();
       if(point_b>0.0){spread_b/=point_b;}else{errors++;}
       double tvol_a=(double)SymbolInfoDouble(symbol_a,SYMBOL_TRADE_TICK_VALUE);
       errors+=GetLastError();ResetLastError();
       double tvol_b=(double)SymbolInfoDouble(symbol_b,SYMBOL_TRADE_TICK_VALUE);
       errors+=GetLastError();ResetLastError();
       if(errors==0){
         symbol_a_swap_buy=a_buy_swap;
         symbol_a_swap_sell=a_sell_swap;
         symbol_b_swap_buy=b_buy_swap;
         symbol_b_swap_sell=b_sell_swap;
         a_swap_calc_mode=swaptype_to_string(swap_a_mode);
         b_swap_calc_mode=swaptype_to_string(swap_b_mode);
         spread_a_cost=spread_a*tvol_a;
         spread_b_cost=spread_b*tvol_b;
         //swap types 
           //A
             if(a_swap_calc_mode=="POINTS"){
               swap_a_buy_cost=tvol_a*symbol_a_swap_buy;
               swap_a_sell_cost=tvol_a*symbol_a_swap_sell;
               }
             else if(a_swap_calc_mode=="BASE.CURRENCY"){
               swap_a_buy_cost=toAccountCoin(symbol_a_swap_buy,a_base,prefix,suffix);
               swap_a_sell_cost=toAccountCoin(symbol_a_swap_sell,a_base,prefix,suffix);
               }
             else if(a_swap_calc_mode=="MARGIN.CURRENCY"){
               swap_a_buy_cost=toAccountCoin(symbol_a_swap_buy,a_margin,prefix,suffix);
               swap_a_sell_cost=toAccountCoin(symbol_a_swap_sell,a_margin,prefix,suffix);
               }//interest ???
             else{swap_a_buy_cost=0.0;swap_a_sell_cost=0.0;}
             
           //B
             if(b_swap_calc_mode=="POINTS"){
               swap_b_buy_cost=tvol_b*symbol_b_swap_buy;
               swap_b_sell_cost=tvol_b*symbol_b_swap_sell;
               }
             else if(b_swap_calc_mode=="BASE.CURRENCY"){
               swap_b_buy_cost=toAccountCoin(symbol_b_swap_buy,b_base,prefix,suffix);
               swap_b_sell_cost=toAccountCoin(symbol_b_swap_sell,b_base,prefix,suffix);
               }
             else if(b_swap_calc_mode=="MARGIN.CURRENCY"){
               swap_b_buy_cost=toAccountCoin(symbol_b_swap_buy,b_margin,prefix,suffix);
               swap_b_sell_cost=toAccountCoin(symbol_b_swap_sell,b_margin,prefix,suffix);
               }//interest ???
             else{swap_b_buy_cost=0.0;swap_b_sell_cost=0.0;}          
         }   
       }
       }
};

struct swapPairs{
swap_correlated_pair pairs[];
       swapPairs(void){reset();}
      ~swapPairs(void){reset();}
  void reset(){
       ArrayFree(pairs);
       }    
   int add_pair(string symbol_a,
                string symbol_b,
                double correlation,
                double covariance,
                string prefix="",
                string suffix=""){
       int ns=ArraySize(pairs)+1;
       ArrayResize(pairs,ns,0);
       pairs[ns-1].setup(symbol_a,symbol_b,correlation,covariance,prefix,suffix);
       return(ns-1);
       }
  void save_to_excel(int f,double threshold,bool only_viable){
       string separator=";";
       string new_line="\n";
       string coin=AccountCurrency()+"/1Lot";
       FileWriteString(f,"A"+separator+"B"+separator+"Correlation"+separator+"Covariance"+separator+"A::Spread"+separator+"B::Spread"+separator+"A::BuySwap"+separator+"A::SellSwap"+separator+"B::BuySwap"+separator+"B::SellSwap"+separator+"Corr,BuyA+SellB"+separator+"Corr,SellA+BuyB"+separator+"InvCorr,BuyA+BuyB"+separator+"InvCorr,SellA+SellB"+separator+"TypeA"+separator+"TypeB"+separator+"A::BASE"+separator+"A::MARGIN"+separator+"B::BASE"+separator+"B::MARGIN"+separator+new_line);
       double neg_threshold=threshold*(-1.0);
       for(int i=0;i<ArraySize(pairs);i++){
          string buy_a_sell_b="Nope";
          string sell_a_buy_b="Nope";
          string buy_a_buy_b="Nope";
          string sell_a_sell_b="Nope";
          //positive correlation 
            if(pairs[i].correlation>=threshold){
              //positive swap on buy a 
                if(pairs[i].symbol_a_swap_buy>0.0){
                  //positive swap on sell b
                    if(pairs[i].symbol_b_swap_sell>0.0){
                      buy_a_sell_b="Yes";
                      }
                  }
              //positive swap on sell a 
                if(pairs[i].symbol_a_swap_sell>0.0){
                  //positive swap on buy b
                    if(pairs[i].symbol_b_swap_buy>0.0){
                      sell_a_buy_b="Yes";
                      }
                  }
              }
          //negative correlation
            else if(pairs[i].correlation<=neg_threshold){
              //positive swap on buy a 
                if(pairs[i].symbol_a_swap_buy>0.0){
                  //positive swap on buy b
                    if(pairs[i].symbol_b_swap_buy>0.0){
                      buy_a_buy_b="Yes";
                      }
                  }
              //positive swap on sell a 
                if(pairs[i].symbol_a_swap_sell>0.0){
                  //positive swap on sell b
                    if(pairs[i].symbol_b_swap_sell>0.0){
                      sell_a_sell_b="Yes";
                      }
                  }              
              }
          //write all or viable
          if(!only_viable||(buy_a_buy_b=="Yes"||buy_a_sell_b=="Yes"||sell_a_buy_b=="Yes"||sell_a_sell_b=="Yes")){
          string data=pairs[i].symbol_a+separator+pairs[i].symbol_b+separator+DoubleToString(pairs[i].correlation,2)+separator+DoubleToString(pairs[i].covariance,5)+separator+DoubleToString(pairs[i].spread_a,0)+"["+DoubleToString(pairs[i].spread_a_cost,2)+coin+"]"+separator+DoubleToString(pairs[i].spread_b,0)+"["+DoubleToString(pairs[i].spread_b_cost,2)+coin+"]"+separator+DoubleToString(pairs[i].symbol_a_swap_buy,2)+"["+DoubleToString(pairs[i].swap_a_buy_cost,2)+coin+"]"+separator+DoubleToString(pairs[i].symbol_a_swap_sell,2)+"["+DoubleToString(pairs[i].swap_a_sell_cost,2)+coin+"]"+separator+DoubleToString(pairs[i].symbol_b_swap_buy,2)+"["+DoubleToString(pairs[i].swap_b_buy_cost,2)+coin+"]"+separator+DoubleToString(pairs[i].symbol_b_swap_sell,2)+"["+DoubleToString(pairs[i].swap_b_sell_cost,2)+coin+"]"+separator+buy_a_sell_b+separator+sell_a_buy_b+separator+buy_a_buy_b+separator+sell_a_sell_b+separator+pairs[i].a_swap_calc_mode+separator+pairs[i].b_swap_calc_mode+separator+pairs[i].a_base+separator+pairs[i].a_margin+separator+pairs[i].b_base+separator+pairs[i].b_margin+separator+new_line;
          StringReplace(data,".",",");
          FileWriteString(f,data);
          }
          }
       }
};

swapPairs SP;

string swaptype_to_string(int type){
if(type==0){return("POINTS");}
if(type==1){return("BASE.CURRENCY");}
if(type==2){return("INTEREST");}
if(type==3){return("MARGIN.CURRENCY");}
return("ERROR");
}

double toAccountCoin(double value,
                     string fromCoin,
                     string prefix="",
                     string suffix=""){
//if not the same 
  string AccountCoin=AccountCurrency();
  if(AccountCoin!=fromCoin){
  //find quotation AAAFFF
    if(findSymbol(AccountCoin,fromCoin,prefix,suffix)){
      //get quote average ask + bid
        string sym=prefix+AccountCoin+fromCoin+suffix;
        int errors=1;
        while(errors>0){
             errors=0;
             double ask=(double)SymbolInfoDouble(sym,SYMBOL_ASK);
             errors+=GetLastError();ResetLastError();
             double bid=(double)SymbolInfoDouble(sym,SYMBOL_BID);
             errors+=GetLastError();ResetLastError();
             if(errors==0){
               /*
               EURUSD means how many usd you get for 1 euro
               but we have acc-from so we would need euros instead of 
               usd in this example 
               So we'd do 1/rate
               */
               double cost=(ask+bid)/2.0;
               cost=1/cost;
               //and then turn the values 
                 value*=cost;
                 return(value);
               }
             }
      }
  //find quotation FFFAAA
    if(findSymbol(fromCoin,AccountCoin,prefix,suffix)){
      //get quote average ask + bid
        string sym=prefix+fromCoin+AccountCoin+suffix;
        int errors=1;
        while(errors>0){
             errors=0;
             double ask=(double)SymbolInfoDouble(sym,SYMBOL_ASK);
             errors+=GetLastError();ResetLastError();
             double bid=(double)SymbolInfoDouble(sym,SYMBOL_BID);
             errors+=GetLastError();ResetLastError();
             if(errors==0){
               /*
               EURUSD means how many usd you get for 1 euro
               this is a direct quotation so ... 
               */
               double cost=(ask+bid)/2.0;
               //and then turn the values 
                 value*=cost;
                 return(value);
               }
             }      
      }
  }else{
  if(StringLen(AccountCoin)>0){
    return(value);
    }
  }
return(0.0);//error code
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
//and the holder of the combos for the system 

bool checkCorrelations(string prefix,string suffix){
  if(CORR_LOADING){
  EventKillTimer();
  //loop
    int move_to=CORRLOADER.test_data(COMBOS_CORR_tf,COMBOS_CORR_period);
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
            ChartSetSymbolPeriod(ChartID(),CORRLOADER.symbols[move_to].symbol.to_string(),COMBOS_CORR_tf);
            }
        //case b : we are on the symbol to load -> go to another one and come back
          else if(CORRLOADER.symbols[move_to].symbol==_Symbol){
            CORRLOADER.save(CORR_Folder,CORR_File);
            string newsymbol=CORRLOADER.get_symbol_not_this(_Symbol);
            ChartSetSymbolPeriod(ChartID(),newsymbol,COMBOS_CORR_tf);
            }
        }
  
  }
  if(CORR_LOADING==false){
  //if market is not closed
  if(IsTradeAllowed()){
  //find correlations 
    double max_correlation=-1.0;
    string max_a=NULL,max_b=NULL;
    regressor_stat REG(COMBOS_CORR_period);
    //loop to symbols a of
    for(int a=0;a<ArraySize(CORRLOADER.symbols);a++){      
    bool allow_symbol_a=AllowSymbol(CORRLOADER.symbols[a].symbol.to_string(),prefix,suffix);
    if(allow_symbol_a){
       //loop to symbols b with
         for(int b=1;b<ArraySize(CORRLOADER.symbols);b++){
            REG.reset(COMBOS_CORR_period);
            if(a!=b&&AllowSymbol(CORRLOADER.symbols[b].symbol.to_string(),prefix,suffix)){
            //loop into the samples 
               for(int s=1;s<=COMBOS_CORR_period;s++){
                  //get close of a 
                    double close_of_a=iClose(CORRLOADER.symbols[a].symbol.to_string(),COMBOS_CORR_tf,s);
                  //get close of b
                    double close_of_b=iClose(CORRLOADER.symbols[b].symbol.to_string(),COMBOS_CORR_tf,s);     
                  //add samples 
                    REG.add_sample(close_of_a,close_of_b);
                  }
            //loop into the samples ends here
            //calculate 
              REG.calculate();
          if(definately_different(CORRLOADER.symbols[a].symbol.to_string(),CORRLOADER.symbols[b].symbol.to_string())){
          if(both_tradable(CORRLOADER.symbols[a].symbol.to_string(),CORRLOADER.symbols[b].symbol.to_string(),Time[0])){
              //Print("DefDiff ::("+CORRLOADER.symbols[a].symbol.to_string()+")vs("+CORRLOADER.symbols[b].symbol.to_string()+")");
                  //i use Time[0] because we might have to wait 
              SP.add_pair(CORRLOADER.symbols[a].symbol.to_string(),CORRLOADER.symbols[b].symbol.to_string(),REG.correlation,REG.covariance,Prefix,Suffix);
            }}
            }//if not same symbol ends here
            }
       //loop to symbols b with ends here
       }//if allow symbol a ends here
       }
   //loop to symbols a of ends here
   //at this point we have all we need to know about the symbols 
     //based on the selection criteria fill up combos 
       //simple non swap , find X amount above (or below) correlation
         if(!COMBOS_selectWithSwap&&!COMBOS_singleMode){
         //filter by absolute max of correlation sco
           int sorter[][2];
           ArrayResize(sorter,ArraySize(SP.pairs),0); 
           for(int i=0;i<ArraySize(SP.pairs);i++){
           sorter[i][0]=(int)(MathAbs(SP.pairs[i].correlation)*100.0);
           sorter[i][1]=i;
           }
           ArraySort(sorter,ArraySize(SP.pairs),0,MODE_DESCEND);
           //now start selecting until we hits the limit
           //or until we are not over the abs limit 
             foundCOMBOS.reset();
             double neg_cor=COMBOS_CORRTHRESH*(-1.0);
             for(int i=0;i<ArraySize(SP.pairs);i++){
             //so if the correlation is valid 
               int ix=sorter[i][1];
                              //Print("SPPairs A("+SP.pairs[ix].symbol_a+")B("+SP.pairs[ix].symbol_b+")");
               //positive
               if(SP.pairs[ix].correlation>=COMBOS_CORRTHRESH){
               if(!COMBOS_Unique_Only||!foundCOMBOS.combo_with_one_of(SP.pairs[ix].symbol_a,SP.pairs[ix].symbol_b,prefix,suffix)){
               foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,1,SP.pairs[ix].symbol_b,-1,Prefix,Suffix);
               }}              
               //negative
               else if(SP.pairs[ix].correlation<=neg_cor){
               if(!COMBOS_Unique_Only||!foundCOMBOS.combo_with_one_of(SP.pairs[ix].symbol_a,SP.pairs[ix].symbol_b,prefix,suffix)){
               foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,1,SP.pairs[ix].symbol_b,1,Prefix,Suffix);
               }}
               //now this list is sorted SO , if none of the above bounce
               else{
               break;
               } 
               if(COMBOS_selectionMax>0&&ArraySize(foundCOMBOS.combos)==COMBOS_selectionMax){
                 break;
                 }
             }
         }
         //then the swap mode we go by most profitable combos "ABOVE" or "BELOW" the thresh
         else if(COMBOS_selectWithSwap&&!COMBOS_singleMode){
         //filter by absolute max of correlation sco
           int sorter[][2];
           ArrayResize(sorter,ArraySize(SP.pairs),0); 
           int valids=0;
           double neg_cor=COMBOS_CORRTHRESH*(-1.0);
           for(int i=0;i<ArraySize(SP.pairs);i++){
           //positive correlation
           if(SP.pairs[i].correlation>=COMBOS_CORRTHRESH){
           //buy+sell
             if(SP.pairs[i].symbol_a_swap_buy>0.0&&SP.pairs[i].symbol_b_swap_sell>0.0){
             valids++;
             sorter[valids-1][0]=(int)((SP.pairs[i].swap_a_buy_cost+SP.pairs[i].swap_b_sell_cost)*1000.0);
             sorter[valids-1][1]=i;
             }
           //sell+buy
             else if(SP.pairs[i].symbol_a_swap_sell>0.0&&SP.pairs[i].symbol_b_swap_buy>0.0){
             valids++;
             sorter[valids-1][0]=(int)((SP.pairs[i].swap_a_sell_cost+SP.pairs[i].swap_b_buy_cost)*1000.0);
             sorter[valids-1][1]=i;
             }           
           }
           //negative correlation
           else if(SP.pairs[i].correlation<=neg_cor){
           //buy+buy
             if(SP.pairs[i].symbol_a_swap_buy>0.0&&SP.pairs[i].symbol_b_swap_buy>0.0){
             valids++;
             sorter[valids-1][0]=(int)((SP.pairs[i].swap_a_buy_cost+SP.pairs[i].swap_b_buy_cost)*1000.0);
             sorter[valids-1][1]=i;
             }
           //sell+sell
             else if(SP.pairs[i].symbol_a_swap_sell>0.0&&SP.pairs[i].symbol_b_swap_sell>0.0){
             valids++;
             sorter[valids-1][0]=(int)((SP.pairs[i].swap_a_sell_cost+SP.pairs[i].swap_b_sell_cost)*1000.0);
             sorter[valids-1][1]=i;
             }            
           }
           }
           if(valids>0){
           ArraySort(sorter,valids,0,MODE_DESCEND);
           //now start selecting until we hits the limit
           //or until we are not over the abs limit 
             foundCOMBOS.reset();
             
             for(int i=0;i<valids;i++){
             //so if the correlation is valid 
               int ix=sorter[i][1];
               //positive correlation
               if(SP.pairs[ix].correlation>=COMBOS_CORRTHRESH){
                 //buy+sell
                   if(SP.pairs[ix].symbol_a_swap_buy>0.0&&SP.pairs[ix].symbol_b_swap_sell>0.0){
                   if(!COMBOS_Unique_Only||!foundCOMBOS.combo_with_one_of(SP.pairs[ix].symbol_a,SP.pairs[ix].symbol_b,prefix,suffix)){
                   foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,1,SP.pairs[ix].symbol_b,-1,Prefix,Suffix);
                   }}
                //sell+buy
                   else if(SP.pairs[ix].symbol_a_swap_sell>0.0&&SP.pairs[ix].symbol_b_swap_buy>0.0){
                   if(!COMBOS_Unique_Only||!foundCOMBOS.combo_with_one_of(SP.pairs[ix].symbol_a,SP.pairs[ix].symbol_b,prefix,suffix)){
                   foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,-1,SP.pairs[ix].symbol_b,1,Prefix,Suffix);
                   }}          
               }
               //negative correlation
               else if(SP.pairs[ix].correlation<=neg_cor){
                  //buy+buy
                    if(SP.pairs[ix].symbol_a_swap_buy>0.0&&SP.pairs[ix].symbol_b_swap_buy>0.0){
                    if(!COMBOS_Unique_Only||!foundCOMBOS.combo_with_one_of(SP.pairs[ix].symbol_a,SP.pairs[ix].symbol_b,prefix,suffix)){
                    foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,1,SP.pairs[ix].symbol_b,1,Prefix,Suffix);
                    }}
                  //sell+sell
                    else if(SP.pairs[ix].symbol_a_swap_sell>0.0&&SP.pairs[ix].symbol_b_swap_sell>0.0){
                    if(!COMBOS_Unique_Only||!foundCOMBOS.combo_with_one_of(SP.pairs[ix].symbol_a,SP.pairs[ix].symbol_b,prefix,suffix)){
                    foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,-1,SP.pairs[ix].symbol_b,-1,Prefix,Suffix);
                    }}            
               } 
               if(COMBOS_selectionMax>0&&ArraySize(foundCOMBOS.combos)==COMBOS_selectionMax){
                 break;
                 }
             } 
          }
         //if valids ends here        
         }
         //and finally the with swap and single mode (pick 1)
         else if(COMBOS_selectWithSwap&&COMBOS_singleMode){
         //pick the most correlated with the positive swap
         //filter by absolute max of correlation sco
           int sorter[][2];
           ArrayResize(sorter,ArraySize(SP.pairs),0); 
           int valids=0;
           double neg_cor=COMBOS_CORRTHRESH*(-1.0);
           for(int i=0;i<ArraySize(SP.pairs);i++){
           //positive correlation
           if(SP.pairs[i].correlation>=COMBOS_CORRTHRESH){
           //buy+sell
             if(SP.pairs[i].symbol_a_swap_buy>0.0&&SP.pairs[i].symbol_b_swap_sell>0.0){
             valids++;
             sorter[valids-1][0]=(int)((SP.pairs[i].correlation)*100.0);
             sorter[valids-1][1]=i;
             }
           //sell+buy
             else if(SP.pairs[i].symbol_a_swap_sell>0.0&&SP.pairs[i].symbol_b_swap_buy>0.0){
             valids++;
             sorter[valids-1][0]=(int)((SP.pairs[i].correlation)*100.0);
             sorter[valids-1][1]=i;
             }           
           }
           }
           if(valids>0){
           ArraySort(sorter,valids,0,MODE_DESCEND);
           //now start selecting until we hits the limit
           //or until we are not over the abs limit 
             foundCOMBOS.reset();
             
             //pick the one
             //so if the correlation is valid 
               int ix=sorter[0][1];
               //positive correlation
               if(SP.pairs[ix].correlation>=COMBOS_CORRTHRESH){
                 //buy+sell
                   if(SP.pairs[ix].symbol_a_swap_buy>0.0&&SP.pairs[ix].symbol_b_swap_sell>0.0){
                   foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,1,SP.pairs[ix].symbol_b,-1,Prefix,Suffix);
                   }
                //sell+buy
                   else if(SP.pairs[ix].symbol_a_swap_sell>0.0&&SP.pairs[ix].symbol_b_swap_buy>0.0){
                   foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,-1,SP.pairs[ix].symbol_b,1,Prefix,Suffix);
                   }           
               }          
          }
         //if valids ends here           
         }
       //selection modes end here
       if(ArraySize(foundCOMBOS.combos)>0){
       EventKillTimer();
       while(!EventSetTimer(1)){
       Sleep(100);
       }
       return(true);
       }else{
       return(false);
       }
    }else{//if market is not closed ends here
    EventKillTimer();
    while(!EventSetTimer(50)){
    Sleep(100);
    }
    return(false);
    }
  }//if correlation not loading ends here
return(false);
}

///////////////////////////////////////////////////////////
//system for keeping tabs on correlation load first 
  //we will add the symbols and load them


bool AllowSymbol(string _sy,string prefix,string suffix){
bool allow=true;
if(StringLen(prefix)>0){
  allow=false;
  if(StringFind(_sy,prefix,0)!=-1){allow=true;}
  }
if(StringLen(suffix)>0&&allow){
  allow=false;
  if(StringFind(_sy,suffix,0)!=-1){allow=true;}
  }
return(allow);
}

//Kay so we got a combo of selected pairs , for any reason 
class pairCombo{
              public:
user_text_var pairA,pairB,pairAMW,pairBMW;
              //-1 sell 1 buy 0 none 
int           pairAdirection,pairBdirection;
              //per the lot calculations 
double        atrA,cost_per_tick_per_lotA,pointA;
double        atrB,cost_per_tick_per_lotB,pointB;
double        minLotA,maxLotA,minLotB,maxLotB;
              pairCombo(void){reset();}
             ~pairCombo(void){reset();}
         void reset(){
              pairA.reset();
              pairB.reset();
              pairAdirection=0;
              pairBdirection=0;
              }
         bool setupLotStuff(int atrPeriod,ENUM_TIMEFRAMES atrTF){
              
              bool doneA=false,doneB=false;
              RefreshRates();
              //we pull the entire weight of the calcs here 
                int attempts=0;
                int errors=1;
                while(errors>0&&attempts<10){
                errors=0;
                attempts++;
                ResetLastError();
                //tick per lot
                  cost_per_tick_per_lotA=MarketInfo(pairAMW.to_string(),MODE_TICKVALUE);
                  if(GetLastError()>0){
                    ResetLastError();
                    cost_per_tick_per_lotA=SymbolInfoDouble(pairAMW.to_string(),SYMBOL_TRADE_TICK_VALUE);
                    errors+=GetLastError();ResetLastError();
                    }
                //min lot max lot 
                  minLotA=(double)SymbolInfoDouble(pairAMW.to_string(),SYMBOL_VOLUME_MIN);errors+=GetLastError();ResetLastError();
                  if(minLotA==0.0){
                    minLotA=(double)MarketInfo(pairAMW.to_string(),MODE_MINLOT);
                    }
                  maxLotA=(double)SymbolInfoDouble(pairAMW.to_string(),SYMBOL_VOLUME_MAX);errors+=GetLastError();ResetLastError();
                  if(maxLotA==0.0){
                    maxLotA=(double)MarketInfo(pairAMW.to_string(),MODE_MAXLOT);
                    }
                //atr
                  atrA=iATR(pairAMW.to_string(),atrTF,atrPeriod,1);errors+=GetLastError();ResetLastError();
                  pointA=(double)SymbolInfoDouble(pairAMW.to_string(),SYMBOL_POINT);errors+=GetLastError();ResetLastError();
                //tick per lot
                  cost_per_tick_per_lotB=MarketInfo(pairBMW.to_string(),MODE_TICKVALUE);
                  if(GetLastError()>0){
                    ResetLastError();
                    cost_per_tick_per_lotB=SymbolInfoDouble(pairBMW.to_string(),SYMBOL_TRADE_TICK_VALUE);
                    errors+=GetLastError();ResetLastError();
                    }
                //min lot max lot 
                  minLotB=(double)SymbolInfoDouble(pairBMW.to_string(),SYMBOL_VOLUME_MIN);errors+=GetLastError();ResetLastError();
                  if(minLotB==0.0){
                    minLotB=(double)MarketInfo(pairBMW.to_string(),MODE_MINLOT);
                    if(minLotB==0.0){
                      minLotB=(double)MarketInfo(pairBMW.to_string(),MODE_LOTSTEP);
                      }
                    }
                  maxLotB=(double)SymbolInfoDouble(pairBMW.to_string(),SYMBOL_VOLUME_MAX);errors+=GetLastError();ResetLastError();
                  if(maxLotB==0.0){
                    maxLotB=(double)MarketInfo(pairBMW.to_string(),MODE_MAXLOT);
                    }
                //atr
                  atrB=iATR(pairBMW.to_string(),atrTF,atrPeriod,1);errors+=GetLastError();ResetLastError();
                  pointB=(double)SymbolInfoDouble(pairBMW.to_string(),SYMBOL_POINT);errors+=GetLastError();ResetLastError();
              if(errors>0){Sleep(33);}else if(errors==0){return(true);}
              }
              return(false);              
              }
              //setup
         void setup(string _pair_a,int _a_direction,
                    string _pair_b,int _b_direction,
                    string _prefix,string _suffix){
              pairA=_pair_a;
              pairB=_pair_b;
              pairAMW=_prefix+_pair_a+_suffix;
              pairBMW=_prefix+_pair_b+_suffix;
              pairAdirection=_a_direction;
              pairBdirection=_b_direction;
              }
         void save(int file_handle){
              pairA.save(file_handle);
              pairB.save(file_handle);
              pairAMW.save(file_handle);
              pairBMW.save(file_handle);
              FileWriteInteger(file_handle,pairAdirection,INT_VALUE);
              FileWriteInteger(file_handle,pairBdirection,INT_VALUE);
              }
         void load(int file_handle){
              reset();
              pairA.load(file_handle);
              pairB.load(file_handle);
              pairAMW.load(file_handle);
              pairBMW.load(file_handle);
              pairAdirection=(int)FileReadInteger(file_handle,INT_VALUE);
              pairBdirection=(int)FileReadInteger(file_handle,INT_VALUE);
              } 
};

//and the holder of the combos for the system 
struct combo_holder{
pairCombo combos[];
          combo_holder(void){reset();}
         ~combo_holder(void){reset();}
     void reset(){
          ArrayFree(combos);
          }
          //add
      int add_combo(string _pair_a,int _direction_a,
                    string _pair_b,int _direction_b,
                    string _prefix,string _suffix){
          int ns=ArraySize(combos)+1;
          ArrayResize(combos,ns,0);
          if(StringLen(_prefix)>0){StringReplace(_pair_a,_prefix,"");StringReplace(_pair_b,_prefix,"");}
          if(StringLen(_suffix)>0){StringReplace(_pair_a,_suffix,"");StringReplace(_pair_b,_suffix,"");}
          combos[ns-1].setup(_pair_a,_direction_a,_pair_b,_direction_b,_prefix,_suffix);
          return(ns-1);
          }
     bool combo_with_one_of(string _pair_a,string _pair_b,string prefix,string suffix){
          if(StringLen(prefix)>0){
            StringReplace(_pair_a,prefix,"");
            StringReplace(_pair_b,prefix,"");
            }
          if(StringLen(suffix)>0){ 
            StringReplace(_pair_a,suffix,"");
            StringReplace(_pair_b,suffix,"");
            }
            
          for(int i=0;i<ArraySize(combos);i++){
             if(combos[i].pairA==_pair_a||combos[i].pairB==_pair_a){return(true);}
             if(combos[i].pairA==_pair_b||combos[i].pairB==_pair_b){return(true);}
             }
          return(false);
          }
     void save(string folder,string filename){
          string location=folder+"\\"+filename;
          if(FileIsExist(location)){FileDelete(location);}
          int f=FileOpen(location,FILE_WRITE|FILE_BIN);
          if(f!=INVALID_HANDLE){
          FileWriteInteger(f,((int)ArraySize(combos)),INT_VALUE);
          for(int i=0;i<ArraySize(combos);i++){
          combos[i].save(f);
          }
          FileClose(f);
          }
          }
     bool load(string folder,string filename){
          reset();
          string location=folder+"\\"+filename;
          if(FileIsExist(location)){
          int f=FileOpen(location,FILE_READ|FILE_BIN);
          if(f!=INVALID_HANDLE){
          bool any=false;
          int total=(int)FileReadInteger(f,INT_VALUE);
          if(total>0){
            any=true;
            ArrayResize(combos,total,0);
            for(int i=0;i<total;i++){
              combos[i].load(f);
              }
            }
          FileClose(f);
          return(any);
          }
          }
          return(false);
          }
};

combo_holder foundCOMBOS;

bool checkCorrelations(string focusPair,
                         char focusDirection,
                       bool consecutive_mode){
  if(CORR_LOADING){
  EventKillTimer();
  //loop
    int move_to=CORRLOADER.test_data(COMBOS_CORR_tf,COMBOS_CORR_period);
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
            ChartSetSymbolPeriod(ChartID(),CORRLOADER.symbols[move_to].symbol.to_string(),COMBOS_CORR_tf);
            }
        //case b : we are on the symbol to load -> go to another one and come back
          else if(CORRLOADER.symbols[move_to].symbol==_Symbol){
            CORRLOADER.save(CORR_Folder,CORR_File);
            string newsymbol=CORRLOADER.get_symbol_not_this(_Symbol);
            ChartSetSymbolPeriod(ChartID(),newsymbol,COMBOS_CORR_tf);
            }
        }
  
  }
  if(CORR_LOADING==false){
  SP.reset();
  foundCOMBOS.reset();
  //find correlations 
    double max_correlation=-1.0;
    string max_a=NULL,max_b=NULL;
    regressor_stat REG(COMBOS_CORR_period);
    //loop to symbols a of
    for(int a=0;a<ArraySize(CORRLOADER.symbols);a++){  
       //loop to symbols b with
         for(int b=a+1;b<ArraySize(CORRLOADER.symbols);b++){
            REG.reset(COMBOS_CORR_period);
            //if not same symbol and at least one of the symbols is the focus pair
            //the corrloader saves the symbols as they are 
            if(a!=b){
            //loop into the samples 
               for(int s=1;s<=COMBOS_CORR_period;s++){
                  //get close of a 
                    double close_of_a=iClose(CORRLOADER.symbols[a].symbol.to_string(),COMBOS_CORR_tf,s);
                  //get close of b
                    double close_of_b=iClose(CORRLOADER.symbols[b].symbol.to_string(),COMBOS_CORR_tf,s);     
                  //add samples 
                    REG.add_sample(close_of_a,close_of_b);
                  }
            //loop into the samples ends here
            //calculate 
              REG.calculate();
              /*
              if not same and if tradable
              */
              if(definately_different(CORRLOADER.symbols[a].symbol.to_string(),CORRLOADER.symbols[b].symbol.to_string())){
                if(both_tradable(CORRLOADER.symbols[a].symbol.to_string(),CORRLOADER.symbols[b].symbol.to_string(),Time[0])){
                  //i use Time[0] because we might have to wait 
                  //but just want to know if the broker allows trading this
                  //symbol in general not if we are in trading session
                  SP.add_pair(CORRLOADER.symbols[a].symbol.to_string(),CORRLOADER.symbols[b].symbol.to_string(),REG.correlation,REG.covariance,Prefix,Suffix);
                  }
                }
              
            }//if not same symbol ends here
            }
       //loop to symbols b with ends here
       }
   //loop to symbols a of ends here
       //now we keep looping having one focus symbol and one focus direction
       //until we collect x number of combos 
       //the first time the focus symbol and direction is the one from the inputs !
         if(consecutive_mode){
         string init_focus_pair=focusPair;
         char init_focus_direction=focusDirection;
         char init_opposite_direction=-1;
         if(init_focus_direction==-1){init_opposite_direction=1;}
         int chosen=0;
         foundCOMBOS.reset();
         //loop to gather consecutives
         while(ArraySize(foundCOMBOS.combos)<COMBOS_selectionMax){
          int pairs_with_symbol=0;
              //1 count
              for(int i=0;i<ArraySize(SP.pairs);i++){
              bool bounce=true;
              //aaaand the other symbol must not be in one of the existing combos either
              string search_if_used="";
              if(SP.pairs[i].symbol_a==init_focus_pair){
                search_if_used=SP.pairs[i].symbol_b;
                bounce=false;
                }
              else if(SP.pairs[i].symbol_b==init_focus_pair){
                search_if_used=SP.pairs[i].symbol_a;
                bounce=false;
                }
              //search 
                for(int j=0;j<ArraySize(foundCOMBOS.combos);j++){
                  if(foundCOMBOS.combos[j].pairAMW==search_if_used||foundCOMBOS.combos[j].pairBMW==search_if_used){
                    bounce=true;
                    break;
                    }
                  }
              if(!bounce)
                {
                pairs_with_symbol++;
                }
              }
              //2 add
                int sorter[][2];
                ArrayResize(sorter,pairs_with_symbol,0);
                pairs_with_symbol=0;
                for(int i=0;i<ArraySize(SP.pairs);i++){
                bool bounce=true;
                //aaaand the other symbol must not be in one of the existing combos either
                string search_if_used="";
                if(SP.pairs[i].symbol_a==init_focus_pair){
                  search_if_used=SP.pairs[i].symbol_b;
                  bounce=false;
                  }
                else if(SP.pairs[i].symbol_b==init_focus_pair){
                  search_if_used=SP.pairs[i].symbol_a;
                  bounce=false;
                  }
                //search 
                  for(int j=0;j<ArraySize(foundCOMBOS.combos);j++){
                    if(foundCOMBOS.combos[j].pairAMW==search_if_used||foundCOMBOS.combos[j].pairBMW==search_if_used){
                      bounce=true;
                      break;
                      }
                    }
                if(!bounce){
                pairs_with_symbol++;
                sorter[pairs_with_symbol-1][0]=(int)(MathAbs(SP.pairs[i].correlation)*100.0);
                sorter[pairs_with_symbol-1][1]=i;
                }
                }
              //3 find highest if existing 
                if(pairs_with_symbol>0){
                bool found=false;
                ArraySort(sorter,pairs_with_symbol,0,MODE_DESCEND);
                   double neg_cor=COMBOS_CORRTHRESH*(-1.0);
                   for(int i=0;i<pairs_with_symbol;i++){
                   //so if the correlation is valid 
                     int ix=sorter[i][1];
                     string otherPair=SP.pairs[ix].symbol_a;
                     if(init_focus_pair==otherPair){otherPair=SP.pairs[ix].symbol_b;}
                     //positive
                     if(SP.pairs[ix].correlation>=COMBOS_CORRTHRESH||COMBOS_CORRTHRESH==0.0){
                     foundCOMBOS.add_combo(init_focus_pair,init_focus_direction,otherPair,init_opposite_direction,Prefix,Suffix);
                     found=true;
                     //now flip to seek for what we found ! 
                     Print("Old focus("+init_focus_pair+")NewFocus("+otherPair+")");
                     init_focus_pair=otherPair;
                     init_focus_direction=init_opposite_direction;
                     init_opposite_direction=-1;
                     if(init_focus_direction==-1){init_opposite_direction=1;}
                     break;
                     }
                     //negative
                     else if(SP.pairs[ix].correlation<=neg_cor||COMBOS_CORRTHRESH==0.0){
                     foundCOMBOS.add_combo(init_focus_pair,init_focus_direction,otherPair,init_focus_direction,Prefix,Suffix);
                     found=true;
                     //now flip to seek for what we found ! 
                     Print("Old focus("+init_focus_pair+")NewFocus("+otherPair+")");
                     init_focus_pair=otherPair;
                     //directions don't change here
                     break;
                     }
                   }       
                if(!found){break;}     
                
                }else{
                break;
                }
              }
              //loop to gather consecutives ends here
         }
         else{
         //filter by absolute max of correlation sco
           int sorter[][2];
           ArrayResize(sorter,ArraySize(SP.pairs),0); 
           for(int i=0;i<ArraySize(SP.pairs);i++){
           sorter[i][0]=(int)(MathAbs(SP.pairs[i].correlation)*100.0);
           sorter[i][1]=i;
           }
           ArraySort(sorter,ArraySize(SP.pairs),0,MODE_DESCEND);
           //now start selecting until we hits the limit
           //or until we are not over the abs limit 
             foundCOMBOS.reset();
             char oppositeOfFocusDirection=-1;
             if(focusDirection==-1){oppositeOfFocusDirection=1;}
             double neg_cor=COMBOS_CORRTHRESH*(-1.0);
             for(int i=0;i<ArraySize(SP.pairs);i++){
             //so if the correlation is valid 
               int ix=sorter[i][1];
               //positive
               if(SP.pairs[ix].correlation>=COMBOS_CORRTHRESH||COMBOS_CORRTHRESH==0.0){
               foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,focusDirection,SP.pairs[ix].symbol_b,oppositeOfFocusDirection,Prefix,Suffix);
               }
               //negative
               else if(SP.pairs[ix].correlation<=neg_cor||COMBOS_CORRTHRESH==0.0){
               foundCOMBOS.add_combo(SP.pairs[ix].symbol_a,focusDirection,SP.pairs[ix].symbol_b,focusDirection,Prefix,Suffix);
               }
               //now this list is sorted SO , if none of the above bounce
               else{
               break;
               } 
               if(COMBOS_selectionMax>0&&ArraySize(foundCOMBOS.combos)==COMBOS_selectionMax){
                 break;
                 }
             }
         }
       //selection modes end here
       //Symbol A is always (ALWAYS) the focus pair
       //so now if anything was selected load its atr data 
         bool atrLoaded=true;
         
         
       if(atrLoaded){
       EventKillTimer();
       while(!EventSetTimer(1)){
       Sleep(100);
       }
       return(true);
       }
  }//if correlation not loading ends here
return(false);
}