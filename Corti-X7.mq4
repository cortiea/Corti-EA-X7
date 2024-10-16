//+------------------------------------------------------------------+
//|                                       Corti-X7-SmallAccounts.mq4 |
//|                                                    @mastercool66 |
//|                                              https://cortiea.com |
//+------------------------------------------------------------------+
#property copyright "Corti-X7-SmallAccounts"
#property link      "https://cortiea.com"
#property version   ""
#property strict
#include "QuickLinersNoiseAndGradient.mqh";
#include "SimpleBoardV2.mqh";
#include "Standards.mqh";
#import "shell32.dll" 
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd); 
#import
#include "regressorCovariatorCorrelator.mqh";
#include "userTextVar.mqh";
#include "x5MixedCorrelationLibrary.mqh";
uint checktimer=1000;//check timer in milliseconds
input string note20="AutoScanner will select most +- Correlated Pairs.";//\\\\_____Trading Settings_____////
input string note21="Selected Pairs will Trade and Hedge.";//\\\\____________________////
input string note22="When one side hits Trail, Recovery will begin in the other side.";//\\\\____________________////
input string note23="When the side in Recovery Locks in Trail,the other side will close.";//\\\\____________________////
bool COMBOS_selectWithSwap=false;//Select with swap in mind
bool COMBOS_singleMode=false;//(with Swap::SingleMode)
bool COMBOS_Unique_Only=true;//Unique Combos only
enum scanner_mode{
scanner_default_mode=0,//default mode
scanner_focus_pair_mode=1//focus mode
};
bool ConsecutiveMode=true;//Consecutive mode
input string Prefix="";//Prefix to symbols
input string Suffix="";//Suffix to symbols
string COMBOS_Focus="EURUSD";//Focus pair without prefix or suffix
enum combo_direction{
direction_sell=-1,
direction_buy=1
};
combo_direction COMBOS_FocusDirection=direction_buy;//Focus Direction : 
scanner_mode SCANNERMODE=scanner_default_mode;//Scanner Mode :
int COMBOS_selectionMax=4;//Maximum Combos to Trade
double COMBOS_CORRTHRESH=0.70;//Correlation threshold (+/-)
int COMBOS_CORR_period=18;//Correlation Candles to Scan
ENUM_TIMEFRAMES COMBOS_CORR_tf=PERIOD_H4;//Correlations Timeframe 
string note11="Risk Management";//\\\\_____Risk Management_____////
double InitialLot=0.01;//First Lot 
double StepLot=0.01;//Step Lot for the Recovery Orders (0 - disabled)
double TrailStep=3;//Trail Profit of the side in positive :
double AverageModeTrailStep=5;//Average Mode : Trail Step (equity)
 bool AdditionalLotForDualHedgeMode=false;//Additional opposite side additive lot for DH mode
 double AdditiveLotForDH=0.01;//Additional lot for above :
 double AdditiveLotLimitMin=0.0;//Min Lot to start additive (meaning the total lot for the side that is about to open has to be more than this value)
double RecoveryCoefficient=2;//Coeficent Equity to trigger Limit Order :
 string note4="Positive Live Equity Trail";//\\\\_____POLE Settings_____////
 string note5="Trails the total of all orders > 0";//\\\\_____POLE Logic_____////
 double POLE_Trail_Step=2;//POLE Trail Step
 double POLE_Trail_Above=2;//POLE Trail Above
int MaxRecoveries=9;//Max Step Orders to recover : (0 = unlimited)
bool AverageMode=true;//Average Mode
bool AverageModeDontCloseInitiator=true;//Average Mode : Don't close first side 
bool DualHedge=false;//Double Hedge
enum dual_hedge_lot_mode{
dh_lot_mode_same=0,//same
dh_lot_mode_additive=1,//additive
dh_lot_mode_multiple=2//multiple
};
 dual_hedge_lot_mode DualHedgeLotMode=dh_lot_mode_additive;//Double Hedge : Lot Mode 
 double DualHedgeLotFactor=0.01;//Double Hedge : Lot Mode (Additive OR Multiplier)
 double TrailStepX_forHighLotSide=2.0;//(DH+add)Trail Step X , for high lot side
 double TrailStepX_forLowLotSide=1.5;//(DH+add)Trail Step X , for low lot side
 bool DualHedgeLotProfitableClose=false;//Double Hedge : Lot Mode EQ Profitable Close 
 bool DualHedgeReBalance=false;//Double Hedge : ReBalance
string note6="EA Settings";//\\\\_____Settings_____////
int MagicNumber=900666001;//Magic Nr
 int M_Attempts=10;//Trade Attempts 
 uint M_Timeout=333;//Delay B2In Trade attempts
 int M_Slippage=100;//Slippage 
 string TradeComment="cortiea.com";//Trade Comment
 bool CalculateSwaps=true;//Calculate Swaps
 bool CalculateCommisions=true;//Calculate Commisions
enum spread_mode{
m_spread_off=0,//Off
m_spread_points=1,//Points Max
m_spread_percentage=2//% of Price Max
};
spread_mode M_Spread_Mode=m_spread_points;//Spread Mode : 
 double M_Spread_Max=0;//Spread Max (based on mode pts/%)
 bool POLE_Trailing=false;//POLE Trailing
 bool POLE_Activate_Limit=false;//POLE Activate Limit (on hedged too)
 bool DontTradeFriday=false;//Dont Trade Fridays (broker time)
enum timeused
{time_local=0,//Local Time
time_broker=1//Broker Time 
};
timeused FridayTimeUsed=time_broker;//Time used for checking Fridays 
bool MondayBegin=false;//Begin trading on monday on hour below :
 int MondayHour=11;//Monday Hour to begin : 
timeused MondayTimeUsed=time_broker;//Time used for checking Mondays
bool TimeToIgnore=true;//Ignore the following time range 
string TTI_End="04:01";//Begin Trading at :
string TTI_Start="16:59";//Dont trade after : 
int i_font_size=9;//Font Size  
int GUI_DeckWidth=300;//Deck Width px
int GUI_RowHeight=20;//Row Height px
 bool IsFifo=false;//Use Fifo Closure ? 
 string notec="<-->";//DISPLAY SETTINGS 
 string SystemHeader="Corti X7";//display header
 color CLR_Text=clrGainsboro;//Text Color
 bool ExitAllButton=true;//Show Close All Button ? 
 bool ExitAllExits=true;//Close EA After Close All Btn ?
//resources load , happens once on compile , the users don't need these files 
#define GUI_LOGO "::gui\\logo1.bmp"
#define GUI_ICON_DISCORD "::gui\\discord_normal.bmp"
#define GUI_ICON_FACEBOOK "::gui\\facebook_normal.bmp"
#define GUI_ICON_FOREX_FACTORY "::gui\\forex_factory_normal.bmp"
#define GUI_ICON_INSTAGRAM "::gui\\instagram_normal.bmp"
#define GUI_ICON_POWER "::gui\\power_normal.bmp"
#define GUI_ICON_TELEGRAM "::gui\\telegram_normal.bmp"
#define GUI_ICON_WEBSITE "::gui\\website_normal.bmp"
#define GUI_CLOSE "::gui\\close_btn.bmp"
#define GUI_IX_DISCORD 0
#define GUI_IX_FACEBOOK 1
#define GUI_IX_FOREX_FACTORY 2
#define GUI_IX_INSTAGRAM 3
#define GUI_IX_POWER 4
#define GUI_IX_TELEGRAM 5
#define GUI_IX_WEBSITE 6
#resource "gui\\logo1.bmp";
#resource "gui\\discord_normal.bmp";
#resource "gui\\facebook_normal.bmp";
#resource "gui\\forex_factory_normal.bmp";
#resource "gui\\instagram_normal.bmp";
#resource "gui\\power_normal.bmp";
#resource "gui\\telegram_normal.bmp";
#resource "gui\\website_normal.bmp";
#resource "gui\\close_btn.bmp";
 string noteguib="<GUI>";//GUI
 int GUI_Header_Height=60;//Header Height
 int GUI_PX=10;//Gui Position X
 int GUI_PY=10;//Gui Position Y 
//sizing
 int GUI_Logo_Height=44;//Logo height (the width will be auto calc'd by the aspect ratio) 
 int GUI_Icons_Height=20;//Icons Height (on header)
 int GUI_Logo_Px=6;//Logo Offset X
 int GUI_Logo_Py=2;//Logo Offset Y
 int GUI_Close_Height=44;//Close Btn Height

//background
 bool GUI_Background_Grade=true;//Gradient Background
 color GUI_Background_Color_1=clrCrimson;//Background Color 1 (or only color)
 uchar GUI_Background_Opacity_1=185;//Color 1 opacity 0->255 the lower the value the more transparent the color (and the background)
 color GUI_Background_Color_2=clrBlack;//Background Color 2 
 uchar GUI_Background_Opacity_2=255;//Color 2 opacity 0->255
/*
di_gr_off=0,//Off
di_gr_simple=1,//Simple
di_gr_center=2,//Centered
di_gr_line_center=3,//Center Linear
di_gr_cross=4,//Center Cross
di_gr_round=5//Round
*/
 display_gradient GUI_Background_Gradient_Type=di_gr_round;//Background Gradient Type
 double GUI_Background_Gradient_Angle=45;//Background Gradient Angle , if applicable
 bool GUI_Background_Liners=true;//Background Liners
/*
  di_li_linear=0,//Linear
  di_li_circles=1//Circles
*/
 display_liner GUI_Background_Liners_Type=di_li_linear;//Background liners type
 color GUI_Background_Liners_Color=clrBlack;//Background liners color
 uchar GUI_Background_Liners_Opacity=255;//Background liners opacity 0->255
 int GUI_Background_Liners_Width=2;//Background liners width 
 int GUI_Background_Liners_Gap=2;//Background liners gap
 double GUI_Background_Liners_Angle=90;//Background liners angle
 bool GUI_Background_Noise=true;//Background Noise
 int GUI_Noise_Range_Min=-5;//Noise Range Min %
 int GUI_Noise_Range_Max=5;//Noiser Range Max %
//logo
 bool GUI_Logo_Gradient=true;//Logo Gradient 
 display_gradient GUI_Logo_Gradient_Type=di_gr_simple;//Logo Gradient Type
 color GUI_Logo_Color_1=clrPeru;//Logo Color 1 
 uchar GUI_Logo_Opacity_1=200;//Logo Opacity 1
 color GUI_Logo_Color_2=clrGold;//Logo Color 2
 uchar GUI_Logo_Opacity_2=255;//Logo Opacity 2 
 double GUI_Logo_Gradient_Angle=90;//Logo Gradient Angle 
 bool GUI_Logo_Liners=false;//Logo Liner 
 display_liner GUI_Logo_Liner_Type=di_li_linear;//Logo Liner Type
 color GUI_Logo_Liner_Color=clrWhite;//Logo Liner Color
 uchar GUI_Logo_Liner_Opacity=255;//Logo Liner Opacity
 double GUI_Logo_Liner_Angle=135;//Logo Liner Angle
 int GUI_Logo_Liner_Gap=2;//Logo Liner Gap
 int GUI_Logo_Liner_Width=2;//Logo Liner Width
 bool GUI_Logo_Noise=false;//Logo Noise
 int GUI_Logo_Noise_Min=-10;//Logo Noise Min %
 int GUI_Logo_Noise_Max=10;//Logo Noise Max %
//icons normal state
 bool GUI_IconsNormal_Gradient=true;//Icon Normal State Gradient 
 display_gradient GUI_IconsNormal_Gradient_Type=di_gr_round;//Icon Normal State Gradient Type
 color GUI_IconsNormal_Color_1=clrMaroon;//Icon Normal State Color 1 
 uchar GUI_IconsNormal_Opacity_1=255;//Icon Normal State Opacity 1
 color GUI_IconsNormal_Color_2=clrCrimson;//Icon Normal State Color 2
 uchar GUI_IconsNormal_Opacity_2=180;//Icon Normal State Opacity 2 
 double GUI_IconsNormal_Gradient_Angle=46;//Icon Normal State Gradient Angle 
 bool GUI_IconsNormal_Liners=false;//Icon Normal State Liner 
 display_liner GUI_IconsNormal_Liner_Type=di_li_linear;//Icon Normal State Liner Type
 color GUI_IconsNormal_Liner_Color=clrWhite;//Icon Normal State Liner Color
 uchar GUI_IconsNormal_Liner_Opacity=255;//Icon Normal State Liner Opacity
 double GUI_IconsNormal_Liner_Angle=135;//Icon Normal State Liner Angle
 int GUI_IconsNormal_Liner_Gap=2;//Icon Normal State Liner Gap
 int GUI_IconsNormal_Liner_Width=2;//Icon Normal State Liner Width
 bool GUI_IconsNormal_Noise=false;//Icon Normal State Noise
 int GUI_IconsNormal_Noise_Min=-10;//Icon Normal State Noise Min %
 int GUI_IconsNormal_Noise_Max=10;//Icon Normal State Noise Max %
//icons hover state
 bool GUI_IconsHover_Gradient=true;//Icon Hover State Gradient 
 display_gradient GUI_IconsHover_Gradient_Type=di_gr_simple;//Icon Hover State Gradient Type
 color GUI_IconsHover_Color_1=clrRed;//Icon Hover State Color 1 
 uchar GUI_IconsHover_Opacity_1=255;//Icon Hover State Opacity 1
 color GUI_IconsHover_Color_2=clrCrimson;//Icon Hover State Color 2
 uchar GUI_IconsHover_Opacity_2=255;//Icon Hover State Opacity 2 
 double GUI_IconsHover_Gradient_Angle=46;//Icon Hover State Gradient Angle 
 bool GUI_IconsHover_Liners=false;//Icon Hover State Liner 
 display_liner GUI_IconsHover_Liner_Type=di_li_linear;//Icon Hover State Liner Type
 color GUI_IconsHover_Liner_Color=clrWhite;//Icon Hover State Liner Color
 uchar GUI_IconsHover_Liner_Opacity=255;//Icon Hover State Liner Opacity
 double GUI_IconsHover_Liner_Angle=135;//Icon Hover State Liner Angle
 int GUI_IconsHover_Liner_Gap=2;//Icon Hover State Liner Gap
 int GUI_IconsHover_Liner_Width=2;//Icon Hover State Liner Width
 bool GUI_IconsHover_Noise=false;//Icon Hover State Noise
 int GUI_IconsHover_Noise_Min=-10;//Icon Hover State Noise Min %
 int GUI_IconsHover_Noise_Max=10;//Icon Hover State Noise Max %
//row a
 bool GUI_RowA_Gradient=true;//Row A  Gradient 
 display_gradient GUI_RowA_Gradient_Type=di_gr_simple;//Row A  Gradient Type
 color GUI_RowA_Color_1=clrCrimson;//Row A  Color 1 
 uchar GUI_RowA_Opacity_1=150;//Row A  Opacity 1
 color GUI_RowA_Color_2=clrBlack;//Row A  Color 2
 uchar GUI_RowA_Opacity_2=50;//Row A  Opacity 2 
 double GUI_RowA_Gradient_Angle=90;//Row A  Gradient Angle 
 bool GUI_RowA_Liners=false;//Row A  Liner 
 display_liner GUI_RowA_Liner_Type=di_li_linear;//Row A  Liner Type
 color GUI_RowA_Liner_Color=clrWhite;//Row A  Liner Color
 uchar GUI_RowA_Liner_Opacity=255;//Row A  Liner Opacity
 double GUI_RowA_Liner_Angle=135;//Row A  Liner Angle
 int GUI_RowA_Liner_Gap=2;//Row A  Liner Gap
 int GUI_RowA_Liner_Width=2;//Row A  Liner Width
 bool GUI_RowA_Noise=true;//Row A  Noise
 int GUI_RowA_Noise_Min=-3;//Row A  Noise Min %
 int GUI_RowA_Noise_Max=3;//Row A  Noise Max %
//row b
 bool GUI_RowB_Gradient=true;//Row B  Gradient 
 display_gradient GUI_RowB_Gradient_Type=di_gr_simple;//Row B  Gradient Type
 color GUI_RowB_Color_1=clrBlack;//Row B  Color 1 
 uchar GUI_RowB_Opacity_1=150;//Row B  Opacity 1
 color GUI_RowB_Color_2=clrCrimson;//Row B  Color 2
 uchar GUI_RowB_Opacity_2=50;//Row B  Opacity 2 
 double GUI_RowB_Gradient_Angle=90;//Row B  Gradient Angle 
 bool GUI_RowB_Liners=false;//Row B  Liner 
 display_liner GUI_RowB_Liner_Type=di_li_linear;//Row B  Liner Type
 color GUI_RowB_Liner_Color=clrWhite;//Row B  Liner Color
 uchar GUI_RowB_Liner_Opacity=255;//Row B  Liner Opacity
 double GUI_RowB_Liner_Angle=135;//Row B  Liner Angle
 int GUI_RowB_Liner_Gap=2;//Row B  Liner Gap
 int GUI_RowB_Liner_Width=2;//Row B  Liner Width
 bool GUI_RowB_Noise=true;//Row B  Noise
 int GUI_RowB_Noise_Min=-3;//Row B  Noise Min %
 int GUI_RowB_Noise_Max=3;//Row B  Noise Max %
//close normal btn
 color GUI_CloseNormal_Text=clrBlack;//Close Normal Text Color
 bool GUI_CloseNormal_Gradient=true;//Close Normal Gradient 
 display_gradient GUI_CloseNormal_Gradient_Type=di_gr_simple;//Close Normal Gradient Type
 color GUI_CloseNormal_Color_1=clrPeru;//Close Normal Color 1 
 uchar GUI_CloseNormal_Opacity_1=200;//Close Normal Opacity 1
 color GUI_CloseNormal_Color_2=clrGold;//Close Normal Color 2
 uchar GUI_CloseNormal_Opacity_2=255;//Close Normal Opacity 2 
 double GUI_CloseNormal_Gradient_Angle=90;//Close Normal Gradient Angle 
 bool GUI_CloseNormal_Liners=false;//Close Normal Liner 
 display_liner GUI_CloseNormal_Liner_Type=di_li_linear;//Close Normal Liner Type
 color GUI_CloseNormal_Liner_Color=clrWhite;//Close Normal Liner Color
 uchar GUI_CloseNormal_Liner_Opacity=255;//Close Normal Liner Opacity
 double GUI_CloseNormal_Liner_Angle=135;//Close Normal Liner Angle
 int GUI_CloseNormal_Liner_Gap=2;//Close Normal Liner Gap
 int GUI_CloseNormal_Liner_Width=2;//Close Normal Liner Width
 bool GUI_CloseNormal_Noise=false;//Close Normal Noise
 int GUI_CloseNormal_Noise_Min=-10;//Close Normal Noise Min %
 int GUI_CloseNormal_Noise_Max=10;//Close Normal Noise Max %
