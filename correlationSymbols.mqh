#property strict
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
    bool test_data(string _symbol,ENUM_TIMEFRAMES _tf,int total){
         bool okay=true;
         int errors=0;
         for(int i=0;i<=total;i++){
            ResetLastError();
            RefreshRates();
            double o=iOpen(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            double h=iHigh(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            double l=iLow(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            double c=iClose(_symbol,_tf,i);errors+=GetLastError();ResetLastError();
            }
         if(errors!=0){okay=false;}
         return(okay);
         }