//close hover btn
 color GUI_CloseHover_Text=clrCrimson;//Close Hover Text Color
 bool GUI_CloseHover_Gradient=true;//Close Hover Gradient 
 display_gradient GUI_CloseHover_Gradient_Type=di_gr_simple;//Close Hover Gradient Type
 color GUI_CloseHover_Color_1=clrPeru;//Close Hover Color 1 
 uchar GUI_CloseHover_Opacity_1=255;//Close Hover Opacity 1
 color GUI_CloseHover_Color_2=clrGold;//Close Hover Color 2
 uchar GUI_CloseHover_Opacity_2=200;//Close Hover Opacity 2 
 double GUI_CloseHover_Gradient_Angle=90;//Close Hover Gradient Angle 
 bool GUI_CloseHover_Liners=false;//Close Hover Liner 
 display_liner GUI_CloseHover_Liner_Type=di_li_linear;//Close Hover Liner Type
 color GUI_CloseHover_Liner_Color=clrWhite;//Close Hover Liner Color
 uchar GUI_CloseHover_Liner_Opacity=255;//Close Hover Liner Opacity
 double GUI_CloseHover_Liner_Angle=135;//Close Hover Liner Angle
 int GUI_CloseHover_Liner_Gap=2;//Close Hover Liner Gap
 int GUI_CloseHover_Liner_Width=2;//Close Hover Liner Width
 bool GUI_CloseHover_Noise=false;//Close Hover Noise
 int GUI_CloseHover_Noise_Min=-10;//Close Hover Noise Min %
 int GUI_CloseHover_Noise_Max=10;//Close Hover Noise Max %

string LINK_WEBSITE="https://cortiea.com";//link to tely
string LINK_WEBSITE_TEXT="Corti is a Forex and Crypto Trading Robot which autotrades by Hedging Forex Triangulares Correlated Pairs or CFD Cryptos so the profit is secured no matter where the market goes";
string LINK_TELEGRAM="https://t.me/cortiea";//link to tely
string LINK_TELEGRAM_TEXT="Official Telegram Channel";
string LINK_DISCORD="https://discord.gg/5FDYYjaz3r";//link to tely
string LINK_DISCORD_TEXT="Official Discord Channel";
string LINK_FOREX_FACTORY="https://www.forexfactory.com/thread/1015941-corti-correlated-ea";//link to tely
string LINK_FOREX_FACTORY_TEXT="ForexFactory Forum Official Thread Free Support";
string LINK_INSTAGRAM="https://www.instagram.com/cortiexpertadvisor/";//link to tely
string LINK_INSTAGRAM_TEXT="Instagram Page";
string LINK_FACEBOOK="https://www.facebook.com/cortiexpertadvisor";//link to tely
string LINK_FACEBOOK_TEXT="Facebook Page";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
string myResources[];//resources the gui creates
string SystemFolder="CortiX7",SystemFilename="",SystemTag="HAT_";
bool HasTimer=false;
    corr_symbols_loader CORRLOADER;
    string CORR_Folder="",CORR_File="corr.txt";
    bool CORR_LOADING=false;
bool BUSY=false,DECKED=false;
datetime timerTime=0;
int OnInit()
  {
//--- create time
  timerTime=0;
  CORR_LOADING=false;
  CORRLOADER.reset();
  DECKED=false;
  BUSY=false;
  CORR_Folder=SystemFolder+"\\Corr";
  CORR_File=IntegerToString(MagicNumber)+".txt";
  foundCOMBOS.reset();
  SP.reset();
  ELEMENTLIST.reset();  
  for(int i=0;i<ArraySize(myResources);i++){
  ResourceFree(myResources[i]);
  }ArrayFree(myResources);
  ObjectsDeleteAll(ChartID(),"HATGUI_");
  //RVL.setup(BuyPairs1,SellPairs1,BuyPairs2,SellPairs2,BuyPairs3,SellPairs3);
  ObjectsDeleteAll(0,"MQLNOTE_");
  ObjectsDeleteAll(ChartID(),SystemTag);
  //controller
  ctfxew_controller jc=JCC();
  MASTER_JC_CONTROL=jc.valid;
  MASTER_JC_NOTES=jc.notes;
  MASTER_JC_NEXT_C=jc.next_checktime;
  //control checks
  if(MASTER_JC_CONTROL==false)
    {
    Alert(MASTER_JC_NOTES);
    ExpertRemove();
    }
  if(MASTER_JC_CONTROL==true)  
  {   
  BlockFrom.set(TTI_Start);
  BlockTo.set(TTI_End);   
  SystemFilename=IntegerToString(MagicNumber)+"_hat.txt";
  bool LOADCORRS=true;
  //can we load the system ? 
    string location=SystemFolder+"\\"+SystemFilename;
    if(FileIsExist(location)){
    LOADCORRS=false;
    //load system
      bool loaded=HAT.load(SystemFolder,SystemFilename);
      if(!loaded){
      bool conflict=false;
      for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
      if(OrderMagicNumber()==MagicNumber){
       conflict=true;
      }}}
      if(conflict){Alert("System with this Magic# ("+IntegerToString(MagicNumber)+") is already live");return(INIT_FAILED);}
      LOADCORRS=true;
      }
      else{
      //build deck
        OG.SetChart(ChartID(),0);
        BuildDeck(OG,SystemTag,GUI_PX,GUI_PY,GUI_DeckWidth,GUI_RowHeight,HAT);         
      //start timer
        while(!EventSetMillisecondTimer(checktimer)){
             Sleep(checktimer);
             }
      }
    }
    
  //if we cannot load the system
    if(LOADCORRS){
      //if we loadit 
      if(CORRLOADER.load(CORR_Folder,CORR_File,Prefix,Suffix)){
        //create timer for load 
          if(CORRLOADER.needs_load()){
          CORR_LOADING=true;
          while(!EventSetMillisecondTimer(300)){
               Sleep(300);
               }
          }
      }else{
      //create it 
        int symbols_total=SymbolsTotal(true);
        for(int i=0;i<symbols_total;i++){
             //so if its forex 
               if(AllowSymbol(SymbolName(i,true),Prefix,Suffix)&&is_probably_forex(SymbolName(i,true),Prefix,Suffix)){
               //Print("Is forex adding "+SymbolName(i,true));
               CORRLOADER.add_symbol(SymbolName(i,true));
               }
           }
        CORRLOADER.save(CORR_Folder,CORR_File);
        //create timer for load 
          CORR_LOADING=true;
          while(!EventSetMillisecondTimer(300)){
               Sleep(300);
               }        
      }     
    }
  //if we cannot load the system ends here 
  if(CTFXEW_CONTROL_ACCOUNT||CTFXEW_CONTROL_BROKER||CTFXEW_CONTROL_DATE||CTFXEW_CONTROL_USER) CreateDemoNote();     
  }else{Alert("Expired");return(INIT_FAILED);}
  //controller ends here         
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
  //EventKillTimer();
    DECKED=false;
    ObjectsDeleteAll(ChartID(),"HATGUI_");
    for(int i=0;i<ArraySize(myResources);i++){
    ResourceFree(myResources[i]);
    }ArrayFree(myResources);
    HAT.reset(true,true);
    ObjectsDeleteAll(0,"MQLNOTE_");
    ObjectsDeleteAll(ChartID(),SystemTag);  
    ELEMENTLIST.reset();  
    CORRLOADER.reset(); 
    foundCOMBOS.reset();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
  //controller
  ctfxew_controller jc=JCC();
  MASTER_JC_CONTROL=jc.valid;
  MASTER_JC_NOTES=jc.notes;
  MASTER_JC_NEXT_C=jc.next_checktime;
  //control checks
  if(MASTER_JC_CONTROL==false)
    {
    Alert(MASTER_JC_NOTES);
    ExpertRemove();
    }
  if(MASTER_JC_CONTROL==true)  
  {    
//---
  if(!BUSY){BUSY=true;

  if(HAT.stage!=hat_stage_void||(SCANNERMODE==scanner_default_mode&&CheckMarselTimeAllow()&&checkCorrelations(Prefix,Suffix))||(SCANNERMODE==scanner_focus_pair_mode&&CheckMarselTimeAllow()&&checkCorrelations(Prefix+COMBOS_Focus+Suffix,(char)COMBOS_FocusDirection,ConsecutiveMode))){
    //we have an additional issue , we access this on timer due to multiple pairs 
    //so we must ensure the market is live ourselves so 
      datetime marketNow=TimeCurrent();
      bool marketIsLive=(bool)(marketNow>timerTime);
      timerTime=marketNow;
    //this returns true if the ea can operate
      //if system is void it means we just found the combos
        if(HAT.stage==hat_stage_void){
        //save
          if(ArraySize(foundCOMBOS.combos)>0){
          //add the combos to buy and sell groups (2 groups here no revolving)
           //count buy sides
           //default mode
           if(SCANNERMODE==scanner_default_mode){
             int total_buys=0,total_sells=0;
             for(int i=0;i<ArraySize(foundCOMBOS.combos);i++){
             if(foundCOMBOS.combos[i].pairAdirection==1){total_buys++;}
             if(foundCOMBOS.combos[i].pairAdirection==-1){total_sells++;}
             if(foundCOMBOS.combos[i].pairBdirection==1){total_buys++;}
             if(foundCOMBOS.combos[i].pairBdirection==-1){total_sells++;}
             }
             string buy_pairs[],sell_pairs[];
             ArrayResize(buy_pairs,total_buys,0);
             ArrayResize(sell_pairs,total_sells,0);
             int buy_co=0,sell_co=0;
             for(int i=0;i<ArraySize(foundCOMBOS.combos);i++){
             if(foundCOMBOS.combos[i].pairAdirection==1)
               {
               buy_co++;
               buy_pairs[buy_co-1]=foundCOMBOS.combos[i].pairA.to_string();
               }
             if(foundCOMBOS.combos[i].pairAdirection==-1)
               {
               sell_co++;
               sell_pairs[sell_co-1]=foundCOMBOS.combos[i].pairA.to_string();
               }
             if(foundCOMBOS.combos[i].pairBdirection==1)
               {
               buy_co++;
               buy_pairs[buy_co-1]=foundCOMBOS.combos[i].pairB.to_string();
               }
             if(foundCOMBOS.combos[i].pairBdirection==-1)
               {
               sell_co++;
               sell_pairs[sell_co-1]=foundCOMBOS.combos[i].pairB.to_string();
               }             
             }
          Print("Setting up HAT with "+IntegerToString(ArraySize(buy_pairs))+" Buy Pairs :");
          for(int i=0;i<ArraySize(buy_pairs);i++){
             Print(buy_pairs[i]);
             }
          Print(IntegerToString(ArraySize(sell_pairs))+"Sell pairs : ");
          for(int i=0;i<ArraySize(sell_pairs);i++){
             Print(sell_pairs[i]);
             }
          HAT.setup(buy_pairs,sell_pairs,false,0,Prefix,Suffix);
          HAT.stage=hat_stage_waiting;
          }
          //default mode setup ends here
          //focus mode
          else if(SCANNERMODE==scanner_focus_pair_mode){
          //the symbol a in each combo is the focus pair here , caution
            //add the focus pair first 
             int total_buys=0,total_sells=0;
             if(COMBOS_FocusDirection==direction_buy){total_buys++;}
             else{total_sells++;}
             
             for(int i=0;i<ArraySize(foundCOMBOS.combos);i++){
             if(foundCOMBOS.combos[i].pairBdirection==1){total_buys++;}
             if(foundCOMBOS.combos[i].pairBdirection==-1){total_sells++;}
             }
             string buy_pairs[],sell_pairs[];
             ArrayResize(buy_pairs,total_buys,0);
             ArrayResize(sell_pairs,total_sells,0);
             int buy_co=0,sell_co=0;
             //add focus pair first 
               if(COMBOS_FocusDirection==direction_buy){
                 buy_co++;
                 buy_pairs[buy_co-1]=Prefix+COMBOS_Focus+Suffix;
                 }
               else{
                 sell_co++;
                 sell_pairs[sell_co-1]=Prefix+COMBOS_Focus+Suffix;
                 }
             for(int i=0;i<ArraySize(foundCOMBOS.combos);i++){
             if(foundCOMBOS.combos[i].pairBdirection==1)
               {
               string to_add=foundCOMBOS.combos[i].pairB.to_string();
               bool used=false;
               for(int j=0;j<buy_co;j++){
                  if(buy_pairs[j]==to_add){
                    used=true;
                    break;
                    }
                  }
               if(!used){
               buy_co++;
               buy_pairs[buy_co-1]=foundCOMBOS.combos[i].pairB.to_string();
               }}
             if(foundCOMBOS.combos[i].pairBdirection==-1)
               {
               string to_add=foundCOMBOS.combos[i].pairB.to_string();
               bool used=false;
               for(int j=0;j<sell_co;j++){
                  if(sell_pairs[j]==to_add){
                    used=true;
                    break;
                    }
                  }
               if(!used){
               sell_co++;
               sell_pairs[sell_co-1]=foundCOMBOS.combos[i].pairB.to_string();
               }}            
             }
             ArrayResize(buy_pairs,buy_co,0);
             ArrayResize(sell_pairs,sell_co,0);
          Print("Setting up HAT with "+IntegerToString(ArraySize(buy_pairs))+" Buy Pairs :");
          for(int i=0;i<ArraySize(buy_pairs);i++){
             Print(buy_pairs[i]);
             }
          Print(IntegerToString(ArraySize(sell_pairs))+"Sell pairs : ");
          for(int i=0;i<ArraySize(sell_pairs);i++){
             Print(sell_pairs[i]);
             }
          HAT.setup(buy_pairs,sell_pairs,false,0,Prefix,Suffix);
          HAT.stage=hat_stage_waiting;              
          }
          //focus mode ends here
          //delete the corr file 
            FileDelete(CORR_Folder+"\\"+CORR_File);
          //save 
            HAT.save(SystemFolder,SystemFilename);
            DECKED=false;
          ObjectsDeleteAll(ChartID(),SystemTag);
          OG.SetChart(ChartID(),0);
          BuildDeck(OG,SystemTag,GUI_PX,GUI_PY,GUI_DeckWidth,GUI_RowHeight,HAT);        
          }else{
          Print("Cannot find combos , retrying");
          }
        }
        else{
        if(marketIsLive){
        bool KILLIT=false;
          //normal operations
            if(HAT.busy==false)
              {
              HAT.monitor(CalculateSwaps,CalculateCommisions,TrailStep,RecoveryCoefficient,StepLot,AverageMode,AverageModeTrailStep,AverageModeDontCloseInitiator,InitialLot,MaxRecoveries,Prefix,Suffix,KILLIT);
              }
        //now , if the stage goes back to void
          if(KILLIT){
          DECKED=false;
          HAT.reset(true,true);
          ObjectsDeleteAll(ChartID(),SystemTag);
          //kill the system file
            FileDelete(SystemFolder+"\\"+SystemFilename);
          //start the correlations load however , might be left unloaded in some cases .
              CORRLOADER.reset();
              //create it 
              int symbols_total=SymbolsTotal(true);
              for(int i=0;i<symbols_total;i++){
             //so if its forex 
               if(is_probably_forex(SymbolName(i,true),Prefix,Suffix)){
               CORRLOADER.add_symbol(SymbolName(i,true));
               }
              }
              CORRLOADER.save(CORR_Folder,CORR_File);
              CORR_LOADING=true;           
          }else{
          UpdateDeck(HAT);
          }
        }
        //if market is live ends here
        }
    }   
   
  BUSY=false;}
  
  }else{ExpertRemove();}  
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
  if(id==CHARTEVENT_OBJECT_CLICK&&sparam==SystemTag+"_ExitAll"&&!HAT.busy){
  bool closed_all=CloseAll(true,HAT);
  if(closed_all){
  DECKED=false;
          if(!ExitAllExits){
          
          //HAT.reset(false);
          int current=HAT.active_hat;
          HAT.reset(true,true);
          ObjectsDeleteAll(ChartID(),SystemTag);
          //kill the system file
            FileDelete(SystemFolder+"\\"+SystemFilename);
          }else if(ExitAllExits){
          HAT.busy=true;
          ExpertRemove();
          }
  }} 
  else if(id==CHARTEVENT_OBJECT_CLICK){
  if(sparam==SystemTag+"_Quit"){
  ExpertRemove();
  }
  else if(sparam==SystemTag+"_Website"){
  CTFX_Links(LINK_WEBSITE,LINK_WEBSITE_TEXT);
  }
  else if(sparam==SystemTag+"_Telegram"){
  CTFX_Links(LINK_TELEGRAM,LINK_TELEGRAM_TEXT);
  }
  else if(sparam==SystemTag+"_Facebook"){
  CTFX_Links(LINK_FACEBOOK,LINK_FACEBOOK_TEXT);
  }
  else if(sparam==SystemTag+"_Instagram"){
  CTFX_Links(LINK_INSTAGRAM,LINK_INSTAGRAM_TEXT);
  }
  else if(sparam==SystemTag+"_Discord"){
  CTFX_Links(LINK_DISCORD,LINK_DISCORD_TEXT);
  }
  else if(sparam==SystemTag+"_ForexFactory"){
  CTFX_Links(LINK_FOREX_FACTORY,LINK_FOREX_FACTORY_TEXT);
  } 
  }
  else if(id==CHARTEVENT_MOUSE_MOVE){
  int mcx=(int)lparam;
  int mcy=(int)dparam;
  ELEMENTLIST.check(mcx,mcy);
  }    
  }
//+------------------------------------------------------------------+

//basics

//a symbol no prefix no suffix stored  
struct a_symbol{
  user_text_var symbol;//no prefix no suffix 
/* the recovery equity is managed per symbol of a side 
   so we store the next equity level of the SYMBOL for opening the next 
   lot 
*/
         double next_recovery_equity;
         double equity,equity_of_last;
         double last_lot,total_lots;//for display
           bool operate;
//the orders for this symbol on the side this symbol is in !
            int tickets[];
//the direction of this symbol on this side  
ENUM_ORDER_TYPE direction;
                //
                a_symbol(void){reset(true,true);}
               ~a_symbol(void){reset(true,true);}
           void reset(bool remove_setup,
                      bool remove_tickets){
                if(remove_setup){
                symbol.reset();
                direction=NULL;
                
                }
                if(remove_tickets){
                ArrayFree(tickets);
                }
                operate=true;
                last_lot=0.0;
                total_lots=0.0;
                next_recovery_equity=0.0;
                equity=0.0;equity_of_last=0.0;
                }
           void setup(string _symbol,ENUM_ORDER_TYPE _direction){
                symbol=_symbol;
                direction=_direction;
                }
            int add_ticket(int ticket,double _last_lot,bool _additional){
                int ns=ArraySize(tickets)+1;
                ArrayResize(tickets,ns,0);
                tickets[ns-1]=ticket;
                if(!_additional){
                  last_lot=_last_lot;
                  }
                else{
                  last_lot+=_last_lot;
                  }
                total_lots+=last_lot;
                return(ns-1);
                }
         double get_equity(bool _swaps,bool _commisions){
                equity=0.0;
                equity_of_last=0.0;
                for(int i=0;i<ArraySize(tickets);i++){
                if(OrderSelect(tickets[i],SELECT_BY_TICKET)){
                equity_of_last=OrderProfit();
                if(_swaps){equity_of_last+=OrderSwap();}
                if(_commisions){equity_of_last+=OrderCommission();}               
                equity+=equity_of_last;
                }
                }
                return(equity);
                }             
           void calculate_next_limit(double _coefficient){
                calculate_next_limit(next_recovery_equity,_coefficient);
                }
           void calculate_next_limit(double _recent_tp,double _coefficient){
                next_recovery_equity=MathAbs(_recent_tp)*(-1.0)*_coefficient;
                }
           void save(int file_handle){
                symbol.save(file_handle);
                FileWriteDouble(file_handle,next_recovery_equity,DOUBLE_VALUE);
                FileWriteDouble(file_handle,last_lot,DOUBLE_VALUE);
                FileWriteDouble(file_handle,total_lots,DOUBLE_VALUE);
                FileWriteInteger(file_handle,(int)direction,INT_VALUE);
                FileWriteInteger(file_handle,((int)operate),INT_VALUE);
                FileWriteInteger(file_handle,ArraySize(tickets),INT_VALUE);
                for(int i=0;i<ArraySize(tickets);i++){
                FileWriteInteger(file_handle,tickets[i],INT_VALUE);
                }
                }
           bool load(int file_handle){
                reset(true,true);
                symbol.load(file_handle);
                next_recovery_equity=(double)FileReadDouble(file_handle,DOUBLE_VALUE);
                last_lot=(double)FileReadDouble(file_handle,DOUBLE_VALUE);
                total_lots=(double)FileReadDouble(file_handle,DOUBLE_VALUE);
                direction=(ENUM_ORDER_TYPE)FileReadInteger(file_handle,INT_VALUE);
                operate=(bool)FileReadInteger(file_handle,INT_VALUE);
                int total=(int)FileReadInteger(file_handle,INT_VALUE);
                if(total>0){
                ArrayResize(tickets,total,0);
                for(int i=0;i<total;i++){
                tickets[i]=(int)FileReadInteger(file_handle,INT_VALUE);
                }
                //if all open 
                  bool all_ok=true;
                return(all_ok);  
                }
                return(false);
                } 
};

//side , a side has symbols 
struct a_side{
a_symbol      symbols[];
user_text_var name;
bool          is_trailed,for_trail_closure,active;
              //for avg mode
bool          is_initiator,is_recoverer;
double        equity,equity_sl,par_equity,previous_close_equity;
int           hedged_time;//for double hedge , keeps counting as it reopens
              //
              a_side(void){reset(true,true);}
             ~a_side(void){reset(true,true);}
         void reset(bool remove_setup,bool remove_previous_equity_stats){
              if(remove_setup){
              name.reset();
              ArrayFree(symbols);
              }else{
              for(int i=0;i<ArraySize(symbols);i++){
              symbols[i].reset(false,true);
              }
              }
              if(remove_previous_equity_stats){
              hedged_time=0;
              previous_close_equity=0.0;
              }
              is_trailed=false;
              for_trail_closure=false;
              active=false;
              par_equity=0.0;
              equity=0.0;
              equity_sl=0.0;
              is_initiator=false;
              is_recoverer=false;
              }
              //add symbol without prefix or suffic
          int add_symbol(string _symbol,ENUM_ORDER_TYPE _direction){
              int ns=ArraySize(symbols)+1;
              ArrayResize(symbols,ns,0);
              symbols[ns-1].setup(_symbol,_direction);
              return(ns-1);
              }
              //buy and sell symbols without the prefix or the suffix
         void setup(string _name,
                    string &_buy_symbols[],
                    string &_sell_symbols[],
                    string _prefix,
                    string _suffix){
              reset(true,true);
              name=_name;
              //loop to buy symbols if they exist 
                for(int i=0;i<ArraySize(_buy_symbols);i++){
                string added=_buy_symbols[i];
                if(StringLen(_prefix)>0){StringReplace(added,_prefix,"");}
                if(StringLen(_suffix)>0){StringReplace(added,_suffix,"");}
                add_symbol(added,OP_BUY);
                }
              //loop to sell symbols if they exist 
                for(int i=0;i<ArraySize(_sell_symbols);i++){
                string added=_sell_symbols[i];
                if(StringLen(_prefix)>0){StringReplace(added,_prefix,"");}
                if(StringLen(_suffix)>0){StringReplace(added,_suffix,"");}
                add_symbol(added,OP_SELL);
                }
              }
         void setup_as_hedge_of(a_side &to_hedge,string _name){
              reset(true,true);
              name=_name;
              if(ArraySize(to_hedge.symbols)>0){
              ArrayResize(symbols,ArraySize(to_hedge.symbols),0);
              for(int i=0;i<ArraySize(to_hedge.symbols);i++){
              ENUM_ORDER_TYPE type=OP_BUY;
              if(to_hedge.symbols[i].direction==OP_BUY){type=OP_SELL;}
              symbols[i].setup(to_hedge.symbols[i].symbol.to_string(),type);
              }}
              }
         void activate(){active=all_orders_live();}
         void deactivate(){active=false;}
       double get_equity(bool _swaps,bool _commisions){
              equity=0.0;
              for(int i=0;i<ArraySize(symbols);i++){
              equity+=symbols[i].get_equity(_swaps,_commisions);
              }
              return(equity);
              }
       double get_equity_with_previous_too(bool _swaps,bool _commisions){
              double total=get_equity(_swaps,_commisions)+previous_close_equity;
              return(total);
              }
       double get_pole_active_and_recovery_equity(bool _swaps,bool _commisions){
              par_equity=0.0;
              for(int i=0;i<ArraySize(symbols);i++){
              if(symbols[i].operate){par_equity+=symbols[i].get_equity(_swaps,_commisions);}
              }
              return(par_equity);
              }              
       double get_active_positive_equity(bool _swaps,bool _commisions){
              double pos_equity=0.0;
              for(int i=0;i<ArraySize(symbols);i++){
              if(symbols[i].operate){
              double tis_equity=symbols[i].get_equity(_swaps,_commisions);
              if(tis_equity>0.0){pos_equity+=tis_equity;}
              }}
              return(pos_equity);
              }
              //returns "reason to save"
         bool monitor(bool _swaps,
                      bool _commisions,
                      double _trail_step,
                      bool _avg_mode,
                      bool _in_avg_mode,//this means we ARE in avg mode not that its on
                      double _avg_mode_trail_step,
                      uchar &_avg_mode_command,//signal to start avg mode 
                      bool _avg_mode_dont_close_init,
                      double _coefficient,
                      double _lot_step,
                      int _max_recoveries,
                      double _last_tp,
                      bool _recovery_side,
                      string _prefix,
                      string _suffix,
                      bool debug,
                      a_side &other_side){
              bool reason_to_save=false;
              _avg_mode_command=0;
              /*
              0 - nothing
              1 - start avg mode (on trail lock of first)
              2 - kill initiator (on trail lock of recovered)
              */
              //the trail step needs to be adaptive if we use additive lot and is on
                //if its on
                  if(DualHedge&&AdditionalLotForDualHedgeMode&&hedged_time>0){
                  //also we check if the additive has been added 
                    bool is_high_lot_side=false;
                    bool additiveUsed=false;
                    //compare one symbol 
                      if(symbols[0].total_lots>other_side.symbols[0].total_lots){is_high_lot_side=true;}
                      if((symbols[0].last_lot-AdditiveLotForDH)>AdditiveLotLimitMin){additiveUsed=true;}
                  //if its high side and high X is on 
                    if(additiveUsed&&is_high_lot_side&&TrailStepX_forHighLotSide>0.0){
                      double times=MathPow(TrailStepX_forHighLotSide,((double)hedged_time));
                      _trail_step=TrailStep*times;  
                      }
                  //if its low side and low X is on 
                    if(additiveUsed&&!is_high_lot_side&&TrailStepX_forLowLotSide>0.0){
                      double times=MathPow(TrailStepX_forLowLotSide,((double)hedged_time));
                      _trail_step=TrailStepX_forLowLotSide*times;
                      }
                  }
              if(active&&!for_trail_closure){
              double eq=get_equity(_swaps,_commisions);
                //no matter what monitor trailing 
                  //so trail candidate 
                    double nsl=eq-_trail_step;
                    double step=nsl-equity_sl;
                    //above previous above step
                    if(step>=_trail_step&&_trail_step>0.0){
                    //check spread 
                      bool spread_of_all=true;
                      for(int i=0;i<ArraySize(symbols);i++){
                      spread_of_all=spread_of_all&&getSpreadAllowance(_prefix+symbols[i].symbol.to_string()+_suffix,M_Spread_Mode,M_Spread_Max);
                      if(!spread_of_all){break;}
                      }
                    //if spread allows 
                    if(spread_of_all){
                    equity_sl=nsl;
                    is_trailed=true;
                    reason_to_save=true;
                    /*
                    if(_avg_mode&&!_in_avg_mode&&!_recovery_side){
                      _avg_mode_command=1;//start
                      is_initiator=true;
                      is_recoverer=false;
                      }
                    */
                    if(_avg_mode&&_in_avg_mode&&_recovery_side){
                      _avg_mode_command=2;//kill initiator
                      }
                    }
                    //
                    }   
                 //check trail hit 
                   if(is_trailed&&eq<=equity_sl){
                   if(!_recovery_side&&!_in_avg_mode&&_avg_mode){
                   
                      _avg_mode_command=1;//start
                      is_initiator=true;
                      is_recoverer=false;
                   
                   }
                   else if(_recovery_side||!_in_avg_mode){
                   for_trail_closure=true;
                   reason_to_save=true;
                   }else if(!_recovery_side&&_in_avg_mode){
                   if(_avg_mode_dont_close_init==false){
                     for_trail_closure=true;
                     reason_to_save=true;
                     }
                   }
                   
                   }
              //if recovery side 
                if(_recovery_side&&_lot_step>0.0){
                //not trailed 
                  if(!is_trailed){
                  //check individual symbols for recovery 
                    for(int i=0;i<ArraySize(symbols);i++)
                    {
                    //if active 
                    if(symbols[i].operate){
                    //if max recoveries allow 
                    if(ArraySize(symbols[i].tickets)<(_max_recoveries+1)||_max_recoveries==0){
                    //check the latest trade if it goes below the next recovery
                      if(symbols[i].equity_of_last<=symbols[i].next_recovery_equity){
                      //open a new recovery
                        //checks for recovery 
                          //spread
                            bool spread_allow=getSpreadAllowance(_prefix+symbols[i].symbol.to_string()+_suffix,M_Spread_Mode,M_Spread_Max);
                          //if can be traded
                            bool trade_allow=IsConnected()&&IsTradeAllowed(_prefix+symbols[i].symbol.to_string()+_suffix,TimeCurrent())&&IsTradeAllowed()&&(!IsTradeContextBusy());                           
                          //if margin enougn
                            double next_lot=symbols[i].last_lot+_lot_step;
                            margin_check check=CheckMarginRequired(_prefix+symbols[i].symbol.to_string()+_suffix,next_lot,symbols[i].direction);
                          //note : time is not limiting recoveries 
                            if(check.can_open&&trade_allow&&spread_allow)
                            {
                            //open order 
                              opener traded=OpenOrder(_prefix+symbols[i].symbol.to_string()+_suffix,symbols[i].direction,next_lot,MagicNumber,TradeComment,M_Attempts,M_Timeout,M_Slippage,clrBlue);
                              if(traded.opened)
                              {
                              reason_to_save=true;
                              //add ticket to symbol
                              symbols[i].add_ticket(traded.ticket,traded.lots,false);
                              //calculate the next recovery equity
                              symbols[i].calculate_next_limit(_coefficient);
                              //bounce
                              continue;
                              }else{
                              if(debug){Print("Cannot open recovery "+symbols[i].symbol.to_string()+" lot "+DoubleToString(next_lot,2));}
                              }
                            }else{
                            if(!check.can_open&&debug){Print("Margin not enough for recovery "+symbols[i].symbol.to_string()+" lot "+DoubleToStr(next_lot,2)+" margin required : "+DoubleToString(check.margin_required,2)+" , free margin : "+DoubleToString(AccountFreeMargin(),2));}
                            if(!trade_allow&&debug){Print("Trade not allowed "+symbols[i].symbol.to_string());}
                            if(!spread_allow&&debug){Print("Spread not allowed "+symbols[i].symbol.to_string());}
                            }
                      }
                    }
                    }
                    //if active ends here
                    }
                  //check individual symbols for recovery ends here 
                  }
                //trailed - nothing (already above)
                }
              }
              return(reason_to_save);
              }
         void save(int file_handle){
              //Print("SAVING SIDE : "+name.to_string()+" ACTIVE : "+active);
              name.save(file_handle);
              FileWriteInteger(file_handle,((uchar)is_initiator),CHAR_VALUE);
              FileWriteInteger(file_handle,((uchar)is_recoverer),CHAR_VALUE);
              FileWriteInteger(file_handle,((uchar)is_trailed),CHAR_VALUE);
              FileWriteInteger(file_handle,((uchar)active),CHAR_VALUE);
              FileWriteInteger(file_handle,((uchar)for_trail_closure),CHAR_VALUE);
              FileWriteDouble(file_handle,equity_sl,DOUBLE_VALUE);
              FileWriteDouble(file_handle,previous_close_equity,DOUBLE_VALUE);
              FileWriteInteger(file_handle,hedged_time,INT_VALUE);
              //# of symbols 
                FileWriteInteger(file_handle,ArraySize(symbols),INT_VALUE);
                for(int i=0;i<ArraySize(symbols);i++){symbols[i].save(file_handle);}
              }
         bool load(int file_handle,int &total_tickets){
              reset(true,true);
              name.load(file_handle);
              Print("Loading side "+name.to_string());
              is_initiator=(bool)FileReadInteger(file_handle,CHAR_VALUE);
              Print("Is initiator "+is_initiator);
              is_recoverer=(bool)FileReadInteger(file_handle,CHAR_VALUE);
              Print("Is recovered "+is_recoverer);
              is_trailed=(bool)FileReadInteger(file_handle,CHAR_VALUE);
              active=(bool)FileReadInteger(file_handle,CHAR_VALUE);
              Print("Is active "+active);
              for_trail_closure=(bool)FileReadInteger(file_handle,CHAR_VALUE);
              Print("ForTrailClosure "+for_trail_closure);
              equity_sl=(double)FileReadDouble(file_handle,DOUBLE_VALUE);
              previous_close_equity=(double)FileReadDouble(file_handle,DOUBLE_VALUE);
              hedged_time=(int)FileReadInteger(file_handle,INT_VALUE);
              //# of symbols 
                int total=(int)FileReadInteger(file_handle,INT_VALUE);
                Print("Total symbols ("+total+")");
                //Print("SIDE "+name.to_string()+" Symbols "+IntegerToString(total));
                if(total>0){
                ArrayResize(symbols,total,0);
                bool okay=true;
                bool has_tickets=false;
                for(int i=0;i<total;i++){
                bool loaded=symbols[i].load(file_handle);
                Print("LOAD "+symbols[i].symbol.to_string()+" "+loaded);
                okay=(okay&&loaded);
                if(ArraySize(symbols[i].tickets)>0){has_tickets=true;}
                total_tickets+=ArraySize(symbols[i].tickets);
                }
                okay=(okay&&has_tickets);
                //if active all tickets must be open 
                if(active&&okay){
                Print("Active and Okay");
                //if(for_trail_closure){Print("For Trail Closure");}
                okay=all_orders_live();
                Print("Okay[post check]:"+okay);
                }
                return(okay);
                }
              return(false);
              }
              private:
         bool all_orders_live(){
              for(int i=0;i<ArraySize(symbols);i++){
              if(symbols[i].operate){
              for(int t=0;t<ArraySize(symbols[i].tickets);t++){
              if(OrderSelect(symbols[i].tickets[t],SELECT_BY_TICKET)){
              if(OrderCloseTime()!=0){
              return(false);
              }
              }else{return(false);}
              }}}
              return(true);
              }

};

//a system , has sides 
enum hat_stage{
hat_stage_void=0,//void
hat_stage_waiting=1,//waiting
hat_stage_hedge=2,//hedged
hat_stage_recovery=3,//recovering
hat_stage_avg_recovery_a=4,//avgModeRecovery a
hat_stage_avg_recovery_b=5//avgModeRecovery b
};
//recovery a is when the recovery mode is enabled by one of the sides 
//getting a lock on trail
//recovery b is when the recovered side locks trail , where we close the
//initial side that triggered avg mode (if open)
string stage_texts[]={"Nothing","Waiting","Hedged","Recovering","AvgMdRecovering A","AvgMdRecovering B"};
struct hat_revolver;
struct hat_system{
int       active_hat;//index of active hat , for ease of editing 
a_side    sides[];
hat_stage stage;
bool      busy,debug;
double    last_trail_close,equity;
bool      pole_trailed,first_poled;
double    pole_equity,pole_trail_stop;
          //
          hat_system(void){reset(true,true);}
         ~hat_system(void){reset(true,true);}
     void reset(bool remove_setup,bool remove_previous_trail_equity){
          if(remove_setup){
          ArrayFree(sides);
          }else{
          for(int si=0;si<ArraySize(sides);si++){
          sides[si].reset(false,remove_previous_trail_equity);
          }
          }
          first_poled=false;
          pole_trailed=false;
          pole_equity=0.0;
          pole_trail_stop=0.0;
          debug=false;
          busy=false;
          stage=hat_stage_void;
          last_trail_close=0.0;
          active_hat=0;
          }
      int add_side(string _name,
                   string &_buy_symbols[],
                   string &_sell_symbols[],
                   string _prefix,
                   string _suffix){
          int ns=ArraySize(sides)+1;
          ArrayResize(sides,ns,0);
          sides[ns-1].setup(_name,_buy_symbols,_sell_symbols,_prefix,_suffix);
          return(ns-1);
          }
     void setup(string &_buy_symbols[],
                string &_sell_symbols[],
                bool for_debug,
                int _hat_id,
                string _prefix,
                string _suffix){
          reset(true,true);
          active_hat=_hat_id;
          add_side("Normal Side",_buy_symbols,_sell_symbols,_prefix,_suffix);
          add_side("Hedged Side",_sell_symbols,_buy_symbols,_prefix,_suffix);
          debug=for_debug;
          }
     void reverse_setup(){
          if(ArraySize(sides)==2){
          reset(false,true);
          a_side temp_side;
          temp_side=sides[0];
          sides[0]=sides[1];
          sides[1]=temp_side;
          }}
     bool monitor(bool _swaps,
                  bool _commisions,
                  double _trail_step,
                  double _coefficient,
                  double _lot_step,
                  bool _avg_mode,
                  double _avg_mode_trail_step,
                  bool _avg_mode_dont_close_init,
                  double _initial_lot,
                  int _max_recoveries,
                  string _prefix,
                  string _suffix,
                  bool &kill_it){
          busy=true;
          kill_it=false;
          bool error=false;//reason to exit
          bool reason_to_save=false;
          uchar _avg_command=0;
          //if stage is void or waiting
            if(stage==hat_stage_void||stage==hat_stage_waiting){
            if(stage==hat_stage_void){stage=hat_stage_waiting;}
            //check time 
              bool time_allows=CheckMarselTimeAllow();
              //time okay
                if(time_allows)
                {
                 double mr=0.0;//for display
                 bool spread_allow=getSpreadAllowanceForSystem(M_Spread_Mode,M_Spread_Max,_prefix,_suffix);
                 bool session_allow=getSessionAllowanceForSystem(TimeCurrent(),_prefix,_suffix);
                 bool margin_allow=getMarginAllowanceForSystem(_initial_lot,_prefix,_suffix,mr);
                 bool tradable=margin_allow&&(!IsTradeContextBusy())&&(IsConnected())&&(IsTradeAllowed())&&spread_allow&&session_allow;
                 //trade the initial positions 
                   if(tradable){
                   //open trades 
                     //loop to sides 
                       for(int si=0;si<ArraySize(sides);si++)
                       {
                       //loop to symbols 
                         for(int sy=0;sy<ArraySize(sides[si].symbols);sy++)
                          {
                          //Print("Side["+si+"]Symbol["+sides[si].symbols[sy].symbol.to_string()+"]Direction["+sides[si].symbols[sy].direction+"]");
                          //trade 
                            opener traded=OpenOrder(_prefix+sides[si].symbols[sy].symbol.to_string()+_suffix,sides[si].symbols[sy].direction,_initial_lot,MagicNumber,TradeComment,M_Attempts,M_Timeout,M_Slippage,clrWhite);
                            if(traded.opened){
                            //add ticket to symbol
                              int t=sides[si].symbols[sy].add_ticket(traded.ticket,traded.lots,false);
                              
                            }else{
                            if(debug){
                            Print("Cannot open initial "+DoubleToString(_initial_lot,2)+" "+sides[si].symbols[sy].symbol.to_string()+" order SIDE["+sides[si].name.to_string()+"");
                            error=true;
                            break;
                            }
                            }
                            if(traded.opened&&(sy<(ArraySize(sides[si].symbols)-1)||si<(ArraySize(sides)-1))){Sleep(M_Timeout);}
                          }
                       //loop to symbols ends here 
                       if(error){break;}
                       }
                       if(!error)
                         {
                         reason_to_save=true;
                         for(int si=0;si<ArraySize(sides);si++){sides[si].activate();}
                         stage=hat_stage_hedge;
                         getEquity(_swaps,_commisions);
                         }
                       
                     //loop to sides 
                   }else if(!tradable){
                   //if not enough margin 
                     if(!margin_allow&&debug){Print("Margin Required = "+DoubleToString(mr,2)+AccountCurrency()+" ,Free Margin : "+DoubleToString(AccountFreeMargin(),2)+AccountCurrency());}
                     if(!session_allow&&debug){Print("One of the assets is not in a trading session");}
                   }
                }
              //time okay ends here 
            }
          //if stage is void or waiting ends here
          //if stage is hedge 
          else if(stage==hat_stage_hedge){
          int to_close=0;
          for(int si=0;si<ArraySize(sides);si++){
          //if normal hedge stage 
          if(POLE_Trailing&&POLE_Activate_Limit&&first_poled){
          a_side voidside;
          bool _rts=sides[si].monitor(_swaps,_commisions,_trail_step,_avg_mode,false,_avg_mode_trail_step,_avg_command,_avg_mode_dont_close_init,_coefficient,_lot_step,_max_recoveries,0.0,true,_prefix,_suffix,debug,voidside);
          if(_rts){reason_to_save=true;}          
          }else{
          a_side otherside;
          if(si==0&&ArraySize(sides)==2){otherside=sides[1];}
          if(si==1&&ArraySize(sides)==2){otherside=sides[0];}
          bool _rts=sides[si].monitor(_swaps,_commisions,_trail_step,_avg_mode,false,_avg_mode_trail_step,_avg_command,_avg_mode_dont_close_init,_coefficient,_lot_step,_max_recoveries,0.0,false,_prefix,_suffix,debug,otherside);
          if(_rts){reason_to_save=true;}
          //avg mode stuffs
            if(_avg_mode&&_avg_command==1){
            //initiator is set internally
              //otherside.is_recoverer=true;
              int os=0;if(si==0){os=1;}
            //cancel existing trail on other side
              sides[os].is_recoverer=true;
              sides[os].is_trailed=false;
              sides[os].equity_sl=0.0;
            //state change 
              stage=hat_stage_avg_recovery_a;
              reason_to_save=true;
              last_trail_close=sides[si].equity_sl;//get_equity(_swaps,_commisions);
                   for(int sy=0;sy<ArraySize(sides[os].symbols);sy++)
                     {
                     if(sides[os].symbols[sy].operate){sides[os].symbols[sy].calculate_next_limit(last_trail_close,_coefficient);}
                     }
            }
          }
          if(sides[si].for_trail_closure){to_close++;}
          }
          getEquity(_swaps,_commisions);
          //are any sides bound for trail closure 
            if(to_close>0){
            int did_close=0;
            int closedside=-1;
            for(int si=0;si<ArraySize(sides);si++)
              {
              if(sides[si].for_trail_closure)
                {
                bool closed=CloseSide(sides[si]);
                if(closed){
                   closedside=si;
                   did_close++;
                   sides[si].deactivate();
                   sides[si].for_trail_closure=false;
                   last_trail_close=sides[si].get_equity(_swaps,_commisions);
                   }
                else if(!closed&&debug){
                   Print("Cannot close Side : "+sides[si].name.to_string()+" for trail tp");
                   }
                }  
              }
            //if no active states left , reset cycle - in the unlikely case all closed on tp 
              if(did_close==to_close)
              {
              bool active_states=false;
              for(int si=0;si<ArraySize(sides);si++)
                 {
                 if(sides[si].active)
                   {
                   active_states=true;
                   for(int sy=0;sy<ArraySize(sides[si].symbols);sy++)
                     {
                     if(sides[si].symbols[sy].operate&&(!DualHedge||closedside==-1)){sides[si].symbols[sy].calculate_next_limit(last_trail_close,_coefficient);}
                     }
                   }
                 }
              if(active_states){
              /*so if the double hedge is on and pole is off 
                instead of going to recovery we reopen this side 
                i assume i'm blocking further operations until this function ends ...yes busy=true
                so we reopen 
              */
                  int opposite_side=0;
                  if(closedside==0){opposite_side=1;}              
              if(DualHedge&&!POLE_Trailing&&closedside!=-1){
              //stage as is 
                //last trail close is pumped in the previous "collector" of the side 
                  sides[closedside].previous_close_equity+=last_trail_close;
                  sides[closedside].hedged_time++;
                  //this will reset the lots so we gotta grab em if dual hedge lot doubler is on
                    double lot_carrier[],opposite_lot_carrier[];
                    if(DualHedgeLotMode!=dh_lot_mode_same){
                    ArrayResize(lot_carrier,ArraySize(sides[closedside].symbols),0);
                    ArrayResize(opposite_lot_carrier,ArraySize(sides[closedside].symbols),0);
                    for(int i=0;i<ArraySize(lot_carrier);i++){
                       
                       lot_carrier[i]=sides[closedside].symbols[i].last_lot;
                       //and adjust it 
                         if(DualHedgeLotMode==dh_lot_mode_additive){
                         lot_carrier[i]+=DualHedgeLotFactor;//add
                         }else if(DualHedgeLotMode==dh_lot_mode_multiple){
                         lot_carrier[i]*=DualHedgeLotFactor;//multiply
                         }
                         //check
                         lot_carrier[i]=CheckLot(_prefix+sides[closedside].symbols[i].symbol.to_string()+_suffix,lot_carrier[i]);
                       opposite_lot_carrier[i]=lot_carrier[i];//store this here for now
                       //if no rebalance but additive is on 
                         if(!DualHedgeReBalance&&AdditionalLotForDualHedgeMode){
                           //we then use the max lot of both sides 
                             //and it also happens to be the last lot 
                               //but we also have the limit so 
                                 //find the value first 
                                   double aL=MathMax(sides[closedside].symbols[i].total_lots,sides[opposite_side].symbols[i].total_lots);
                                   //if this is above the limit
                                   if(aL>=AdditiveLotLimitMin){
                                     lot_carrier[i]=aL+AdditiveLotForDH;
                                     //otherwise use the calc
                                     }
                           }
                       }
                    }
                  //if reBalance other side is on for dual hedge 
                    if(DualHedgeReBalance){
                    //then run to the opposite side - the one that is still open 
                      for(int i=0;i<ArraySize(opposite_lot_carrier);i++){
                         //if we use additive to the additive (the opposite side tho)
                           if(AdditionalLotForDualHedgeMode){
                             //and the opposite lot is above the limit 
                               if(opposite_lot_carrier[i]>=AdditiveLotLimitMin){
                                 //add
                                   opposite_lot_carrier[i]+=AdditiveLotForDH;
                                 }
                             }
                         opposite_lot_carrier[i]-=sides[opposite_side].symbols[i].last_lot;
                         //so essentially open what is missing right ?
                           opposite_lot_carrier[i]=CheckLot(_prefix+sides[opposite_side].symbols[i].symbol.to_string()+_suffix,opposite_lot_carrier[i]);
                         }
                    }
                  sides[closedside].reset(false,false);//leave symbols leave prev close
                  //and reopen it - i assume the other side continues as is 
                       //loop to symbols 
                       error=false;
                         for(int sy=0;sy<ArraySize(sides[closedside].symbols);sy++)
                          {
                          //lot to trade 
                            double lot_to_re=_initial_lot;
                            //if dh mode
                            if(DualHedgeLotMode!=dh_lot_mode_same){
                            lot_to_re=lot_carrier[sy];
                            }
                          //trade 
                            opener traded=OpenOrder(_prefix+sides[closedside].symbols[sy].symbol.to_string()+_suffix,sides[closedside].symbols[sy].direction,lot_to_re,MagicNumber,TradeComment,M_Attempts,M_Timeout,M_Slippage,clrWhite);
                            if(traded.opened){
                            //add ticket to symbol
                              int t=sides[closedside].symbols[sy].add_ticket(traded.ticket,traded.lots,false);
                              
                            }else{
                            if(debug){
                            Print("Cannot open double "+DoubleToString(_initial_lot,2)+" "+sides[closedside].symbols[sy].symbol.to_string()+" order SIDE["+sides[closedside].name.to_string()+"");
                            error=true;
                            break;
                            }
                            }
                            if(traded.opened&&(sy<(ArraySize(sides[closedside].symbols)-1)||closedside<(ArraySize(sides)-1))){Sleep(M_Timeout);}
                          }
                       //loop to symbols ends here 
                       if(!error){
                       sides[closedside].activate();
                       }
                       //if rebalance is on 
                       if(DualHedgeReBalance){
                         for(int sy=0;sy<ArraySize(sides[opposite_side].symbols);sy++)
                          {
                          //lot to trade 
                            double lot_to_re=_initial_lot;
                            //if dh mode
                            if(DualHedgeLotMode!=dh_lot_mode_same){
                            lot_to_re=opposite_lot_carrier[sy];
                            }
                          //trade 
                            opener traded=OpenOrder(_prefix+sides[opposite_side].symbols[sy].symbol.to_string()+_suffix,sides[opposite_side].symbols[sy].direction,lot_to_re,MagicNumber,TradeComment,M_Attempts,M_Timeout,M_Slippage,clrWhite);
                            if(traded.opened){
                            //add ticket to symbol
                              int t=sides[opposite_side].symbols[sy].add_ticket(traded.ticket,traded.lots,true);               
                            }else{
                            if(debug){
                            Print("Cannot open reBalance "+DoubleToString(_initial_lot,2)+" "+sides[opposite_side].symbols[sy].symbol.to_string()+" order SIDE["+sides[opposite_side].name.to_string()+"");
                            error=true;
                            break;
                            }
                            }
                            if(traded.opened&&(sy<(ArraySize(sides[opposite_side].symbols)-1)||opposite_side<(ArraySize(sides)-1))){Sleep(M_Timeout);}
                          }                       
                       }
                       //if rebalance is on ends here 
              }else{
              stage=hat_stage_recovery;
              }
              reason_to_save=true;
              }else{
              kill_it=true;
              }
              }
            }else{//IF NO SIDES BOUND FOR CLOSURE ON HEDGE
            //and Double Hedge is on 
              if(DualHedge&&!POLE_Trailing){
              //get equity with previous of whole system
                double totalEQ=getEquityWithPrevious(_swaps,_commisions);
                double previousONLY=getOnlyPrevious();
              //now if any of the sides are on more than one hedge , meaning 
              //we have at least one double 
                int total_hedges=getHedgesCount();//so if this is 1+
                if(total_hedges>=1){
                //and totalEQ > previousONLY
                  if(totalEQ>previousONLY){
                  //close cycle 
                   bool closed=CloseAll(false,this);
                   if(closed){
                    kill_it=true;                  
                  }}
                //or TotalEQ is profitable 
                  else if(DualHedgeLotProfitableClose&&totalEQ>0.0){
                  //close cycle 
                   bool closed=CloseAll(false,this);
                   if(closed){
                    kill_it=true;                   
                  }}
                }
              }
            //POLE
              if(POLE_Trailing){
              get_pole_equity(_swaps,_commisions);
              bool spread_allow=getSpreadAllowanceForSystem(M_Spread_Mode,M_Spread_Max,_prefix,_suffix);
              //hit trail
                if(pole_trailed&&pole_equity<=pole_trail_stop&&spread_allow){
                //close all poles !
                  bool closed_poles=ClosePole(true,this);
                  if(closed_poles){
                  Print("Closed poles");
                  pole_trailed=false;
                  pole_trail_stop=0.0;
                  pole_equity=0.0;
                  //checks 
                      bool normal_side_alive=false,hedged_side_alive=false;
                      for(int si=0;si<ArraySize(sides);si++){
                      for(int sy=0;sy<ArraySize(sides[si].symbols);sy++){
                      if(sides[si].symbols[sy].operate){
                      if(si==0){normal_side_alive=true;}else if(si==1){hedged_side_alive=true;}
                      }}}
                    //if nothing is left then reset 
                      if(!normal_side_alive&&!hedged_side_alive){
                      //reset(false);//reset cycle
                        kill_it=true;                      
                      }
                    //if both sides left and its the first POLE and LIMITS mode is on
                      else if(normal_side_alive&&hedged_side_alive&&POLE_Activate_Limit&&!first_poled){
                      //A.Loop into active symbols (not poled)
                        for(int sid=0;sid<=1;sid++)
                        {
                        for(int sym=0;sym<ArraySize(sides[sid].symbols);sym++)
                          {
                          if(sides[sid].symbols[sym].operate)
                            {
                            //log the equity of the symbol here (of the latest order) as the last close 
                              double last_close=sides[sid].symbols[sym].equity_of_last;
                              sides[sid].symbols[sym].next_recovery_equity=last_close;
                              //open an additional 
                              double next_lot=sides[sid].symbols[sym].last_lot+StepLot;
                                opener traded=OpenOrder(_prefix+sides[sid].symbols[sym].symbol.to_string()+_suffix,sides[sid].symbols[sym].direction,next_lot,MagicNumber,TradeComment,M_Attempts,M_Timeout,M_Slippage,clrBlue);
                                if(traded.opened)
                                {
                                reason_to_save=true;
                                //add ticket to symbol
                                sides[sid].symbols[sym].add_ticket(traded.ticket,traded.lots,false);
                                //calculate the next recovery equity
                                sides[sid].symbols[sym].calculate_next_limit(_coefficient);
                                }else{
                                 if(debug){Print("Cannot open recovery "+sides[sid].symbols[sym].symbol.to_string()+" lot "+DoubleToString(next_lot,2));}
                                }                                
                              //open an additional ends here
                            }
                          }
                        }
                      //A.Loop into active symbols (not poled) ends here 
                      first_poled=true;
                      }
                    //if normal side side closed switch to recovery 
                      else if(normal_side_alive&&!hedged_side_alive){
                      sides[1].deactivate();
                      sides[1].for_trail_closure=false;
                      last_trail_close=sides[1].get_equity(_swaps,_commisions);                      
                      stage=hat_stage_recovery;
                      for(int sy=0;sy<ArraySize(sides[0].symbols);sy++)
                         {
                         if(sides[0].symbols[sy].operate){sides[0].symbols[sy].calculate_next_limit(last_trail_close,_coefficient);}
                         }                      
                      reason_to_save=true;                      
                      }
                    //if hedged side closed switch to recovery 
                      else if(!normal_side_alive&&hedged_side_alive){
                      sides[0].deactivate();
                      sides[0].for_trail_closure=false;
                      last_trail_close=sides[0].get_equity(_swaps,_commisions);                      
                      stage=hat_stage_recovery;
                      for(int sy=0;sy<ArraySize(sides[1].symbols);sy++)
                         {
                         if(sides[1].symbols[sy].operate){sides[1].symbols[sy].calculate_next_limit(last_trail_close,_coefficient);}
                         }                      
                      reason_to_save=true;                       
                      }
                  }
                reason_to_save=true;
                }else{
                 double nsl=pole_equity-POLE_Trail_Step;
                //if above 
                 if(nsl>=POLE_Trail_Above){
                 //and step 
                   double step=nsl-pole_trail_stop;
                   if(step>=POLE_Trail_Step||!pole_trailed){
                   pole_trailed=true;
                   pole_trail_stop=nsl;
                   reason_to_save=true;
                   }
                 }
                }
              }
            }//IF NO SIDES BOUND FOR CLOSURE ON HEDGE ENDS HERE
            
          }
          //if stage is hedge ends here 
          //if stage is avg recovery a
          else if(stage==hat_stage_avg_recovery_a){
          /*
          here both sides are open and when the trail will be set 
          on the recovering side then we close the initiator
          */
          int to_close=0;
          for(int si=0;si<ArraySize(sides);si++){
          if(sides[si].active){
          a_side otherside;
          if(si==0&&ArraySize(sides)==2){otherside=sides[1];}
          if(si==1&&ArraySize(sides)==2){otherside=sides[0];}
          
          bool _rts=false;
          //if side is initiator
          if(sides[si].is_initiator){
          if(sides[si].monitor(_swaps,_commisions,_trail_step,_avg_mode,true,_avg_mode_trail_step,_avg_command,_avg_mode_dont_close_init,_coefficient,_lot_step,_max_recoveries,0.0,false,_prefix,_suffix,debug,otherside)){reason_to_save=true;}
          }
          //if side is recoverer
          else if(sides[si].is_recoverer){
          if(sides[si].monitor(_swaps,_commisions,_avg_mode_trail_step,_avg_mode,true,_avg_mode_trail_step,_avg_command,_avg_mode_dont_close_init,_coefficient,_lot_step,_max_recoveries,last_trail_close,true,_prefix,_suffix,debug,otherside)){reason_to_save=true;}
          }
          if(_rts){reason_to_save=true;}
          //avg mode stuffs
            if(_avg_mode&&_avg_command==2){
            //this means we must shut off 
              int os=0;if(si==0){os=1;}
              //the initiator
                if(sides[os].active){
                sides[os].for_trail_closure=true;
                to_close++;
                }
            }
          if(sides[si].for_trail_closure){to_close++;}
          }}
          getEquity(_swaps,_commisions);
          //are any sides bound for trail closure 
            if(to_close>0){
            int did_close=0;
            int closedside=-1;
            for(int si=0;si<ArraySize(sides);si++)
              {
              if(sides[si].for_trail_closure)
                {
                bool closed=CloseSide(sides[si]);
                if(closed){
                   closedside=si;
                   did_close++;
                   sides[si].deactivate();
                   sides[si].for_trail_closure=false;
                   last_trail_close=sides[si].get_equity(_swaps,_commisions);
                   }
                else if(!closed&&debug){
                   Print("Cannot close Side : "+sides[si].name.to_string()+" for trail tp");
                   }
                }  
              }
            //if no active states left , reset cycle - in the unlikely case all closed on tp 
              if(did_close==to_close)
              {
              bool actives=false;
              for(int si=0;si<ArraySize(sides);si++){
                if(sides[si].active){ 
                  actives=true;
                  }
                }
              if(actives){
              reason_to_save=true;
              //and what happens ? we transition to final phase of avg recovery
              stage=hat_stage_avg_recovery_b;
              }else{//if by any chance the are both gone
              kill_it=true;
              }
              }
            }
            
          }
          //if stage is avg recovery a
          else if(stage==hat_stage_avg_recovery_b){
          /*
          here both sides are open and when the trail will be set 
          on the recovering side then we close the initiator
          */
          bool actives_check=false;
          int to_close=0;
          for(int si=0;si<ArraySize(sides);si++){
          a_side otherside;
          if(sides[si].active){
          actives_check=true;
          if(si==0&&ArraySize(sides)==2){otherside=sides[1];}
          if(si==1&&ArraySize(sides)==2){otherside=sides[0];}
          
          bool _rts=false;
          //if side is recoverer
          if(sides[si].is_recoverer){
          if(sides[si].monitor(_swaps,_commisions,_avg_mode_trail_step,_avg_mode,true,_avg_mode_trail_step,_avg_command,_avg_mode_dont_close_init,_coefficient,_lot_step,_max_recoveries,last_trail_close,true,_prefix,_suffix,debug,otherside)){reason_to_save=true;}
          }
          if(_rts){reason_to_save=true;}
          if(sides[si].for_trail_closure){to_close++;}
          }}
          getEquity(_swaps,_commisions);
          //if no actives bounce
            if(!actives_check){
            kill_it=true;
            }
          //are any sides bound for trail closure 
            if(to_close>0){
            int did_close=0;
            int closedside=-1;
            for(int si=0;si<ArraySize(sides);si++)
              {
              if(sides[si].for_trail_closure)
                {
                bool closed=CloseSide(sides[si]);
                if(closed){
                   closedside=si;
                   did_close++;
                   sides[si].deactivate();
                   sides[si].for_trail_closure=false;
                   last_trail_close=sides[si].get_equity(_swaps,_commisions);
                   }
                else if(!closed&&debug){
                   Print("Cannot close Side : "+sides[si].name.to_string()+" for trail tp");
                   }
                }  
              }
            //if no active states left , reset cycle - in the unlikely case all closed on tp 
              if(did_close==to_close)
              {
              kill_it=true;
              }
            }
            
          }
          //if stage is recovery 
          else if(stage==hat_stage_recovery){
          int to_close=0;
          for(int si=0;si<ArraySize(sides);si++){
          if(sides[si].active){
          a_side voidside;
          bool _rts=sides[si].monitor(_swaps,_commisions,_trail_step,_avg_mode,false,_avg_mode_trail_step,_avg_command,_avg_mode_dont_close_init,_coefficient,_lot_step,_max_recoveries,last_trail_close,true,_prefix,_suffix,debug,voidside);
          if(_rts){reason_to_save=true;}
          if(sides[si].for_trail_closure){to_close++;}
          }}
          getEquity(_swaps,_commisions); 
          //are any sides bound for trail closure 
            if(to_close>0){
            int did_close=0;
            for(int si=0;si<ArraySize(sides);si++)
              {
              if(sides[si].for_trail_closure)
                {
                bool closed=CloseSide(sides[si]);
                if(closed){
                   did_close++;
                   sides[si].deactivate();
                   sides[si].for_trail_closure=false;
                   //last_trail_close=sides[si].equity_sl;
                   }
                else if(!closed&&debug){
                   Print("Cannot close Recovery Side : "+sides[si].name.to_string()+" for trail tp");
                   }
                }  
              }
            //if no active states left , reset cycle - in the unlikely case all closed on tp 
              if(did_close==to_close)
              {
              bool active_states=false;
              for(int si=0;si<ArraySize(sides);si++)
                 {
                 if(sides[si].active)
                   {
                   active_states=true;
                   break;
                   }
                 }
              if(active_states){
              stage=hat_stage_recovery;
              reason_to_save=true;
              }else{
              //reset(false);//reset cycle
              kill_it=true;
              }
              }
            }else{
            //POLE
              if(POLE_Trailing){
              get_pole_equity(_swaps,_commisions);
              //hit trail
                if(pole_trailed&&pole_equity<=pole_trail_stop){
                //close all poles !
                  bool closed_poles=ClosePole(true,this);
                  if(closed_poles){
                  pole_trailed=false;
                  pole_trail_stop=0.0;
                  pole_equity=0.0;
                  //checks 
                      bool normal_side_alive=false,hedged_side_alive=false;
                      for(int si=0;si<ArraySize(sides);si++){
                      if(sides[si].active){
                      for(int sy=0;sy<ArraySize(sides[si].symbols);sy++){
                      if(sides[si].symbols[sy].operate){
                      if(si==0){normal_side_alive=true;}else if(si==1){hedged_side_alive=true;}
                      }}}}
                    //if nothing is left then reset 
                      if(!normal_side_alive&&!hedged_side_alive){
                      //reset(false);//reset cycle
                       kill_it=true;                  
                      }                  
                  }
                reason_to_save=true;
                }else{
                 double nsl=pole_equity-POLE_Trail_Step;
                //if above 
                 if(nsl>=POLE_Trail_Above){
                 //and step 
                   double step=nsl-pole_trail_stop;
                   if(step>=POLE_Trail_Step||!pole_trailed){
                   pole_trailed=true;
                   pole_trail_stop=nsl;
                   reason_to_save=true;
                   }
                 }
                }
              }
            }                  
          }
          //if stage is recovery ends here
          if(!error){busy=false;
          if(reason_to_save&&!IsTesting()&&!kill_it){
          save(SystemFolder,SystemFilename);
          }
          }
          return(!error);//return the opposite of error , so , if all okay it returns true
          }
     void save(string folder,string filename){
          string location=folder+"\\"+filename;
          if(FileIsExist(location)){FileDelete(location);}
          int f=FileOpen(location,FILE_WRITE|FILE_BIN);
          if(f!=INVALID_HANDLE){
          //hat active 
            FileWriteInteger(f,active_hat,INT_VALUE);
          //stage 
            FileWriteInteger(f,(int)stage,INT_VALUE);
          //# of sides 
            FileWriteInteger(f,ArraySize(sides),INT_VALUE);
          //the sides 
            for(int i=0;i<ArraySize(sides);i++){
            sides[i].save(f);
            }
          //the last tp close 
            FileWriteDouble(f,last_trail_close,DOUBLE_VALUE);
          //pole
            FileWriteInteger(f,((int)pole_trailed),INT_VALUE);
            FileWriteDouble(f,pole_equity,DOUBLE_VALUE);
            FileWriteDouble(f,pole_trail_stop,DOUBLE_VALUE);
            FileWriteInteger(f,((int)first_poled),INT_VALUE);
          FileClose(f);
          }
          }
     bool load(string folder,string filename){
          reset(true,true);
          string location=folder+"\\"+filename;
          //if it exists 
            if(FileIsExist(location)){
            //Print("File "+location+" Exists");
            int f=FileOpen(location,FILE_READ|FILE_BIN);
            if(f!=INVALID_HANDLE){
            //active hat 
              active_hat=(int)FileReadInteger(f,INT_VALUE);
              Print("Loading active HAT("+active_hat+")");
              //no point in associating this with what is in the settings 
              //as the hat will already be running , but , 
              //we provide a display in the deck so that the user 
              //can see which group they have to edit to alter 
              //the next pairs that are going to be executed
              //note the hat must reflect the group id as in the inputs 
              //NOT how many groups are eligible (i.e. if group2 is empty and group3 is activated we don't 
              //set an id of 2(as in the second eligible) but an id of 3 as in the 3rd group in the inputs 
            //stage 
              stage=(hat_stage)FileReadInteger(f,INT_VALUE);
              Print("Stage : "+stage_texts[(int)stage]);
            //total sides 
              int total=(int)FileReadInteger(f,INT_VALUE);
              bool sides_okay=false;
              int total_tickets=0;
            //sides 
              if(total>0){
              sides_okay=true;
              ArrayResize(sides,total,0);
              for(int i=0;i<total;i++){
              bool loaded=sides[i].load(f,total_tickets);
              Print("LOAD SIDE : "+sides[i].name.to_string()+" "+loaded);
              sides_okay=(sides_okay&&loaded);
              }                           
              }
            //if total tickets zero false
              if(total_tickets==0){sides_okay=false;}
            last_trail_close=(double)FileReadDouble(f,DOUBLE_VALUE);   
            pole_trailed=(bool)FileReadInteger(f,INT_VALUE);
            pole_equity=(double)FileReadDouble(f,DOUBLE_VALUE);
            pole_trail_stop=(double)FileReadDouble(f,DOUBLE_VALUE);   
            first_poled=(bool)FileReadInteger(f,INT_VALUE);       
            FileClose(f);
            return(sides_okay);
            }}
          return(false);
          }
   double getOnlyPrevious(){
          double total=0.0;
          for(int si=0;si<ArraySize(sides);si++){
          total+=sides[si].previous_close_equity;
          }         
          return(total);
          }
      int getHedgesCount(){
          int total=0;
          for(int si=0;si<ArraySize(sides);si++){
          total+=sides[si].hedged_time;
          }
          return(total);
          }          
          private:
     bool getSpreadAllowanceForSystem(spread_mode _m_spread_mode,double max_spread,string _prefix,string _suffix){
          bool allowed=true;
          for(int si=0;si<ArraySize(sides);si++){
          for(int sy=0;sy<ArraySize(sides[si].symbols);sy++){
          bool sy_allow=getSpreadAllowance(_prefix+sides[si].symbols[sy].symbol.to_string()+_suffix,_m_spread_mode,max_spread);
          allowed=(allowed&&sy_allow);
          }}
          return(allowed);
          }
     bool getMarginAllowanceForSystem(double lot,string _prefix,string _suffix,double &margin_required){
          bool allowed=false;
          margin_required=0.0;
          for(int si=0;si<ArraySize(sides);si++){
          for(int sy=0;sy<ArraySize(sides[si].symbols);sy++){
          margin_check check=CheckMarginRequired(_prefix+sides[si].symbols[sy].symbol.to_string()+_suffix,lot,sides[si].symbols[sy].direction);
          margin_required+=check.margin_required;
          }}
          if(margin_required<AccountFreeMargin()){allowed=true;}
          return(allowed);
          }
     bool getSessionAllowanceForSystem(datetime _time,string _prefix,string _suffix){
          bool allowed=true;
          for(int si=0;si<ArraySize(sides);si++){
          for(int sy=0;sy<ArraySize(sides[si].symbols);sy++){
          bool sy_allow=IsTradeAllowed(_prefix+sides[si].symbols[sy].symbol.to_string()+_suffix,_time);
          allowed=(allowed&&sy_allow);
          }}
          return(allowed);          
          }
     void getEquity(bool _swaps,bool _commisions){  
          equity=0.0;
          for(int si=0;si<ArraySize(sides);si++){
          equity+=sides[si].get_equity(_swaps,_commisions);
          }
          }
   double getEquityWithPrevious(bool _swaps,bool _commisions){
          double total=0.0;
          for(int si=0;si<ArraySize(sides);si++){
          total+=sides[si].get_equity_with_previous_too(_swaps,_commisions);
          }
          return(total);
          }
     void get_pole_equity(bool _swaps,bool _commisions){
          pole_equity=0.0;
          for(int si=0;si<ArraySize(sides);si++){
          if(sides[si].active){pole_equity+=sides[si].get_active_positive_equity(_swaps,_commisions);}
          }
          }

};
hat_system HAT;

//hat holder , no save to allow edits 



//VARIOUS
struct hm_timer
{
int hour,minute,in_minutes,in_seconds;
hm_timer(void){hour=0;minute=0;in_minutes=0;in_seconds=0;}
void set(string time_hh_mm){
ushort usep=StringGetCharacter(":",0);
string result[];
int k=StringSplit(time_hh_mm,usep,result);
if(k==1){hour=(int)StringToInteger(result[0]);minute=0;}
if(k>=2){hour=(int)StringToInteger(result[0]);minute=(int)StringToInteger(result[1]);}
in_minutes=minute+hour*60;
in_seconds=minute*60+hour*3600;
}
};
hm_timer BlockFrom,BlockTo;
bool CheckMarselTimeAllow()
{
bool result=true;
//time used is broker time 
  datetime fritime=TimeLocal();
  if(FridayTimeUsed==time_broker) fritime=TimeCurrent();
  int day=TimeDayOfWeek(fritime);
  if(day==5&&DontTradeFriday) result=false;
  if(day==6) result=false;
//if its friday and no trading is allowed on fridays 
//monday check
  if(MondayBegin)
  {
  datetime montime=TimeLocal();
  if(MondayTimeUsed==time_broker) montime=TimeCurrent();
  day=TimeDayOfWeek(montime);
  int hour=TimeHour(montime);
  //if day is sunday ,block
    if(day==0) result=false;
  //if day is monday ,and before our hour ,block
    if(day==1&&hour<MondayHour) result=false;
  }
//monday check ends here 
//if block time period is enabled(server time),and we about to send a valid time ,check again
if(TimeToIgnore&&result)
  {
  fritime=TimeCurrent();
  //turn it to linear minutes 
    int frimins=TimeHour(fritime)*60+TimeMinute(fritime);
  //check 
    //if the end is smaller than the start
      if(BlockTo.in_minutes<=BlockFrom.in_minutes)
      {
      if(frimins>=BlockFrom.in_minutes&&frimins<=24*60){result=false;}
      if(frimins>=0&&frimins<=BlockTo.in_minutes){result=false;}
      } 
    //if the end is bigger than the start 
      if(BlockTo.in_minutes>BlockFrom.in_minutes)
      {
      if(frimins>=BlockFrom.in_minutes&&frimins<=BlockTo.in_minutes){result=false;}
      }
  }
return(result);
}  

//check if a group can open based on spreads
  bool getSpreadAllowance(string _symbol,spread_mode _mode,double _max){
  if(_mode==m_spread_off){return(true);}//mode off - no checks
  else if(_mode==m_spread_points){//mode in points (old mode)
    if(_max>0){
    bool verdict=true;//true by default ,if any hurdles come up bounce immediately no need to check further
      //get tick size of asset
        double tick_size_of_this_asset=_Point;
      //get ask of asset
        double ask_of_asset=Ask;
      //get bid of asset
        double bid_of_asset=Bid;
      //spread calc 
        //if no errors proceed
          double spread=(ask_of_asset-bid_of_asset)/tick_size_of_this_asset;
          //to int 
            int theSpread=(int)spread;
            if(theSpread>=_max){verdict=false;}
      return(verdict);
    }
  //if spread is not zero - i.e. not off ends here   
  }
  //points mode ends here 
  else if(_mode==m_spread_percentage){//mode percentage (new)
    if(_max>0){
    bool verdict=true;//true by default ,if any hurdles come up bounce immediately no need to check further
      //get tick size of asset
        double tick_size_of_this_asset=_Point;
      //get ask of asset
        double ask_of_asset=Ask;
      //get bid of asset
        double bid_of_asset=Bid;        
      //size based on percentage 
        _max=(ask_of_asset/100.0)*_max;
      //spread calc 
          _max/=tick_size_of_this_asset;
          double spread=(ask_of_asset-bid_of_asset)/tick_size_of_this_asset;
          //to int 
            int theSpread=(int)spread;
            if(theSpread>=_max){verdict=false;}       
      return(verdict);
    }
  //if spread is not zero - i.e. not off ends here     
  }
  return(true);
  }
  
enum order_direction
{
dir_none=0,//None
dir_buy=1,//Buy
dir_sell=2//Sell
};
struct opener
{
bool opened;
double price;
ENUM_ORDER_TYPE direction;
int ticket;
double lots;
datetime time;
opener(void){opened=false;price=0;ticket=-1;lots=0;time=0;}
};
opener OpenOrder(string symbol,ENUM_ORDER_TYPE type,double lots,int magic,string comment,int attemps,uint timeout,int slippage,color col)
{
opener result;
int atts=0;
lots=CheckLot(symbol,lots);
int ticket=-1;
double op=0;
while(ticket==-1&&atts<=attemps)
 {
 atts++;
 if(type==OP_BUY)
   {
   int digs=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   op=(double)NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),digs);
   if(op>0&&digs>0)
     {
     ticket=OrderSend(symbol,OP_BUY,lots,op,slippage,0,0,comment,magic,0,col);
     if(ticket==-1&&atts<attemps){Sleep(timeout);}
     if(ticket!=-1)
       {
       result.opened=true;
       result.lots=lots;
       result.price=op;
       result.ticket=ticket;
       result.direction=OP_BUY;
       result.time=TimeCurrent();
       
       }
     }
   }
 if(type==OP_SELL)
   {
   int digs=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   op=(double)NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),digs);
   if(op>0&&digs>0)
     {
     ticket=OrderSend(symbol,OP_SELL,lots,op,slippage,0,0,comment,magic,0,col);
     if(ticket==-1&&atts<attemps){Sleep(timeout);}
     if(ticket!=-1)
       {
       result.opened=true;
       result.lots=lots;
       result.price=op;
       result.ticket=ticket;
       result.direction=OP_SELL;
       result.time=TimeCurrent();
       }
     }
   }   
 }
return(result);
}
//CHECK LOT 
double CheckLot(string symbol,double lot)
{
double returnio=lot;
double max_lot=MarketInfo(symbol,MODE_MAXLOT);
double min_lot=MarketInfo(symbol,MODE_MINLOT);
int lot_digits=LotDigits(min_lot);
returnio=NormalizeDouble(returnio,lot_digits);
if(returnio<=min_lot) returnio=min_lot;
if(returnio>=max_lot) returnio=max_lot;
returnio=NormalizeDouble(returnio,lot_digits);
return(returnio);
}
int LotDigits(double lot)
{
int returnio=0;
double digitos=0;
double transfer=lot;
while(transfer<1)
{
digitos++;
transfer=transfer*10;
} 
returnio=(int)digitos;
return(returnio);
}
  struct margin_check
  {
  bool can_open;
  double margin_required;
  margin_check(void){can_open=false;margin_required=0;}
  };
  margin_check CheckMarginRequired(string _symbol,double lot,ENUM_ORDER_TYPE direction){
  margin_check result;
  lot=CheckLot(_symbol,lot);
  result.margin_required=AccountFreeMargin()-AccountFreeMarginCheck(_symbol,direction,lot);
  if(result.margin_required<AccountFreeMargin()){result.can_open=true;}
  return(result);
  } 
int fifo_sort[][3];
bool CloseAll(bool setbusy,hat_system &system)
{
if(setbusy){system.busy=true;}
bool ClosedEverything=true;
//non fifo
if(IsFifo==false)
{
 for(int si=0;si<ArraySize(system.sides);si++){
 if(system.sides[si].active){
 for(int sy=0;sy<ArraySize(system.sides[si].symbols);sy++){
 if(system.sides[si].symbols[sy].operate){
 for(int t=0;t<ArraySize(system.sides[si].symbols[sy].tickets);t++){
  bool isClosed=CloseOrder(system.sides[si].symbols[sy].tickets[t],M_Attempts,M_Timeout,M_Slippage);
  if(!isClosed){ClosedEverything=false;} 
 }}}}}

}
//non fifo ends here
//fifo
if(IsFifo==true)
{
int TicketsTotal=0;
 for(int si=0;si<ArraySize(system.sides);si++){
 if(system.sides[si].active){
 for(int sy=0;sy<ArraySize(system.sides[si].symbols);sy++){
 if(system.sides[si].symbols[sy].operate){
 for(int t=0;t<ArraySize(system.sides[si].symbols[sy].tickets);t++){
 TicketsTotal+=ArraySize(system.sides[si].symbols[sy].tickets);
 }}}}}
//sort tickets
  if(TicketsTotal>ArraySize(fifo_sort))
  {
  ArrayResize(fifo_sort,TicketsTotal,0);
  }
  //pass them in 
   int sorts_total=0;
 for(int si=0;si<ArraySize(system.sides);si++){
 if(system.sides[si].active){
 for(int sy=0;sy<ArraySize(system.sides[si].symbols);sy++){
 if(system.sides[si].symbols[sy].operate){
     for(int t=0;t<ArraySize(system.sides[si].symbols[sy].tickets);t++)
       {
       bool select=OrderSelect(system.sides[si].symbols[sy].tickets[t],SELECT_BY_TICKET);
       if(select)
       {
       if(OrderCloseTime()==0)
         {
         sorts_total++;
         fifo_sort[sorts_total-1][0]=(int)(OrderOpenTime());//open time in seconds 
         fifo_sort[sorts_total-1][1]=t;//ix in tickets array 
         fifo_sort[sorts_total-1][2]=system.sides[si].symbols[sy].tickets[t];//ticket
         }
       }       
       }}}}}
   //if anything in the list 
   if(sorts_total>0)
   {
   ArraySort(fifo_sort,sorts_total,0,MODE_ASCEND);
   //ascend so , the earlier opened trades will go to the top of the stack
   //loop and close -
     for(int l=0;l<sorts_total;l++)
     {
      int ix=fifo_sort[l][1];
      bool isClosed=CloseOrder(fifo_sort[l][2],M_Attempts,M_Timeout,M_Slippage);
      if(!isClosed){ClosedEverything=false;}     
     }
   //loop and close - 
   }
   //if anything in the list ends here 
//sort tickets ends here 
}
//fifo ends here 
if(setbusy){system.busy=false;}
return(ClosedEverything);
}
bool ClosePole(bool setbusy,hat_system &system)
{
if(setbusy){system.busy=true;}
bool ClosedEverything=true;
//non fifo
if(IsFifo==false)
{
 for(int si=0;si<ArraySize(system.sides);si++){
 if(system.sides[si].active){
 for(int sy=0;sy<ArraySize(system.sides[si].symbols);sy++){
 bool symbol_closed=false;
 if(system.sides[si].symbols[sy].operate&&system.sides[si].symbols[sy].equity>0.0){
 symbol_closed=true;
 for(int t=0;t<ArraySize(system.sides[si].symbols[sy].tickets);t++){
  bool isClosed=CloseOrder(system.sides[si].symbols[sy].tickets[t],M_Attempts,M_Timeout,M_Slippage);
  if(!isClosed){ClosedEverything=false;symbol_closed=false;} 
 }
 if(symbol_closed){system.sides[si].symbols[sy].operate=false;}
 }}}}

}
//non fifo ends here
//fifo
if(IsFifo==true)
{
int TicketsTotal=0;
 for(int si=0;si<ArraySize(system.sides);si++){
 if(system.sides[si].active){
 for(int sy=0;sy<ArraySize(system.sides[si].symbols);sy++){
 if(system.sides[si].symbols[sy].operate&&system.sides[si].symbols[sy].equity>0.0){
 for(int t=0;t<ArraySize(system.sides[si].symbols[sy].tickets);t++){
 TicketsTotal+=ArraySize(system.sides[si].symbols[sy].tickets);
 }}}}}
//sort tickets
  if(TicketsTotal>ArraySize(fifo_sort))
  {
  ArrayResize(fifo_sort,TicketsTotal,0);
  }
  //pass them in 
   int sorts_total=0;
 for(int si=0;si<ArraySize(system.sides);si++){
 if(system.sides[si].active){
 for(int sy=0;sy<ArraySize(system.sides[si].symbols);sy++){
 if(system.sides[si].symbols[sy].operate&&system.sides[si].symbols[sy].equity>0.0){
     for(int t=0;t<ArraySize(system.sides[si].symbols[sy].tickets);t++)
       {
       bool select=OrderSelect(system.sides[si].symbols[sy].tickets[t],SELECT_BY_TICKET);
       if(select)
       {
       if(OrderCloseTime()==0)
         {
         sorts_total++;
         fifo_sort[sorts_total-1][0]=(int)(OrderOpenTime());//open time in seconds 
         fifo_sort[sorts_total-1][1]=t;//ix in tickets array 
         fifo_sort[sorts_total-1][2]=system.sides[si].symbols[sy].tickets[t];//ticket
         }
       }       
       }
       system.sides[si].symbols[sy].operate=false;
       }}}}
   //if anything in the list 
   if(sorts_total>0)
   {
   ArraySort(fifo_sort,sorts_total,0,MODE_ASCEND);
   //ascend so , the earlier opened trades will go to the top of the stack
   //loop and close -
     for(int l=0;l<sorts_total;l++)
     {
      int ix=fifo_sort[l][1];
      bool isClosed=CloseOrder(fifo_sort[l][2],M_Attempts,M_Timeout,M_Slippage);
      if(!isClosed){ClosedEverything=false;}     
     }
   //loop and close - 
   }
   //if anything in the list ends here 
//sort tickets ends here 
}
//fifo ends here 
if(setbusy){system.busy=false;}
return(ClosedEverything);
}
bool CloseSide(a_side &the_side){
bool ClosedEverything=true;
//non fifo
if(IsFifo==false)
{
 if(the_side.active){
 for(int sy=0;sy<ArraySize(the_side.symbols);sy++){
 if(the_side.symbols[sy].operate){
 for(int t=0;t<ArraySize(the_side.symbols[sy].tickets);t++){
  bool isClosed=CloseOrder(the_side.symbols[sy].tickets[t],M_Attempts,M_Timeout,M_Slippage);
  if(!isClosed){ClosedEverything=false;} 
 }}}}

}
//non fifo ends here
//fifo
if(IsFifo==true)
{
int TicketsTotal=0;

 if(the_side.active){
 for(int sy=0;sy<ArraySize(the_side.symbols);sy++){
 if(the_side.symbols[sy].operate){
 for(int t=0;t<ArraySize(the_side.symbols[sy].tickets);t++){
 TicketsTotal+=ArraySize(the_side.symbols[sy].tickets);
 }}}}
//sort tickets
  if(TicketsTotal>ArraySize(fifo_sort))
  {
  ArrayResize(fifo_sort,TicketsTotal,0);
  }
  //pass them in 
   int sorts_total=0;
 if(the_side.active){
 for(int sy=0;sy<ArraySize(the_side.symbols);sy++){
 if(the_side.symbols[sy].operate){
     for(int t=0;t<ArraySize(the_side.symbols[sy].tickets);t++)
       {
       bool select=OrderSelect(the_side.symbols[sy].tickets[t],SELECT_BY_TICKET);
       if(select)
       {
       if(OrderCloseTime()==0)
         {
         sorts_total++;
         fifo_sort[sorts_total-1][0]=(int)(OrderOpenTime());//open time in seconds 
         fifo_sort[sorts_total-1][1]=t;//ix in tickets array 
         fifo_sort[sorts_total-1][2]=the_side.symbols[sy].tickets[t];//ticket
         }
       }       
       }}}}
   //if anything in the list 
   if(sorts_total>0)
   {
   ArraySort(fifo_sort,sorts_total,0,MODE_ASCEND);
   //ascend so , the earlier opened trades will go to the top of the stack
   //loop and close -
     for(int l=0;l<sorts_total;l++)
     {
      int ix=fifo_sort[l][1];
      bool isClosed=CloseOrder(fifo_sort[l][2],M_Attempts,M_Timeout,M_Slippage);
      if(!isClosed){ClosedEverything=false;}     
     }
   //loop and close - 
   }
   //if anything in the list ends here 
//sort tickets ends here 
}
//fifo ends here 
return(ClosedEverything);
}
bool CloseOrder(int ticket,int attempts,uint timeout,int slippage)
{
bool result=false;
int atts=0;
double cp=0;
while(!result&&atts<=attempts)
{
atts++;
bool select=OrderSelect(ticket,SELECT_BY_TICKET);
if(select)
  {
  ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderType();
  string symbol=OrderSymbol();
  double lots=OrderLots();
  if(OrderCloseTime()!=0) return(true);
  //buys
    if(type==OP_BUY&&OrderCloseTime()==0)
    {
    int digs=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
    cp=(double)NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),digs);
    if(cp>0&&digs>0)
      {
      result=OrderClose(ticket,lots,cp,slippage,clrBlue);
      if(!result&&atts<attempts) Sleep(timeout);
      if(result) return(true);
      }
    }
  //sells 
    if(type==OP_SELL&&OrderCloseTime()==0)
    {
    int digs=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
    cp=(double)NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),digs);
    if(cp>0&&digs>0)
      {
      result=OrderClose(ticket,lots,cp,slippage,clrBlue);
      if(!result&&atts<attempts) Sleep(timeout);
      if(result) return(true);
      }
    }  
  }
}
return(result);
}
//DISPLAY FUNCTIONS 
objects_group OG;
//+------------------------------------------------------------------+
//BUILD DECK
void BuildDeck(objects_group &og,
               string system_tag,
               int posx,
               int posy,
               int size_x,
               int row_height,
               hat_system &sys)
{
double unit_x=((double)size_x)/100.0;
int px=posx;
int py=posy;
int poffx=size_x/60;
int btn_size=row_height-row_height/5;
int btn_offset_y=(row_height-btn_size)/2;
int poffy=row_height/20;
ArrayFree(og.Objects);
/*
rows :
1-title
2-system magic
3-system stage
4-groups ...
...
last -total equity of system
*/
int rows=9;
if(DualHedge){rows++;}
for(int si=0;si<ArraySize(sys.sides);si++){
rows+=ArraySize(sys.sides[si].symbols)+4;
}
//design resources 
int deck_sx=0,deck_sy=0,logo_sx=0,logo_sy=0,icons_sx[],icons_sy[],close_sx=0,close_sy=0;
DesignDeck(rows,deck_sx,deck_sy,logo_sx,logo_sy,icons_sx,icons_sy,close_sx,close_sy);
string objna="";

  //background
  objna=system_tag+"_Background";
  //HS_Create_Btn(ChartID(),0,objna,size_x,row_height*rows,px,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"",false,false);
  HS_Create_Bmp(ChartID(),0,objna,deck_sx,deck_sy,px,py,"::GUI_BACKGROUND",false,false);
  og.AddObject(objna,"","",obj_bitmap,0,0,true,false,NULL);
  //logo
  objna=system_tag+"_Logo";
  HS_Create_Bmp(ChartID(),0,objna,logo_sx,logo_sy,px+GUI_Logo_Px,py+GUI_Logo_Py,"::GUI_LOGO",false,false);
  og.AddObject(objna,"","",obj_bitmap,GUI_Logo_Px,GUI_Logo_Py,true,false,NULL);
  //quit btn
  int btn_x=GUI_DeckWidth-icons_sx[GUI_IX_POWER];
  objna=system_tag+"_Quit";
  HS_Create_Bmp(ChartID(),0,objna,icons_sx[GUI_IX_POWER],icons_sy[GUI_IX_POWER],px+btn_x,py,"::GUI_POWER_NORMAL",false,false);
  og.AddObject(objna,"","",obj_bitmap,GUI_DeckWidth-icons_sx[GUI_IX_POWER],0,true,true,"EXIT");
  ELEMENTLIST.add(objna,"::GUI_POWER_NORMAL","::GUI_POWER_HOVER",false,px+btn_x,py,px+btn_x+icons_sx[GUI_IX_POWER],py+icons_sy[GUI_IX_POWER]);
  btn_x-=icons_sx[GUI_IX_POWER];
  //website
  objna=system_tag+"_Website";
  HS_Create_Bmp(ChartID(),0,objna,icons_sx[GUI_IX_WEBSITE],icons_sy[GUI_IX_WEBSITE],px+btn_x,py,"::GUI_WEBSITE_NORMAL",false,false);
  og.AddObject(objna,"","",obj_bitmap,btn_x,0,true,true,"WEBSITE");
  ELEMENTLIST.add(objna,"::GUI_WEBSITE_NORMAL","::GUI_WEBSITE_HOVER",false,px+btn_x,py,px+btn_x+icons_sx[GUI_IX_WEBSITE],py+icons_sy[GUI_IX_WEBSITE]);
  btn_x-=icons_sx[GUI_IX_WEBSITE];
  //telegram
  objna=system_tag+"_Telegram";
  HS_Create_Bmp(ChartID(),0,objna,icons_sx[GUI_IX_TELEGRAM],icons_sy[GUI_IX_TELEGRAM],px+btn_x,py,"::GUI_TELEGRAM_NORMAL",false,false);
  og.AddObject(objna,"","",obj_bitmap,btn_x,0,true,true,"TELEGRAM");
  ELEMENTLIST.add(objna,"::GUI_TELEGRAM_NORMAL","::GUI_TELEGRAM_HOVER",false,px+btn_x,py,px+btn_x+icons_sx[GUI_IX_TELEGRAM],py+icons_sy[GUI_IX_TELEGRAM]);
  btn_x-=icons_sx[GUI_IX_TELEGRAM];  
  //facebook
  objna=system_tag+"_Facebook";
  HS_Create_Bmp(ChartID(),0,objna,icons_sx[GUI_IX_FACEBOOK],icons_sy[GUI_IX_FACEBOOK],px+btn_x,py,"::GUI_FACEBOOK_NORMAL",false,false);
  og.AddObject(objna,"","",obj_bitmap,btn_x,0,true,true,"FACEBOOK");
  ELEMENTLIST.add(objna,"::GUI_FACEBOOK_NORMAL","::GUI_FACEBOOK_HOVER",false,px+btn_x,py,px+btn_x+icons_sx[GUI_IX_FACEBOOK],py+icons_sy[GUI_IX_FACEBOOK]);
  btn_x-=icons_sx[GUI_IX_FACEBOOK];    
  //instagram
  objna=system_tag+"_Instagram";
  HS_Create_Bmp(ChartID(),0,objna,icons_sx[GUI_IX_INSTAGRAM],icons_sy[GUI_IX_INSTAGRAM],px+btn_x,py,"::GUI_INSTAGRAM_NORMAL",false,false);
  og.AddObject(objna,"","",obj_bitmap,btn_x,0,true,true,"INSTAGRAM");
  ELEMENTLIST.add(objna,"::GUI_INSTAGRAM_NORMAL","::GUI_INSTAGRAM_HOVER",false,px+btn_x,py,px+btn_x+icons_sx[GUI_IX_INSTAGRAM],py+icons_sy[GUI_IX_INSTAGRAM]);
  btn_x-=icons_sx[GUI_IX_INSTAGRAM];   
  //discord
  objna=system_tag+"_Discord";
  HS_Create_Bmp(ChartID(),0,objna,icons_sx[GUI_IX_DISCORD],icons_sy[GUI_IX_DISCORD],px+btn_x,py,"::GUI_DISCORD_NORMAL",false,false);
  og.AddObject(objna,"","",obj_bitmap,btn_x,0,true,true,"DISCORD");
  ELEMENTLIST.add(objna,"::GUI_DISCORD_NORMAL","::GUI_DISCORD_HOVER",false,px+btn_x,py,px+btn_x+icons_sx[GUI_IX_DISCORD],py+icons_sy[GUI_IX_DISCORD]);
  btn_x-=icons_sx[GUI_IX_DISCORD];  
  //forex factory
  objna=system_tag+"_ForexFactory";
  HS_Create_Bmp(ChartID(),0,objna,icons_sx[GUI_IX_FOREX_FACTORY],icons_sy[GUI_IX_FOREX_FACTORY],px+btn_x,py,"::GUI_FOREX_FACTORY_NORMAL",false,false);
  og.AddObject(objna,"","",obj_bitmap,btn_x,0,true,true,"FOREX_FACTORY");
  ELEMENTLIST.add(objna,"::GUI_FOREX_FACTORY_NORMAL","::GUI_FOREX_FACTORY_HOVER",false,px+btn_x,py,px+btn_x+icons_sx[GUI_IX_FOREX_FACTORY],py+icons_sy[GUI_IX_FOREX_FACTORY]);
  btn_x-=icons_sx[GUI_IX_FOREX_FACTORY];       
  int rowCo=0;
  py=posy+GUI_Header_Height;
  int hafrow=GUI_RowHeight/2;
  //magic number back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_MN_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);
  //magic number 
    objna=system_tag+"_System_MN";
    HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
    og.AddObject(objna,"SystemMagicNumber","",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
    py+=row_height;
  //active group back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_AG_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);
  //active group 
    objna=system_tag+"_System_AG";
    HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
    og.AddObject(objna,"ActiveGroup","",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
    py+=row_height;
  //system stage back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Stage_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);    
  //system stage 
      objna=system_tag+"_System_Stage";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,"SystemStage","Stage : ",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;    
  //sides 
    for(int si=0;si<ArraySize(sys.sides);si++){
  //tutle back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Side_"+IntegerToString(si)+"_Title_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);     
    //title 
    objna=system_tag+"_SIDE_"+sys.sides[si].name.to_string();
    HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
    og.AddObject(objna,sys.sides[si].name.to_string()+"TITLE","",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
    py+=row_height;      
    //symbols
      for(int sy=0;sy<ArraySize(sys.sides[si].symbols);sy++)
      {
      //symbols back
      rowCo++;if(rowCo>2){rowCo=1;}
      objna=system_tag+"_Side_"+IntegerToString(si)+"_Symbols"+IntegerToString(sy)+"_Row";
      HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
      og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);        
      //symbols text
      objna=system_tag+"_SIDE_"+sys.sides[si].name.to_string()+"_"+IntegerToString(sy);
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,sys.sides[si].name.to_string()+"SYMBOL"+IntegerToString(sy),"",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;        
      }
  //equity back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Side_"+IntegerToString(si)+"_Equity_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);        
    //equity
      objna=system_tag+"_SIDE_"+sys.sides[si].name.to_string()+"_EQUITY";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,sys.sides[si].name.to_string()+"EQUITY","Equity : ",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;  
      
  //trailed back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Side_"+IntegerToString(si)+"_Trailed_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);  
    //trailed
      objna=system_tag+"_SIDE_"+sys.sides[si].name.to_string()+"_TRAILED";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,sys.sides[si].name.to_string()+"TRIAL","Trail : ",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;        
  //separator back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Side_"+IntegerToString(si)+"_sep_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);  
    //separator
      objna=system_tag+"_SIDE_"+sys.sides[si].name.to_string()+"_SEP";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,"","-----",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;      
    }
  //overall equity back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Overall_Equity_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);      
  //overall equity 
      objna=system_tag+"_OVERALL_EQUITY";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,"SystemEquity","SysEquity : ",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;  
  //pole equity back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Pole_Equity_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);      
  //pole equity 
      objna=system_tag+"_POLE_EQUITY";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,"PoleEquity","Positive Orders Live Equity : ",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;   
  //pole trail back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_Pole_Trail_Row";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);      
  //pole trail
      objna=system_tag+"_POLE_TRAIL";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,"PoleTrail","POLE Trail : ",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;      
    if(DualHedge){   
  //previous equity back
    rowCo++;if(rowCo>2){rowCo=1;}
    objna=system_tag+"_PrevEquityRow";
    HS_Create_Bmp(ChartID(),0,objna,GUI_DeckWidth,GUI_RowHeight,px,py,"::GUI_ROW"+IntegerToString(rowCo),false,false);
    og.AddObject(objna,"","",obj_bitmap,0,py+poffy-posy,true,false,NULL);      
  //pole trail
      objna=system_tag+"_PREV_EQUITY";
      HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy+hafrow,"Arial",i_font_size,CLR_Text,ANCHOR_LEFT,IntegerToString(MagicNumber),false,false);
      og.AddObject(objna,"PrevTrailEquity","PREV.TRAILED.EQ : ",obj_label,px+poffx-posx,py+poffy-posy+hafrow,true,false,NULL);
      py+=row_height;
   }            
  //button for close all (if on and invisible at first)
    if(ExitAllButton)
    {
    objna=system_tag+"_ExitAll";
    int btnpx=px+(GUI_DeckWidth-close_sx)/2;
    py+=row_height/2;
    HS_Create_Bmp(ChartID(),0,objna,close_sx,close_sy,btnpx,py,"::GUI_CLOSE_NORMAL",false,false);
    og.AddObject(objna,"CloseAll","",obj_bitmap,btnpx-posx,py-posy,true,true,"EXITALLMN");
    ELEMENTLIST.add(objna,"::GUI_CLOSE_NORMAL","::GUI_CLOSE_HOVER",false,btnpx,py,btnpx+close_sx,py+close_sy);

    py+=row_height;
    /*
    HS_Create_Btn(ChartID(),0,objna,size_x,row_height,px,py,"Arial",i_font_size,clrCrimson,clrDarkRed,BORDER_FLAT,clrOrange,ALIGN_CENTER,"Close All With MN ",false,false);
    og.AddObject(objna,"CloseAll","Close All",obj_button,px-posx,py-posy,true,true,"EXITALLMN");
    py+=row_height;
    */
    }  
og.Relocate(posx,posy,true);
DECKED=true;
UpdateDeck(sys);
} 
//+------------------------------------------------------------------+

void UpdateDeck(hat_system &sys)
{
if(DECKED){
OG>"SystemMagicNumber">IntegerToString(MagicNumber);
OG>"ActiveGroup">"Active Group "+IntegerToString(sys.active_hat);
OG>"SystemStage">stage_texts[(int)sys.stage]+" "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
if(POLE_Trailing&&sys.first_poled&&POLE_Activate_Limit&&sys.stage==hat_stage_hedge){
OG>"SystemStage">"Both Recover(pole)";
}
if(DualHedge&&!POLE_Trailing&&sys.getHedgesCount()>=1){
OG>"PrevTrailEquity">DoubleToString(sys.getOnlyPrevious(),2)+AccountCurrency();
}else if(sys.getHedgesCount()<1&&DualHedge&&!POLE_Trailing){
OG>"PrevTrailEquity">"..";
}
for(int si=0;si<ArraySize(sys.sides);si++)
 {
 string activity="ACTIVE";
 if(!sys.sides[si].active){activity="INACTIVE";}
 string addit="";
 if(DualHedge&&!POLE_Trailing){addit=" Hedge#"+IntegerToString(sys.sides[si].hedged_time);}
 OG>sys.sides[si].name.to_string()+"TITLE">sys.sides[si].name.to_string()+" "+addit+","+activity;
 for(int sy=0;sy<ArraySize(sys.sides[si].symbols);sy++)
   {
  
   //if active
     if(sys.sides[si].active){
     string direct="BUY";
     if(sys.sides[si].symbols[sy].direction==OP_SELL){direct="SELL";}
     string sum=sys.sides[si].symbols[sy].symbol.to_string()+"["+direct+"][L:"+DoubleToString(MathMin(sys.sides[si].symbols[sy].total_lots,sys.sides[si].symbols[sy].last_lot),2)+"][#"+IntegerToString(ArraySize(sys.sides[si].symbols[sy].tickets))+"][>$:"+DoubleToString(sys.sides[si].symbols[sy].equity_of_last,2)+"/"+DoubleToString(sys.sides[si].symbols[sy].next_recovery_equity,2)+"][all:"+DoubleToString(sys.sides[si].symbols[sy].equity,2)+"]";
     OG>sys.sides[si].name.to_string()+"SYMBOL"+IntegerToString(sy)>sum;
     string objna=SystemTag+"_SIDE_"+sys.sides[si].name.to_string()+"_"+IntegerToString(sy);
     if(sys.sides[si].symbols[sy].operate){
     ObjectSetInteger(ChartID(),objna,OBJPROP_COLOR,clrGainsboro);
     }else{
     ObjectSetInteger(ChartID(),objna,OBJPROP_COLOR,clrCrimson);
     }
     }
   //if inactive
     else{
     OG>sys.sides[si].name.to_string()+"SYMBOL"+IntegerToString(sy)>"...";
     }
   }
    //equity
      OG>sys.sides[si].name.to_string()+"EQUITY">DoubleToString(sys.sides[si].equity,2);
    //trailed
      string trailtext="Nope";
      if(sys.sides[si].is_trailed&&sys.sides[si].active){
      trailtext="Yes -> "+DoubleToString(sys.sides[si].equity_sl,2);      
      }
      OG>sys.sides[si].name.to_string()+"TRIAL">trailtext;
 }
OG>"SystemEquity">DoubleToString(sys.equity,2);
if(!POLE_Trailing){
OG>"PoleEquity">"off";
OG>"PoleTrail">"off";
}else{
OG>"PoleEquity">DoubleToString(sys.pole_equity,2);
if(sys.pole_trailed){
OG>"PoleTrail">DoubleToString(sys.pole_trail_stop,2);
}else{
OG>"PoleTrail">"---";
}
}
ChartRedraw(0);
}//
}

//interactive elements 
  struct i_element{
  string object,normal_bmp,hover_bmp;
  bool   state;
  int    from_x,to_x,from_y,to_y;
         i_element(void){reset();}
        ~i_element(void){reset();}
    void reset(){
         object=NULL;
         normal_bmp=NULL;
         hover_bmp=NULL;
         state=false;
         from_x=-1;to_x=-1;from_y=-1;to_y=-1;
         }
    void set(string _object,string _normal_bmp,string _hover_bmp,bool _state,int _sx,int _sy,int _ex,int _ey){
         object=_object;
         normal_bmp=_normal_bmp;
         hover_bmp=_hover_bmp;
         state=_state;
         from_x=_sx;
         to_x=_ex;
         from_y=_sy;
         to_y=_ey;
         
         }
    void check(int mx,int my){ 
         bool new_state=false;//true means hover
         if(mx>=from_x&&mx<=to_x&&my>=from_y&&my<=to_y){new_state=true;}
         if(new_state!=state){
         state=new_state;
         display();
         }}
    void display(){
         if(state){ObjectSetString(ChartID(),object,OBJPROP_BMPFILE,hover_bmp);}
         else{ObjectSetString(ChartID(),object,OBJPROP_BMPFILE,normal_bmp);}
         }
  };
struct elements{
i_element e[];
       elements(void){reset();}
      ~elements(void){reset();}
   void reset(){ArrayFree(e);}
   void check(int mx,int my){
        for(int i=0;i<ArraySize(e);i++){e[i].check(mx,my);}
        }
    int add(string _object,string _normal_bmp,string _hover_bmp,bool _state,int _sx,int _sy,int _ex,int _ey){
        int ns=ArraySize(e)+1;
        ArrayResize(e,ns,0);
        e[ns-1].set(_object,_normal_bmp,_hover_bmp,_state,_sx,_sy,_ex,_ey);
        return(ns-1);
        }
};
elements ELEMENTLIST;
void DesignDeck(int rows,int &deck_sx,int &deck_sy,int &_logo_sx,int &_logo_sy,int &_icons_sx[],int &_icons_sy[],int &_close_sx,int &_close_sy){
int dx=GUI_DeckWidth;
int dy=GUI_Header_Height+GUI_RowHeight*rows;
deck_sx=dx;
deck_sy=dy;
     //design background 
     uint pixels[];
     ArrayResize(pixels,dx*dy,0);
     RCTN_GradientsReset();
     RCTN_LinersReset();
     if(GUI_Background_Grade){
       RCTN_GradientsAdd(GUI_Background_Gradient_Type,GUI_Background_Color_1,GUI_Background_Color_2,GUI_Background_Opacity_1,GUI_Background_Opacity_2,GUI_Background_Gradient_Angle,50.0,50.0,true,true,true,true);
       }
     else{
     ArrayFill(pixels,0,ArraySize(pixels),ColorToARGB(GUI_Background_Color_1,GUI_Background_Opacity_1));
     }
     if(GUI_Background_Liners)
     {
     RCTN_LinersAdd(GUI_Background_Liners_Type,GUI_Background_Liners_Color,GUI_Background_Liners_Opacity,GUI_Background_Liners_Angle,0.0,0.0,GUI_Background_Liners_Gap,GUI_Background_Liners_Width,false,true,true,true);
     }
   
     if(GUI_Background_Grade){test_draw_gradient_from_settings(pixels,dx,dy);}
     if(GUI_Background_Liners){test_draw_liners(pixels,dx,dy);}
     if(GUI_Background_Noise){
     RCTN_Noise_Applicator(pixels,dx,dy,GUI_Noise_Range_Min,GUI_Noise_Range_Max,true,false,true,true,true);
     }
   
     string rezName="GUI_BACKGROUND";
     bool created=ResourceCreate(rezName,pixels,dx,dy,0,0,dx,COLOR_FORMAT_ARGB_NORMALIZE);
     if(created){add_to_string_array(myResources,rezName);}
     ArrayFree(pixels);
     //Prep logo and social media icons 
       //utilization max 
         int max_logo_sx=(int)(((double)GUI_DeckWidth)*80);
         //find new size based on aspect ratio and the height provided 
         uint logo_pixels[],logo_original_sx=0,logo_original_sy=0;
         bool grab_logo=ResourceReadImage(GUI_LOGO,logo_pixels,logo_original_sx,logo_original_sy);
         if(grab_logo){
         double logo_ratio=((double)logo_original_sx)/((double)logo_original_sy);
         int logo_sy=GUI_Logo_Height;
         int logo_sx=(int)(((double)logo_sy)*logo_ratio);
         if(logo_sx>max_logo_sx){logo_sx=max_logo_sx;logo_sy=(int)(((double)logo_sx)/logo_ratio);}
         _logo_sx=logo_sx;_logo_sy=logo_sy;
         //we have the new size here , hit it 
           //create logo style first 
             uint logradient_pixels[];
             resize_and_rearray(logo_pixels,logo_original_sx,logo_original_sy,logo_sx,logo_sy,pixels);
             ArrayResize(logradient_pixels,logo_sx*logo_sy,0);
             RCTN_GradientsReset();RCTN_LinersReset();
             if(GUI_Logo_Gradient){
             RCTN_GradientsAdd(GUI_Logo_Gradient_Type,GUI_Logo_Color_1,GUI_Logo_Color_2,GUI_Logo_Opacity_1,GUI_Logo_Opacity_2,GUI_Logo_Gradient_Angle,50.0,50.0,true,true,true,true);
             }
             if(GUI_Logo_Liners){
             RCTN_LinersAdd(GUI_Logo_Liner_Type,GUI_Logo_Liner_Color,GUI_Logo_Liner_Opacity,GUI_Logo_Liner_Angle,0,0,GUI_Logo_Liner_Gap,GUI_Logo_Liner_Width,true,true,true,true);
             }
             if(GUI_Logo_Gradient){
             test_draw_gradient_from_settings(logradient_pixels,logo_sx,logo_sy);
             }else{ArrayFill(logradient_pixels,0,ArraySize(logradient_pixels),ColorToARGB(GUI_Logo_Color_1,GUI_Logo_Opacity_1));}
             if(GUI_Logo_Liners){
             test_draw_liners(logradient_pixels,logo_sx,logo_sy);
             }
             if(GUI_Logo_Noise){
             RCTN_Noise_Applicator(logradient_pixels,logo_sx,logo_sy,GUI_Logo_Noise_Min,GUI_Logo_Noise_Max,true,false,true,true,true);
             }
             //so we take the RESIZED logo and paint it with the RESIZED style
             grab_mask_and_style(pixels,logo_sx,logo_sy,logo_pixels,clrBlack,false,logo_sx,logo_sy,logradient_pixels,logo_sx,logo_sy);
             //aand we create a resource finally 
               rezName="GUI_LOGO";
               created=ResourceCreate(rezName,logo_pixels,logo_sx,logo_sy,0,0,logo_sx,COLOR_FORMAT_ARGB_NORMALIZE);
               if(created){
               add_to_string_array(myResources,rezName);
               //icons 
                 //create icons list 
                   string icons[]={GUI_ICON_DISCORD,GUI_ICON_FACEBOOK,GUI_ICON_FOREX_FACTORY,GUI_ICON_INSTAGRAM,GUI_ICON_POWER,GUI_ICON_TELEGRAM,GUI_ICON_WEBSITE};
                   string resnames[]={"GUI_DISCORD","GUI_FACEBOOK","GUI_FOREX_FACTORY","GUI_INSTAGRAM","GUI_POWER","GUI_TELEGRAM","GUI_WEBSITE"};
                   int icons_sx[],icons_sy[];
                   ArrayResize(icons_sx,ArraySize(icons),0);
                   ArrayResize(icons_sy,ArraySize(icons),0);
                   //loop and color , normal style first 
                     ArrayFree(logradient_pixels);
                     int icon_maxx=(int)(((double)GUI_Icons_Height)*1.2);
                     int icon_maxy=(int)(((double)GUI_Icons_Height)*1.2);
                     ArrayResize(logradient_pixels,icon_maxx*icon_maxy,0);
                     RCTN_GradientsReset();RCTN_LinersReset();
                     if(GUI_IconsNormal_Gradient){
                     RCTN_GradientsAdd(GUI_IconsNormal_Gradient_Type,GUI_IconsNormal_Color_1,GUI_IconsNormal_Color_2,GUI_IconsNormal_Opacity_1,GUI_IconsNormal_Opacity_2,GUI_IconsNormal_Gradient_Angle,50.0,50.0,true,true,true,true);
                     }
                     if(GUI_IconsNormal_Liners){
                     RCTN_LinersAdd(GUI_IconsNormal_Liner_Type,GUI_IconsNormal_Liner_Color,GUI_IconsNormal_Liner_Opacity,GUI_IconsNormal_Liner_Angle,0,0,GUI_IconsNormal_Liner_Gap,GUI_IconsNormal_Liner_Width,true,true,true,true);
                     }
                     if(GUI_IconsNormal_Gradient){
                     test_draw_gradient_from_settings(logradient_pixels,icon_maxx,icon_maxy);
                     }else{ArrayFill(logradient_pixels,0,ArraySize(logradient_pixels),ColorToARGB(GUI_IconsNormal_Color_1,GUI_IconsNormal_Opacity_1));}
                     if(GUI_IconsNormal_Liners){
                     test_draw_liners(logradient_pixels,icon_maxx,icon_maxy);
                     }
                     if(GUI_IconsNormal_Noise){
                     RCTN_Noise_Applicator(logradient_pixels,icon_maxy,icon_maxy,GUI_IconsNormal_Noise_Min,GUI_IconsNormal_Noise_Max,true,false,true,true,true);
                     }                     
                     //loop and style  
                       uint tempixels[];
                       int temp_x=0,temp_y=0;
                       for(int i=0;i<ArraySize(icons);i++)
                       {
                       ArrayResize(tempixels,ArraySize(logradient_pixels),0);
                       ArrayCopy(tempixels,logradient_pixels,0,0,ArraySize(logradient_pixels));
                       temp_x=icon_maxx;
                       temp_y=icon_maxy;
                       int icn_x=0,icn_y=GUI_Icons_Height;
                       //grab 
                         grab_mask_and_style_set_height_only(icons[i],pixels,clrBlack,true,icn_x,icn_y,tempixels,temp_x,temp_y);
                       //resource 
                         rezName=resnames[i]+"_NORMAL";
                         created=ResourceCreate(rezName,pixels,icn_x,icn_y,0,0,icn_x,COLOR_FORMAT_ARGB_NORMALIZE);
                         add_to_string_array(myResources,rezName);
                       icons_sx[i]=icn_x;
                       icons_sy[i]=icn_y;
                       }
                       //export icons sizes 
                         ArrayResize(_icons_sx,ArraySize(icons_sx),0);
                         ArrayResize(_icons_sy,ArraySize(icons_sy),0);
                         ArrayCopy(_icons_sx,icons_sx,0,0,ArraySize(icons_sx));
                         ArrayCopy(_icons_sy,icons_sy,0,0,ArraySize(icons_sy));
                     //HOVER STYLE
                     ArrayResize(logradient_pixels,icon_maxx*icon_maxy,0);
                     RCTN_GradientsReset();RCTN_LinersReset();
                     if(GUI_IconsHover_Gradient){
                     RCTN_GradientsAdd(GUI_IconsHover_Gradient_Type,GUI_IconsHover_Color_1,GUI_IconsHover_Color_2,GUI_IconsHover_Opacity_1,GUI_IconsHover_Opacity_2,GUI_IconsHover_Gradient_Angle,50.0,50.0,true,true,true,true);
                     }
                     if(GUI_IconsHover_Liners){
                     RCTN_LinersAdd(GUI_IconsHover_Liner_Type,GUI_IconsHover_Liner_Color,GUI_IconsHover_Liner_Opacity,GUI_IconsHover_Liner_Angle,0,0,GUI_IconsHover_Liner_Gap,GUI_IconsHover_Liner_Width,true,true,true,true);
                     }
                     if(GUI_IconsHover_Gradient){
                     test_draw_gradient_from_settings(logradient_pixels,icon_maxx,icon_maxy);
                     }else{ArrayFill(logradient_pixels,0,ArraySize(logradient_pixels),ColorToARGB(GUI_IconsHover_Color_1,GUI_IconsHover_Opacity_1));}
                     if(GUI_IconsHover_Liners){
                     test_draw_liners(logradient_pixels,icon_maxx,icon_maxy);
                     }
                     if(GUI_IconsHover_Noise){
                     RCTN_Noise_Applicator(logradient_pixels,icon_maxy,icon_maxy,GUI_IconsHover_Noise_Min,GUI_IconsHover_Noise_Max,true,false,true,true,true);
                     }                     
                     //loop and style  
                       for(int i=0;i<ArraySize(icons);i++)
                       {
                       ArrayResize(tempixels,ArraySize(logradient_pixels),0);
                       ArrayCopy(tempixels,logradient_pixels,0,0,ArraySize(logradient_pixels));
                       temp_x=icon_maxx;
                       temp_y=icon_maxy;
                       int icn_x=0,icn_y=GUI_Icons_Height;
                       //grab 
                         grab_mask_and_style_set_height_only(icons[i],pixels,clrBlack,true,icn_x,icn_y,tempixels,temp_x,temp_y);
                       //resource 
                         rezName=resnames[i]+"_HOVER";
                         created=ResourceCreate(rezName,pixels,icn_x,icn_y,0,0,icn_x,COLOR_FORMAT_ARGB_NORMALIZE);
                         add_to_string_array(myResources,rezName);
                       }                       
               //icons 
               //row A
                 dx=GUI_DeckWidth;
                 dy=GUI_RowHeight;
                 ArrayResize(pixels,dx*dy,0);
                 RCTN_GradientsReset();
                 RCTN_LinersReset();
                 if(GUI_RowA_Gradient){
                 RCTN_GradientsAdd(GUI_RowA_Gradient_Type,GUI_RowA_Color_1,GUI_RowA_Color_2,GUI_RowA_Opacity_1,GUI_RowA_Opacity_2,GUI_RowA_Gradient_Angle,50.0,50.0,true,true,true,true);
                 }
                 else{
                 ArrayFill(pixels,0,ArraySize(pixels),ColorToARGB(GUI_RowA_Color_1,GUI_RowA_Opacity_1));
                 }
                 if(GUI_RowA_Liners)
                 {
                 RCTN_LinersAdd(GUI_RowA_Liner_Type,GUI_RowA_Liner_Color,GUI_RowA_Liner_Opacity,GUI_RowA_Liner_Angle,0.0,0.0,GUI_RowA_Liner_Gap,GUI_RowA_Liner_Width,false,true,true,true);
                 }
                 if(GUI_RowA_Gradient){test_draw_gradient_from_settings(pixels,dx,dy);}
                 if(GUI_RowA_Liners){test_draw_liners(pixels,dx,dy);}
                 if(GUI_RowA_Noise){
                 RCTN_Noise_Applicator(pixels,dx,dy,GUI_RowA_Noise_Min,GUI_RowA_Noise_Max,true,false,true,true,true);
                 }
   
                 rezName="GUI_ROW1";
                 created=ResourceCreate(rezName,pixels,dx,dy,0,0,dx,COLOR_FORMAT_ARGB_NORMALIZE);
                 if(created){add_to_string_array(myResources,rezName);}             
               //row B
                 RCTN_GradientsReset();
                 RCTN_LinersReset();
                 if(GUI_RowB_Gradient){
                 RCTN_GradientsAdd(GUI_RowB_Gradient_Type,GUI_RowB_Color_1,GUI_RowB_Color_2,GUI_RowB_Opacity_1,GUI_RowB_Opacity_2,GUI_RowB_Gradient_Angle,50.0,50.0,true,true,true,true);
                 }
                 else{
                 ArrayFill(pixels,0,ArraySize(pixels),ColorToARGB(GUI_RowB_Color_1,GUI_RowB_Opacity_1));
                 }
                 if(GUI_RowB_Liners)
                 {
                 RCTN_LinersAdd(GUI_RowB_Liner_Type,GUI_RowB_Liner_Color,GUI_RowB_Liner_Opacity,GUI_RowB_Liner_Angle,0.0,0.0,GUI_RowB_Liner_Gap,GUI_RowB_Liner_Width,false,true,true,true);
                 }
                 if(GUI_RowB_Gradient){test_draw_gradient_from_settings(pixels,dx,dy);}
                 if(GUI_RowB_Liners){test_draw_liners(pixels,dx,dy);}
                 if(GUI_RowB_Noise){
                 RCTN_Noise_Applicator(pixels,dx,dy,GUI_RowB_Noise_Min,GUI_RowB_Noise_Max,true,false,true,true,true);
                 }
   
                 rezName="GUI_ROW2";
                 created=ResourceCreate(rezName,pixels,dx,dy,0,0,dx,COLOR_FORMAT_ARGB_NORMALIZE);
                 if(created){add_to_string_array(myResources,rezName);}   
                 
                 //CLOSE BTN --------------------------------------------------------    
                 
               //create close button hover and normal
                 //utilization max 
                   int max_close_sx=(int)(((double)GUI_DeckWidth)*50);
                 //find new size based on aspect ratio and the height provided 
                   uint close_pixels[],close_original_sx=0,close_original_sy=0;
                   bool grab_close=ResourceReadImage(GUI_CLOSE,close_pixels,close_original_sx,close_original_sy);
                   if(grab_close){
                   double close_ratio=((double)close_original_sx)/((double)close_original_sy);
                   int close_sy=GUI_Close_Height;
                   int close_sx=(int)(((double)close_sy)*close_ratio);
                   if(close_sx>max_close_sx){close_sx=max_close_sx;close_sy=(int)(((double)close_sx)/close_ratio);}
                   _close_sx=close_sx;_close_sy=close_sy;
                   //we have the new size here , hit it 
                    //create close normal style first 
                      uint clgradient_pixels[];
                      resize_and_rearray(close_pixels,close_original_sx,close_original_sy,close_sx,close_sy,pixels);
                      ArrayResize(clgradient_pixels,close_sx*close_sy,0);
                      RCTN_GradientsReset();RCTN_LinersReset();
                      if(GUI_CloseNormal_Gradient){
                      RCTN_GradientsAdd(GUI_CloseNormal_Gradient_Type,GUI_CloseNormal_Color_1,GUI_CloseNormal_Color_2,GUI_CloseNormal_Opacity_1,GUI_CloseNormal_Opacity_2,GUI_CloseNormal_Gradient_Angle,50.0,50.0,true,true,true,true);
                      }
                      if(GUI_CloseNormal_Liners){
                      RCTN_LinersAdd(GUI_CloseNormal_Liner_Type,GUI_CloseNormal_Liner_Color,GUI_CloseNormal_Liner_Opacity,GUI_CloseNormal_Liner_Angle,0,0,GUI_CloseNormal_Liner_Gap,GUI_CloseNormal_Liner_Width,true,true,true,true);
                      }
                      if(GUI_CloseNormal_Gradient){
                      test_draw_gradient_from_settings(clgradient_pixels,close_sx,close_sy);
                      }else{ArrayFill(clgradient_pixels,0,ArraySize(clgradient_pixels),ColorToARGB(GUI_CloseNormal_Color_1,GUI_CloseNormal_Opacity_1));}
                      if(GUI_CloseNormal_Liners){
                      test_draw_liners(clgradient_pixels,close_sx,close_sy);
                      }
                      if(GUI_CloseNormal_Noise){
                      RCTN_Noise_Applicator(clgradient_pixels,close_sx,close_sy,GUI_CloseNormal_Noise_Min,GUI_CloseNormal_Noise_Max,true,false,true,true,true);
                      }
                      //so we take the RESIZED logo and paint it with the RESIZED style
                      grab_mask_and_style(pixels,close_sx,close_sy,close_pixels,clrBlack,false,close_sx,close_sy,clgradient_pixels,close_sx,close_sy);
                      //aand we create a resource finally 
                        rezName="GUI_CLOSE_NORMAL";
                          //text
                            TextSetFont("Arial",close_sy/2,FW_BOLD,0);
                            TextOut("Close All",close_sx/2,close_sy/2,TA_CENTER|TA_VCENTER,close_pixels,close_sx,close_sy,ColorToARGB(GUI_CloseNormal_Text,255),COLOR_FORMAT_ARGB_NORMALIZE);                        
                        created=ResourceCreate(rezName,close_pixels,close_sx,close_sy,0,0,close_sx,COLOR_FORMAT_ARGB_NORMALIZE);
                        add_to_string_array(myResources,rezName);     
                        //HOVER 
                          RCTN_GradientsReset();RCTN_LinersReset();
                          if(GUI_CloseHover_Gradient){
                          RCTN_GradientsAdd(GUI_CloseHover_Gradient_Type,GUI_CloseHover_Color_1,GUI_CloseHover_Color_2,GUI_CloseHover_Opacity_1,GUI_CloseHover_Opacity_2,GUI_CloseHover_Gradient_Angle,50.0,50.0,true,true,true,true);
                          }
                          if(GUI_CloseHover_Liners){
                          RCTN_LinersAdd(GUI_CloseHover_Liner_Type,GUI_CloseHover_Liner_Color,GUI_CloseHover_Liner_Opacity,GUI_CloseHover_Liner_Angle,0,0,GUI_CloseHover_Liner_Gap,GUI_CloseHover_Liner_Width,true,true,true,true);
                          }
                          if(GUI_CloseHover_Gradient){
                          test_draw_gradient_from_settings(clgradient_pixels,close_sx,close_sy);
                          }else{ArrayFill(clgradient_pixels,0,ArraySize(clgradient_pixels),ColorToARGB(GUI_CloseHover_Color_1,GUI_CloseHover_Opacity_1));}
                          if(GUI_CloseHover_Liners){
                          test_draw_liners(clgradient_pixels,close_sx,close_sy);
                          }
                          if(GUI_CloseHover_Noise){
                          RCTN_Noise_Applicator(clgradient_pixels,close_sx,close_sy,GUI_CloseHover_Noise_Min,GUI_CloseHover_Noise_Max,true,false,true,true,true);
                          }  
                          //so we take the RESIZED logo and paint it with the RESIZED style
                            grab_mask_and_style(pixels,close_sx,close_sy,close_pixels,clrBlack,false,close_sx,close_sy,clgradient_pixels,close_sx,close_sy);
                          //text
                            TextSetFont("Arial",close_sy/2,FW_BOLD,0);
                            TextOut("Close All",close_sx/2,close_sy/2,TA_CENTER|TA_VCENTER,close_pixels,close_sx,close_sy,ColorToARGB(GUI_CloseHover_Text,255),COLOR_FORMAT_ARGB_NORMALIZE);                        

                          //aand we create a resource finally 
                            rezName="GUI_CLOSE_HOVER";
                            created=ResourceCreate(rezName,close_pixels,close_sx,close_sy,0,0,close_sx,COLOR_FORMAT_ARGB_NORMALIZE);
                            add_to_string_array(myResources,rezName);                        
                            
                        //HOVER ENDS HERE                       
                     
                     
                   }else{Print("Cannot grab close resource");}  
                 //CLOSE BTN -------------------------------------------------------     
       }else{Print("Cannot create logo");}
     }else{Print("Cannot grab logo resource");}
}



int find_in_string_array(string &array[],string find){
for(int i=0;i<ArraySize(array);i++){
if(array[i]==find){return(i);}
}return(-1);
}
int add_to_string_array(string &array[],string add){
int ns=ArraySize(array)+1;
ArrayResize(array,ns,0);
array[ns-1]=add;
return(ns-1);
}

//Create LABEL 
  void HS_Create_Label(long cid,
                       int subw,
                       string name,
                       int px,
                       int py,
                       string font,
                       int fontsize,
                       color txt_col,
                       ENUM_ANCHOR_POINT anchor,
                       string text,
                       bool selectable,
                       bool back)
  {
  bool obji=ObjectCreate(cid,name,OBJ_LABEL,subw,0,0);
  if(obji)
    {
    ObjectSetString(cid,name,OBJPROP_FONT,font);
    ObjectSetInteger(cid,name,OBJPROP_ANCHOR,anchor);
    ObjectSetInteger(cid,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(cid,name,OBJPROP_XDISTANCE,px);
    ObjectSetInteger(cid,name,OBJPROP_YDISTANCE,py);
    ObjectSetInteger(cid,name,OBJPROP_COLOR,txt_col);
    ObjectSetInteger(cid,name,OBJPROP_SELECTABLE,selectable);
    ObjectSetInteger(cid,name,OBJPROP_BACK,back);
    ObjectSetString(cid,name,OBJPROP_TEXT,text);    
    }
  }
//CREATE BTN OBJECT
  void HS_Create_Btn(long cid,
                     int subw,
                     string name,
                     int sx,
                     int sy,
                     int px,
                     int py,
                     string font,
                     int fontsize,
                     color bck_col,
                     color brd_col,
                     ENUM_BORDER_TYPE brd_type,
                     color txt_col,
                     ENUM_ALIGN_MODE align,
                     string text,
                     bool selectable,
                     bool back)  
  {
  bool obji=ObjectCreate(cid,name,OBJ_BUTTON,subw,0,0);
  if(obji)
    {
    ObjectSetString(0,name,OBJPROP_FONT,font);
    ObjectSetInteger(0,name,OBJPROP_ALIGN,align);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_XSIZE,sx);
    ObjectSetInteger(0,name,OBJPROP_YSIZE,sy);
    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,px);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,py);
    ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bck_col);
    ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,brd_col);
    ObjectSetInteger(0,name,OBJPROP_COLOR,txt_col);
    ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,brd_type);
    ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selectable);
    ObjectSetInteger(0,name,OBJPROP_BACK,back);
    ObjectSetString(0,name,OBJPROP_TEXT,text);
    }
  }                   
//CREATE BTN OBJECT ENDS HERE   
//CREATE BMP OBJECT
  void HS_Create_Bmp(long cid,
                     int subw,
                     string name,
                     int sx,
                     int sy,
                     int px,
                     int py,
                     string resource,
                     bool selectable,
                     bool back)  
  {
  bool obji=ObjectCreate(cid,name,OBJ_BITMAP_LABEL,subw,0,0);
  if(obji)
    {
    ObjectSetInteger(0,name,OBJPROP_XSIZE,sx);
    ObjectSetInteger(0,name,OBJPROP_YSIZE,sy);
    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,px);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,py);
    ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selectable);
    ObjectSetInteger(0,name,OBJPROP_BACK,back);
    ObjectSetString(0,name,OBJPROP_BMPFILE,resource);
    }
  }  
//CREATE INPUT OBJECT
  void HS_Create_Edit(long cid,
                     int subw,
                     string name,
                     int sx,
                     int sy,
                     int px,
                     int py,
                     string font,
                     int fontsize,
                     color bck_col,
                     color brd_col,
                     ENUM_BORDER_TYPE brd_type,
                     color txt_col,
                     ENUM_ALIGN_MODE align,
                     string text,
                     bool selectable,
                     bool readonly,
                     bool back)  
  {
  bool obji=ObjectCreate(cid,name,OBJ_EDIT,subw,0,0);
  if(obji)
    {
    ObjectSetString(0,name,OBJPROP_FONT,font);
    ObjectSetInteger(0,name,OBJPROP_ALIGN,align);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_XSIZE,sx);
    ObjectSetInteger(0,name,OBJPROP_YSIZE,sy);
    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,px);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,py);
    ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bck_col);
    ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,brd_col);
    ObjectSetInteger(0,name,OBJPROP_COLOR,txt_col);
    ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,brd_type);
    ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selectable);
    ObjectSetInteger(0,name,OBJPROP_READONLY,readonly);
    ObjectSetInteger(0,name,OBJPROP_BACK,back);
    ObjectSetString(0,name,OBJPROP_TEXT,text);
    }
  }                   
  
//DISPLAY FUNCTIONS END HERE 
//CONTROLLER 
//+------------------------------------------------------------------+
  //Controller 
    //JC_ => CTFXEW CONTROL _ 
    //Switch for Date Control
      bool CTFXEW_CONTROL_DATE=true;
      datetime JC_Expiration=D'30.12.2024';
      string JC_MSG_DATE="Trial Expired ! ";//error message 
    //Switch for Account # Control 
      bool CTFXEW_CONTROL_ACCOUNT=false;
      int JC_Account=24231152;
      string JC_MSG_ACCOUNT="Invalid Account #.";//error message 
    //Switch for UserName - usually not needed
      bool CTFXEW_CONTROL_USER=false;
      string JC_user_name="";
      string JC_user_surname="";
      string JC_MSG_NAME="Invalid User .";//error message 
    //Switch for Broker   - usually not needed 
      bool CTFXEW_CONTROL_BROKER=false;
      string JC_Broker="";
      string JC_MSG_BROKER="Broker Not Supported .";//error message
    //Demo Live controller 
      bool CTFXEW_CONTROL_TYPE=true;
      bool CTFXEW_ALLOW_DEMO=true,CTFXEW_ALLOW_REAL=false;
      string JC_Message_Demo="Demo Accounts Not Allowed";
      string JC_Message_Real="Real Accounts Not Allowed";
    //time in minutes between checks 
      int JC_MINUTES=600;//10 hours 
  //ignore these 
  bool MASTER_JC_CONTROL=false;
  string MASTER_JC_NOTES="";
  datetime MASTER_JC_NEXT_C=0;
  
void CreateDemoNote()
{
ObjectsDeleteAll(0,"MQLNOTE_");
string message="";
//date
if(CTFXEW_CONTROL_DATE){message+="Valid until : "+TimeToString(JC_Expiration,TIME_DATE)+" ";}
//account 
if(CTFXEW_CONTROL_ACCOUNT){message+="For Account #"+IntegerToString(JC_Account)+" ";}
//user name
if(CTFXEW_CONTROL_USER){message+="For "+JC_user_name+" "+JC_user_surname+" ";}
//broker
if(CTFXEW_CONTROL_BROKER){message+="on "+JC_Broker;}
TextSetFont("Arial",20,0,0);
uint w,h;
TextGetSize(message,w,h);
int sizex=0;//(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)/4;
sizex=(int)w+20;
int sizey=(int)h+4;
int posx=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
posx=(int)((posx-sizex)/2);
HS_Create_Btn(0,0,"MQLNOTE_!",sizex,sizey,posx,0,"Arial",12,clrDarkRed,clrRed,BORDER_RAISED,clrWhite,ALIGN_CENTER,message,false,false);
}
//controller 
struct ctfxew_controller
{
bool valid;
string notes;
datetime next_checktime;
};
ctfxew_controller JCC()
{
ctfxew_controller returnio;
returnio.valid=false;
returnio.notes="ok";
returnio.next_checktime=TimeLocal()+JC_MINUTES*60;
bool r_date=true;
bool r_account=true;
bool r_name=true;
bool r_broker=true;
bool r_type=true;
string rtype_msg="";
if(CTFXEW_CONTROL_TYPE==true)
{
ENUM_ACCOUNT_TRADE_MODE tm=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
if(!CTFXEW_ALLOW_DEMO&&(tm==ACCOUNT_TRADE_MODE_DEMO||tm==ACCOUNT_TRADE_MODE_CONTEST)){r_type=false;rtype_msg=JC_Message_Demo;}
if(!CTFXEW_ALLOW_REAL&&(tm==ACCOUNT_TRADE_MODE_REAL)){r_type=false;rtype_msg=JC_Message_Real;}
}
if(CTFXEW_CONTROL_DATE==true)
{
datetime t1=TimeCurrent();
datetime t2=TimeLocal();
datetime t3=iTime(Symbol(),Period(),0);
if(t1>=JC_Expiration||t2>=JC_Expiration||t3>=JC_Expiration) r_date=false; 
}

if(CTFXEW_CONTROL_ACCOUNT==true)
{
if(AccountNumber()!=JC_Account) r_account=false;
}

if(CTFXEW_CONTROL_USER==true)
{
string zeuser=AccountName();
if(StringFind(zeuser,JC_user_name,0)==-1||StringFind(zeuser,JC_user_surname,0)==-1) r_name=false;
}

if(CTFXEW_CONTROL_BROKER==true)
{
string brok=AccountCompany();
if(StringFind(brok,JC_Broker,0)==-1) r_broker=false;
}
returnio.notes="";
if(r_date==false) returnio.notes=JC_MSG_DATE;
if(r_name==false) returnio.notes+=JC_MSG_NAME;
if(r_account==false) returnio.notes+=JC_MSG_ACCOUNT;
if(r_broker==false) returnio.notes+=JC_MSG_BROKER;
if(r_type==false) returnio.notes+=rtype_msg;
if(r_date&&r_account&&r_name&&r_broker&&r_type){returnio.notes="ok";returnio.valid=true;}

return(returnio);
}
//CONTROLLER 
void CTFX_Links(string links,string text)
{
if(!IsDllsAllowed()) Alert(text+"\n"+links);
if(IsDllsAllowed()==true) ShellExecuteW(NULL,"open",links,"","",5);
}