#property strict
enum object_type
{
obj_none=0,//none
obj_label=1,//label
obj_edit=2,//edit
obj_button=3,//button
obj_bitmap=4,//bitmap
obj_rectangle=5//rectangle
};
bool has_sizes[]={false,false,true,true,true,true};
bool has_text[]={false,true,true,true,false,false};
class board_object
{
public:
long CID;
int SUBW;
object_type Type;
string Name;//object name
string ShortName;//Short name is used to edit the object 
string PreText,Value,Command;//example ,pretext is Trades: ,on update we only send the #of trades and the object displays Trades:# !
bool HasSize,HasText,HasCommand;
int OffsetX,OffsetY,SizeX,SizeY;
board_object(void){ObjectDelete(0,Name);HasSize=false;HasText=false;HasCommand=false;}
~board_object(void){ObjectDelete(0,Name);delete GetPointer(this);}
void Add(string name,
         string short_name,
         string pre_text,
         object_type type,
         int off_x,
         int off_y,
         long chart_id,
         int subwindow,
         bool has_command,
         string command)
{
CID=chart_id;
SUBW=subwindow;
PreText=pre_text;
ShortName=short_name;
Value=NULL;
Command=command;
HasCommand=has_command;
HasText=has_text[type];
Name=name;
Type=type;
HasSize=has_sizes[type];
OffsetX=off_x;
OffsetY=off_y;
if(HasSize){SizeX=(int)ObjectGetInteger(chart_id,Name,OBJPROP_XSIZE);SizeY=(int)ObjectGetInteger(chart_id,Name,OBJPROP_YSIZE);}
}
void ChangePreText(string new_pretext,bool update_object){PreText=new_pretext;if(update_object&&HasText){ObjectSetString(CID,Name,OBJPROP_TEXT,PreText+Value);}}
void ChangeValue(string new_value,bool update_object){Value=new_value;if(update_object&&HasText){ObjectSetString(CID,Name,OBJPROP_TEXT,PreText+Value);}}
void ChangeTextColor(color new_color){ObjectSetInteger(CID,Name,OBJPROP_COLOR,new_color);}
void Bolden(){ObjectSetString(CID,Name,OBJPROP_FONT,"Arial Bold");}
void UnBolden(){ObjectSetString(CID,Name,OBJPROP_FONT,"Arial");}
void operator>(string new_value){ChangeValue(new_value,true);}
void operator<(bool bolden){if(bolden){Bolden();}if(!bolden){UnBolden();}}
void operator<(color new_color){ChangeTextColor(new_color);}
void operator=(bool show){if(!show){ObjectSetInteger(CID,Name,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);}if(show){ObjectSetInteger(CID,Name,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);}}
void operator<(string &get_value){get_value=ObjectGetString(CID,Name,OBJPROP_TEXT);}
};
struct objects_group
{
private:
bool HoverBeforeClick,Hover,IsMoving,CancelScroll,AnyElementsWithCommands;
int click_offset_x,click_offset_y;
int HoverSX,HoverSY,HoverEX,HoverEY;
public:
board_object Objects[];
long CID;
int SUBW;
int PosX,PosY,SizeX,SizeY;
objects_group(void){ArrayFree(Objects);HoverBeforeClick=false;Hover=false;IsMoving=false;AnyElementsWithCommands=false;}
~objects_group(void){ArrayFree(Objects);HoverBeforeClick=false;Hover=false;IsMoving=false;AnyElementsWithCommands=false;}
objects_group(long chart_id,int subwindow){ArrayFree(Objects);SetChart(chart_id,subwindow);HoverBeforeClick=false;Hover=false;IsMoving=false;}
void SetChart(long chart_id,int subwindow){CID=chart_id;SUBW=subwindow;}
//Add object
void AddObject(string name,
               string short_name,
               string pre_text,
               object_type type,
               int offset_x,
               int offset_y,
               bool update,
               bool has_command,
               string command)
{
int newsize=ArraySize(Objects)+1;
ArrayResize(Objects,newsize,0);
if(has_command){AnyElementsWithCommands=true;}
Objects[newsize-1].Add(name,short_name,pre_text,type,offset_x,offset_y,CID,SUBW,has_command,command);
FindHoverData();
if(update)
  {
  Objects[newsize-1].ChangePreText(pre_text,true);
  }
}
//Relocate
void Relocate(int px,int py,bool redraw_chart)
{
PosX=px;
PosY=py;
  for(int o=0;o<ArraySize(Objects);o++)
  {
  ObjectSetInteger(CID,Objects[o].Name,OBJPROP_XDISTANCE,PosX+Objects[o].OffsetX);
  ObjectSetInteger(CID,Objects[o].Name,OBJPROP_YDISTANCE,PosY+Objects[o].OffsetY);
  }
  FindHoverData();
if(redraw_chart){ChartRedraw(CID);}
}
string ChartEvent(const int id,
                const long &lparam,
                const double &dparam,
                const string &sparam,
                bool auto_detect_symbols_in_labels,
                bool auto_detect_commands){
//string return is for detected commands if enabled
/*
each element has an internal click command - optional - string
*/
string command="NONE";
//click and autodetect symbols 
if(id==CHARTEVENT_OBJECT_CLICK&&auto_detect_symbols_in_labels)
  {
    if(ObjectGetInteger(ChartID(),sparam,OBJPROP_TYPE)==OBJ_LABEL||ObjectGetInteger(ChartID(),sparam,OBJPROP_TYPE)==OBJ_BUTTON){
    string lbl_content=ObjectGetString(ChartID(),sparam,OBJPROP_TEXT);
    bool tu=StringToUpper(lbl_content);
    int sytotal=SymbolsTotal(true);
    for(int s=0;s<sytotal;s++){
    if(lbl_content==SymbolName(s,true)){
      ChartOpen(lbl_content,PERIOD_CURRENT);
      break;
      }
    }
    }
  }
//click and autodetect commands 
if(id==CHARTEVENT_OBJECT_CLICK&&auto_detect_commands&&AnyElementsWithCommands)
  {
  //match name 
    int f=-1;
    for(int o=0;o<ArraySize(Objects);o++){if(sparam==Objects[o].Name&&Objects[o].HasCommand){command=Objects[o].Command;break;}}
  //match name 
  }
//mousemove
if(id==CHARTEVENT_MOUSE_MOVE){
  IsHovering((int)lparam,(int)dparam,sparam,Hover,HoverBeforeClick);
  //if clicking
  if(sparam=="1"){
  //look for possible mousedown on command buttons
  string possible_command="NONE";
  if(auto_detect_commands&&AnyElementsWithCommands)
  {
  for(int o=0;o<ArraySize(Objects);o++)
     {
     int b_fx=PosX+Objects[o].OffsetX;
     int b_fy=PosY+Objects[o].OffsetY;
     int b_ex=b_fx+Objects[o].SizeX;
     int b_ey=b_fy+Objects[o].SizeY;
     int mcx=(int)lparam;
     int mcy=(int)dparam;
     if(Objects[o].HasCommand)
       {
       if(mcx>=b_fx&&mcx<=b_ex&&mcy>=b_fy&&mcy<=b_ey)
         {
         possible_command=Objects[o].Command;break;
         }
       }
     }
  }
  //look for possible mousedown on command buttons ends here
  //and not moving 
    if(!IsMoving&&Hover&&HoverBeforeClick&&command=="NONE"&&possible_command=="NONE"){
    IsMoving=true;
    click_offset_x=((int)lparam)-PosX;
    click_offset_y=((int)dparam)-PosY;
    CancelScroll=(bool)(ChartGetInteger(CID,CHART_MOUSE_SCROLL));
    if(CancelScroll){ChartSetInteger(CID,CHART_MOUSE_SCROLL,false);}
    }
  //and not moving 
  }
  //if clicking ends here
  //if moving
  if(IsMoving)
  {
  //cancel
    if(sparam=="0"){
    IsMoving=false;
    if(CancelScroll){ChartSetInteger(CID,CHART_MOUSE_SCROLL,true);}
    }
  int new_x=((int)lparam)-click_offset_x;
  int new_y=((int)dparam)-click_offset_y;
  Relocate(new_x,new_y,true);
  }
  //if moving ends here
  }
return(command);
}
private:
void IsHovering(int mx,int my,string mcc,bool &hover_trigger,bool &hover_before_click_trigger)
  {
  hover_trigger=false;
  if(mx>=HoverSX&&mx<=HoverEX&&my>=HoverSY&&my<=HoverEY){hover_trigger=true;if(mcc=="0"){hover_before_click_trigger=true;}}
  if(!hover_trigger){hover_before_click_trigger=false;}
  }
//change value directly by shortname
int FindByShortName(string short_name){for(int o=0;o<ArraySize(Objects);o++){if(short_name==Objects[o].ShortName){return(o);}}return(-1);}
void FindHoverData(){
int px=PosX,py=PosY;
HoverSX=px;HoverEX=px;HoverSY=py;HoverEY=py;
//loop into objects
  for(int o=0;o<ArraySize(Objects);o++)
  {
  if(Objects[o].HasSize){
    int left_x=px+Objects[o].OffsetX,right_x=px+Objects[o].OffsetX,top_y=py+Objects[o].OffsetY,bottom_y=py+Objects[o].OffsetY;
    //anchor
    ENUM_ANCHOR_POINT anchor=(ENUM_ANCHOR_POINT)ObjectGetInteger(CID,Objects[o].Name,OBJPROP_ANCHOR);
    if(anchor==ANCHOR_LEFT_UPPER){right_x+=Objects[o].SizeX;bottom_y+=Objects[o].SizeY;}
    if(anchor==ANCHOR_LEFT){top_y-=(Objects[o].SizeY/2);bottom_y+=(Objects[o].SizeY/2);right_x+=Objects[o].SizeX;}
    if(anchor==ANCHOR_LEFT_LOWER){top_y-=Objects[o].SizeY;right_x+=Objects[o].SizeX;}
    if(anchor==ANCHOR_RIGHT_UPPER){bottom_y+=Objects[o].SizeY;left_x-=Objects[o].SizeX;}
    if(anchor==ANCHOR_RIGHT){top_y-=(Objects[o].SizeY/2);bottom_y+=(Objects[o].SizeY/2);left_x-=Objects[o].SizeX;}
    if(anchor==ANCHOR_RIGHT_LOWER){top_y-=Objects[o].SizeY;left_x-=Objects[o].SizeX;}
    if(anchor==ANCHOR_UPPER){left_x-=(Objects[o].SizeX/2);right_x+=(Objects[o].SizeX/2);bottom_y+=Objects[o].SizeY;}
    if(anchor==ANCHOR_LOWER){left_x-=(Objects[o].SizeX/2);right_x+=(Objects[o].SizeX/2);top_y-=Objects[o].SizeY;}
    if(anchor==ANCHOR_CENTER){left_x-=(Objects[o].SizeX/2);right_x+=(Objects[o].SizeX/2);top_y-=(Objects[o].SizeY/2);bottom_y+=(Objects[o].SizeY/2);}
    if(left_x<HoverSX){HoverSX=left_x;}
    if(right_x>HoverEX){HoverEX=right_x;}
    if(top_y<HoverSY){HoverSY=top_y;}
    if(bottom_y>HoverEY){HoverEY=bottom_y;}
    }
  }
//loop into objects 
}
public:
board_object* operator>(string short_name){int f=FindByShortName(short_name);if(f!=-1){return(GetPointer(Objects[f]));}return(NULL);}
};


/* EXAMPLES 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
objects_group OG;
string SystemTag="HAWA_",SystemHeader="HAWA";
bool IsMinimized=false,has_timer=false,SystemBusy=false;

int OnInit()
  {
  
  SystemBusy=false;
  ObjectsDeleteAll(ChartID(),SystemTag);  
  OG.SetChart(ChartID(),0);
  IsMinimized=false;
  BuildDeck(OG,IsMinimized,SySt,start_x,start_y,CloseBy_Pips,CloseBy_Amount,CloseBy_Risk); 
  ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,true);

  return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
  //system busy check
  if(!SystemBusy)
  {
  SystemBusy=true;
//---
  if(id==CHARTEVENT_OBJECT_CLICK){ObjectSetInteger(ChartID(),sparam,OBJPROP_STATE,false);}
  string command=OG.ChartEvent(id,lparam,dparam,sparam,true,true);  
  //this system is equipped with auto command return to the events function
  SystemBusy=false;
  }
  }

//+------------------------------------------------------------------+
//BUILD DECK
double columns_p[]={18.0,16.0,12.0,10.0,20.0,12.0,12.0};//percentages 
double columns[]={0,0,0,0,0,0,0};
ENUM_ALIGN_MODE columns_align[]={ALIGN_LEFT,ALIGN_RIGHT,ALIGN_RIGHT,ALIGN_CENTER,ALIGN_RIGHT,ALIGN_CENTER,ALIGN_CENTER};
string column_titles[]={"PAIR(s)","AMOUNT","RISK","LOTS","P/L","LIVE","PENDING"};
void BuildDeck(objects_group &og,
               bool &is_minimized,
               symbol_stats &ss,
               int posx,
               int posy,
               bool close_by_pips,
               bool close_by_amount,
               bool close_by_risk)
{
double unit_x=((double)size_x)/100.0;
for(int c=0;c<ArraySize(columns);c++){columns[c]=unit_x*columns_p[c];}
int px=posx;
int py=posy;
int poffx=size_x/60;
int btn_size=row_height-row_height/5;
int btn_offset_y=(row_height-btn_size)/2;
int poffy=row_height/20;
ArrayFree(og.Objects);
int rows=1;
if(!is_minimized){
  if(ss.list_total>0){
  rows+=2+ss.list_total;
  }
rows+=1;
if(ss.list_total>0){
if(close_by_pips){rows+=1;}
if(close_by_amount){rows+=1;}
if(close_by_risk){rows+=1;}
}}
if(ss.list_total==0&&!is_minimized){rows+=2;}
string objna="";
  //background
  objna=SystemTag+"_Background";
  HS_Create_Btn(ChartID(),0,objna,size_x,row_height*rows,px,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"",false,false);
  og.AddObject(objna,"","",obj_button,0,0,true,false,NULL);
  //header - always visible 
    objna=SystemTag+"_Header_Background";
    HS_Create_Btn(ChartID(),0,objna,size_x,row_height,px,py,"Arial",i_font_size,CLR_Header_Back,CLR_Header_Border,BRD_Header_Type,CLR_Header_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"","",obj_button,0,0,true,false,NULL);
    //title of window 
    objna=SystemTag+"_Header_Title";
    HS_Create_Label(ChartID(),0,objna,px+poffx,py+poffy,"Arial",i_font_size,CLR_Header_Text,ANCHOR_LEFT_UPPER,SystemHeader,false,false);
    og.AddObject(objna,"HeaderTitle","",obj_label,px+poffx-posx,py+poffy-posy,true,false,NULL);
    //quit button 
    objna=SystemTag+"_Header_X";
    HS_Create_Btn(ChartID(),0,objna,btn_size,btn_size,px+size_x-btn_size-btn_offset_y,py+btn_offset_y,"Webdings",(int)(i_font_size*1.2),CLR_Header_Btn_Back,CLR_Header_Btn_Border,BRD_Type,CLR_Header_Btn_Text,ALIGN_CENTER,"X",false,false);
    og.AddObject(objna,"QuitBtn","r",obj_button,size_x-btn_size-btn_offset_y,py+btn_offset_y-posy,true,true,"QUIT");
    //minimize button
    objna=SystemTag+"_Header_Minimize";
    HS_Create_Btn(ChartID(),0,objna,btn_size,btn_size,px+size_x-btn_size*2-btn_offset_y*2,py+btn_offset_y,"Webdings",(int)(i_font_size*1.2),CLR_Header_Btn_Back,CLR_Header_Btn_Border,BRD_Type,CLR_Header_Btn_Text,ALIGN_CENTER,"-",false,false);
    og.AddObject(objna,"MinimizeBtn","",obj_button,size_x-btn_size*2-btn_offset_y*2,py+btn_offset_y-posy,true,true,"MINIMIZE");
    //if minimized and show stats on minimize 
      if(is_minimized&&show_stats_on_minimize){
      int ax=px;
      for(int c=0;c<ArraySize(columns);c++){
      if(column_titles[c]!="LIVE"&&column_titles[c]!="PENDING"&&c>0){
      objna=SystemTag+"_Total_"+column_titles[c];
      HS_Create_Btn(ChartID(),0,objna,(int)columns[c],row_height-2,ax,py+1,"Arial",i_font_size,CLR_Header_Back,CLR_Header_Back,BRD_Type,CLR_Text,ALIGN_CENTER,"",false,false);
      og.AddObject(objna,column_titles[c]+"_Total","",obj_button,ax-posx,py+1-posy,true,false,NULL);
      }
      int btn_x_reduce=(int)((columns[c]/100.0)*Btns_X_Reduce);
      int btn_x_reduce_half=btn_x_reduce/2;
      int btn_y_reduce=(int)((((double)row_height)/100.0)*Btns_Y_Reduce);
      int btn_y_reduce_half=btn_y_reduce/2;
      ax+=(int)columns[c];
      }      
      }
    //if minimized and show stats on minimize ends here 
  //if not minimized
  if(!is_minimized)
  {
  py+=row_height;  
  //titles 
    int ax=px;
    for(int c=0;c<ArraySize(columns);c++){
    objna=SystemTag+"_Table_Title_"+column_titles[c];
    HS_Create_Edit(ChartID(),0,objna,(int)columns[c],row_height,ax,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Title_Text,columns_align[c],"",false,true,false);
    og.AddObject(objna,column_titles[c]+"Title",column_titles[c],obj_edit,ax-posx,py-posy,true,false,NULL);    
    ax+=(int)columns[c];
    }
  //titles ends here  
  //data 
    ax=px;
    py+=row_height;
    for(int r=0;r<ss.list_total;r++)
    {
    ax=px;
    for(int c=0;c<ArraySize(columns);c++){
    //non live or pending 
    if(column_titles[c]!="LIVE"&&column_titles[c]!="PENDING"){
    objna=SystemTag+"_Table_"+IntegerToString(r)+"_"+column_titles[c];
    HS_Create_Edit(ChartID(),0,objna,(int)columns[c],row_height,ax,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,columns_align[c],"",false,true,false);
    og.AddObject(objna,column_titles[c]+"_"+IntegerToString(r),"",obj_edit,ax-posx,py-posy,true,false,NULL);
    }
    //non live or pending 
    int btn_x_reduce=(int)((columns[c]/100.0)*Btns_X_Reduce);
    int btn_x_reduce_half=btn_x_reduce/2;
    int btn_y_reduce=(int)((((double)row_height)/100.0)*Btns_Y_Reduce);
    int btn_y_reduce_half=btn_y_reduce/2;
    //live
    if(column_titles[c]=="LIVE"){
    objna=SystemTag+"_Table_"+IntegerToString(r)+"_"+column_titles[c];
    HS_Create_Btn(ChartID(),0,objna,(int)columns[c]-btn_x_reduce,row_height-btn_y_reduce,ax+btn_x_reduce_half,py+btn_y_reduce_half,"Arial",i_font_size,CLR_Back_Close_Live,CLR_Brd_Close_Live,BRD_Type,CLR_Text_Close_Live,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,column_titles[c]+"_"+IntegerToString(r),"",obj_button,ax+btn_x_reduce_half-posx,py+btn_y_reduce_half-posy,true,true,"CLOSE LIVE "+ss.list[r].symbol);
    }
    //live
    //pending
    if(column_titles[c]=="PENDING"){
    objna=SystemTag+"_Table_"+IntegerToString(r)+"_"+column_titles[c];
    HS_Create_Btn(ChartID(),0,objna,(int)columns[c]-btn_x_reduce,row_height-btn_y_reduce,ax+btn_x_reduce_half,py+btn_y_reduce_half,"Arial",i_font_size,CLR_Back_Close_Pending,CLR_Brd_Close_Pending,BRD_Type,CLR_Text_Close_Pending,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,column_titles[c]+"_"+IntegerToString(r),"",obj_button,ax+btn_x_reduce_half-posx,py+btn_y_reduce_half-posy,true,true,"DELETE PENDING "+ss.list[r].symbol);
    }
    //pending
    ax+=(int)columns[c];
    }
    py+=row_height;
    }
  //data ends here
    py+=row_height/4;
    //separator
    objna=SystemTag+"_separator1";
    HS_Create_Btn(ChartID(),0,objna,size_x,1,px,py,"Arial",i_font_size,separator_color,separator_color,BORDER_FLAT,separator_color,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"separator1","",obj_button,px-posx,py-posy,true,false,NULL);    
    py+=2;
  //total 
    ax=px;
    for(int c=0;c<ArraySize(columns);c++){
    if(column_titles[c]!="LIVE"&&column_titles[c]!="PENDING"){
    objna=SystemTag+"_Total_"+column_titles[c];
    HS_Create_Edit(ChartID(),0,objna,(int)columns[c],row_height,ax,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,columns_align[c],"",false,true,false);
    og.AddObject(objna,column_titles[c]+"_Total","",obj_edit,ax-posx,py-posy,true,false,NULL);    
    }
    int btn_x_reduce=(int)((columns[c]/100.0)*Btns_X_Reduce);
    int btn_x_reduce_half=btn_x_reduce/2;
    int btn_y_reduce=(int)((((double)row_height)/100.0)*Btns_Y_Reduce);
    int btn_y_reduce_half=btn_y_reduce/2;
    //live
    if(column_titles[c]=="LIVE"){
    objna=SystemTag+"_Total_"+column_titles[c];
    HS_Create_Btn(ChartID(),0,objna,(int)columns[c]-btn_x_reduce,row_height-btn_y_reduce,ax+btn_x_reduce_half,py+btn_y_reduce_half,"Arial",i_font_size,CLR_Back_Close_Live,CLR_Brd_Close_Live,BRD_Type,CLR_Text_Close_Live,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,column_titles[c]+"_Total","",obj_button,ax+btn_x_reduce_half-posx,py+btn_y_reduce_half-posy,true,true,"CLOSE ALL LIVE");
    }
    //live
    //pending
    if(column_titles[c]=="PENDING"){
    objna=SystemTag+"_Total_"+column_titles[c];
    HS_Create_Btn(ChartID(),0,objna,(int)columns[c]-btn_x_reduce,row_height-btn_y_reduce,ax+btn_x_reduce_half,py+btn_y_reduce_half,"Arial",i_font_size,CLR_Back_Close_Pending,CLR_Brd_Close_Pending,BRD_Type,CLR_Text_Close_Pending,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,column_titles[c]+"_Total","",obj_button,ax+btn_x_reduce_half-posx,py+btn_y_reduce_half-posy,true,true,"DELETE ALL PENDING");
    }
    //pending    
    ax+=(int)columns[c];
    }
    py+=row_height+1;
    //separator
    objna=SystemTag+"_separator2";
    HS_Create_Btn(ChartID(),0,objna,size_x,1,px,py,"Arial",i_font_size,separator_color,separator_color,BORDER_FLAT,separator_color,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"separator2","",obj_button,px-posx,py-posy,true,false,NULL);  
    py+=+row_height/2+2;
  //total ends here
  if(ss.list_total>0)
  {
    int c=ArraySize(columns)-1;
    int btn_x_reduce=(int)((columns[c]/100.0)*Btns_X_Reduce);
    int btn_x_reduce_half=btn_x_reduce/2;
    int btn_y_reduce=(int)((((double)row_height)/100.0)*Btns_Y_Reduce);
    int btn_y_reduce_half=btn_y_reduce/2;
    bool break_symmetry=true;
  //close by risk
  if(close_by_risk){
  //close profitable 
    objna=SystemTag+"_Close_Profitable_Risk_Label";
    HS_Create_Edit(ChartID(),0,objna,size_x/4,row_height,px,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"Close By % Profit",false,true,false);
    og.AddObject(objna,"CloseProfitableRiskTitle","    Close By % Profit : ",obj_edit,px-posx,py-posy,true,false,NULL);
    //input
    objna=SystemTag+"_Close_Profitable_Risk_Value";
    HS_Create_Edit(ChartID(),0,objna,size_x/10,row_height,px+size_x/4,py,"Arial",i_font_size,CLR_Edit_Back,CLR_Edit_Border,BRD_Edit_Type,CLR_Edit_Text,ALIGN_CENTER,"0",false,false,false);
    og.AddObject(objna,"CloseProfitableRiskValue","",obj_edit,px+size_x/4-posx,py-posy,true,false,NULL);
    OG>"CloseProfitableRiskValue">DoubleToString(last_risk_profit_value,1)+"%";
    //btn
    objna=SystemTag+"_Close_Profitable_Risk_Btn";
    HS_Create_Btn(ChartID(),0,objna,size_x/10,row_height,px+size_x/4+size_x/10,py,"Arial",i_font_size,CLR_Profit_Btn_Back,CLR_Profit_Btn_Border,BRD_Profit_Btn_Type,CLR_Profit_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseProfitableRiskBtn","Close",obj_button,px+size_x/4+size_x/10-posx,py-posy,true,true,"CLOSE PROFITABLE RISK");
    
  int bx=px+size_x/4+size_x/5+size_x/10;
  //close losing
    objna=SystemTag+"_Close_Losing_Risk_Label";
    HS_Create_Edit(ChartID(),0,objna,size_x/4,row_height,bx,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"Close By % Loss",false,true,false);
    og.AddObject(objna,"CloseLosingRiskTitle","    Close By % Loss : ",obj_edit,bx-posx,py-posy,true,false,NULL);
    //input
    objna=SystemTag+"_Close_Losing_Risk_Value";
    HS_Create_Edit(ChartID(),0,objna,size_x/10,row_height,bx+size_x/4,py,"Arial",i_font_size,CLR_Edit_Back,CLR_Edit_Border,BRD_Edit_Type,CLR_Edit_Text,ALIGN_CENTER,"0",false,false,false);
    og.AddObject(objna,"CloseLosingRiskValue","",obj_edit,bx+size_x/4-posx,py-posy,true,false,NULL);
    OG>"CloseLosingRiskValue">DoubleToString(last_risk_loss_value,1)+"%";
    //btn
    if(!break_symmetry){
    objna=SystemTag+"_Close_Losing_Risk_Btn";
    HS_Create_Btn(ChartID(),0,objna,size_x/10,row_height,bx+size_x/4+size_x/10,py,"Arial",i_font_size,CLR_Loss_Btn_Back,CLR_Loss_Btn_Border,BRD_Loss_Btn_Type,CLR_Loss_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseLosingRiskBtn","Close",obj_button,bx+size_x/4+size_x/10-posx,py-posy,true,true,"CLOSE LOSING RISK");}
    if(break_symmetry){
    ax=px+size_x-(int)columns[c];
    objna=SystemTag+"_Close_Losing_Risk_Btn";
    HS_Create_Btn(ChartID(),0,objna,(int)columns[c]-btn_x_reduce,row_height,ax+btn_x_reduce_half,py,"Arial",i_font_size,CLR_Loss_Btn_Back,CLR_Loss_Btn_Border,BRD_Loss_Btn_Type,CLR_Loss_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseLosingRiskBtn","Close",obj_button,ax+btn_x_reduce_half-posx,py-posy,true,true,"CLOSE LOSING RISK");}
         
    py+=row_height;
  }
  //close by risk ends here  
  //close by pips
  if(close_by_pips){
  //close profitable 
    objna=SystemTag+"_Close_Profitable_Pips_Label";
    HS_Create_Edit(ChartID(),0,objna,size_x/4,row_height,px,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"Close By Pips Profit",false,true,false);
    og.AddObject(objna,"CloseProfitablePipsTitle","    Close By Pips Profit : ",obj_edit,px-posx,py-posy,true,false,NULL);
    //input
    objna=SystemTag+"_Close_Profitable_Pips_Value";
    HS_Create_Edit(ChartID(),0,objna,size_x/10,row_height,px+size_x/4,py,"Arial",i_font_size,CLR_Edit_Back,CLR_Edit_Border,BRD_Edit_Type,CLR_Edit_Text,ALIGN_CENTER,"0",false,false,false);
    og.AddObject(objna,"CloseProfitablePipsValue","",obj_edit,px+size_x/4-posx,py-posy,true,false,NULL);
    OG>"CloseProfitablePipsValue">IntegerToString(last_pips_profit_value);
    //btn
    objna=SystemTag+"_Close_Profitable_Pips_Btn";
    HS_Create_Btn(ChartID(),0,objna,size_x/10,row_height,px+size_x/4+size_x/10,py,"Arial",i_font_size,CLR_Profit_Btn_Back,CLR_Profit_Btn_Border,BRD_Profit_Btn_Type,CLR_Profit_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseProfitablePipsBtn","Close",obj_button,px+size_x/4+size_x/10-posx,py-posy,true,true,"CLOSE PROFITABLE PIPS");
    
  int bx=px+size_x/4+size_x/5+size_x/10;
  //close losing
    objna=SystemTag+"_Close_Losing_Pips_Label";
    HS_Create_Edit(ChartID(),0,objna,size_x/4,row_height,bx,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"Close By Pips Profit",false,true,false);
    og.AddObject(objna,"CloseLosingPipsTitle","    Close By Pips Loss : ",obj_edit,bx-posx,py-posy,true,false,NULL);
    //input
    objna=SystemTag+"_Close_Losing_Pips_Value";
    HS_Create_Edit(ChartID(),0,objna,size_x/10,row_height,bx+size_x/4,py,"Arial",i_font_size,CLR_Edit_Back,CLR_Edit_Border,BRD_Edit_Type,CLR_Edit_Text,ALIGN_CENTER,"0",false,false,false);
    og.AddObject(objna,"CloseLosingPipsValue","",obj_edit,bx+size_x/4-posx,py-posy,true,false,NULL);
    OG>"CloseLosingPipsValue">IntegerToString(last_pips_loss_value);
    //btn
    if(!break_symmetry){
    objna=SystemTag+"_Close_Losing_Pips_Btn";
    HS_Create_Btn(ChartID(),0,objna,size_x/10,row_height,bx+size_x/4+size_x/10,py,"Arial",i_font_size,CLR_Loss_Btn_Back,CLR_Loss_Btn_Border,BRD_Loss_Btn_Type,CLR_Loss_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseLosingPipsBtn","Close",obj_button,bx+size_x/4+size_x/10-posx,py-posy,true,true,"CLOSE LOSING PIPS");}
    if(break_symmetry){
    ax=px+size_x-(int)columns[c];
    objna=SystemTag+"_Close_Losing_Pips_Btn";
    HS_Create_Btn(ChartID(),0,objna,(int)columns[c]-btn_x_reduce,row_height,ax+btn_x_reduce_half,py,"Arial",i_font_size,CLR_Loss_Btn_Back,CLR_Loss_Btn_Border,BRD_Loss_Btn_Type,CLR_Loss_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseLosingPipsBtn","Close",obj_button,ax+btn_x_reduce_half-posx,py-posy,true,true,"CLOSE LOSING PIPS");}    
         
    py+=row_height;
  }
  //close by pips ends here
  //close by amount
  if(close_by_amount){
  //close profitable 
    objna=SystemTag+"_Close_Profitable_Amount_Label";
    HS_Create_Edit(ChartID(),0,objna,size_x/4,row_height,px,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"Close By Amount Profit",false,true,false);
    og.AddObject(objna,"CloseProfitableAmountTitle","    Close By Amount Profit : ",obj_edit,px-posx,py-posy,true,false,NULL);
    //input
    objna=SystemTag+"_Close_Profitable_Amount_Value";
    HS_Create_Edit(ChartID(),0,objna,size_x/10,row_height,px+size_x/4,py,"Arial",i_font_size,CLR_Edit_Back,CLR_Edit_Border,BRD_Edit_Type,CLR_Edit_Text,ALIGN_CENTER,"0",false,false,false);
    og.AddObject(objna,"CloseProfitableAmountValue","",obj_edit,px+size_x/4-posx,py-posy,true,false,NULL);
    OG>"CloseProfitableAmountValue">DoubleToString(last_amount_profit_value,2)+currency;
    //btn
    objna=SystemTag+"_Close_Profitable_Amount_Btn";
    HS_Create_Btn(ChartID(),0,objna,size_x/10,row_height,px+size_x/4+size_x/10,py,"Arial",i_font_size,CLR_Profit_Btn_Back,CLR_Profit_Btn_Border,BRD_Profit_Btn_Type,CLR_Profit_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseProfitableAmountBtn","Close",obj_button,px+size_x/4+size_x/10-posx,py-posy,true,true,"CLOSE PROFITABLE AMOUNT");
    
  int bx=px+size_x/4+size_x/5+size_x/10;
  //close losing
    objna=SystemTag+"_Close_Losing_Amount_Label";
    HS_Create_Edit(ChartID(),0,objna,size_x/4,row_height,bx,py,"Arial",i_font_size,CLR_Back,CLR_Border,BRD_Type,CLR_Text,ALIGN_LEFT,"Close By Amount Loss",false,true,false);
    og.AddObject(objna,"CloseLosingAmountTitle","    Close By Amount Loss : ",obj_edit,bx-posx,py-posy,true,false,NULL);
    //input
    objna=SystemTag+"_Close_Losing_Amount_Value";
    HS_Create_Edit(ChartID(),0,objna,size_x/10,row_height,bx+size_x/4,py,"Arial",i_font_size,CLR_Edit_Back,CLR_Edit_Border,BRD_Edit_Type,CLR_Edit_Text,ALIGN_CENTER,"0",false,false,false);
    og.AddObject(objna,"CloseLosingAmountValue","",obj_edit,bx+size_x/4-posx,py-posy,true,false,NULL);
    OG>"CloseLosingAmountValue">DoubleToString(last_amount_loss_value,2)+currency;
    //btn
    if(!break_symmetry){
    objna=SystemTag+"_Close_Losing_Amount_Btn";
    HS_Create_Btn(ChartID(),0,objna,size_x/10,row_height,bx+size_x/4+size_x/10,py,"Arial",i_font_size,CLR_Loss_Btn_Back,CLR_Loss_Btn_Border,BRD_Loss_Btn_Type,CLR_Loss_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseLosingAmountBtn","Close",obj_button,bx+size_x/4+size_x/10-posx,py-posy,true,true,"CLOSE LOSING AMOUNT");}
    if(break_symmetry){
    ax=px+size_x-(int)columns[c];
    objna=SystemTag+"_Close_Losing_Amount_Btn";
    HS_Create_Btn(ChartID(),0,objna,(int)columns[c]-btn_x_reduce,row_height,ax+btn_x_reduce_half,py,"Arial",i_font_size,CLR_Loss_Btn_Back,CLR_Loss_Btn_Border,BRD_Loss_Btn_Type,CLR_Loss_Btn_Text,ALIGN_CENTER,"",false,false);
    og.AddObject(objna,"CloseLosingAmountBtn","Close",obj_button,ax+btn_x_reduce_half-posx,py-posy,true,true,"CLOSE LOSING AMOUNT");}
         
    py+=row_height;
  }
  //close by amount ends here  

   }
  //close nonprofitable 
  }
  //if not minimized ends here
og.Relocate(posx,posy,true);
UpdateDeck(is_minimized,ss);
} 
//+------------------------------------------------------------------+
void UpdateDeck(bool &is_minimized,symbol_stats &ss)
{
OG>"HeaderTitle">SystemHeader;
OG>"MinimizeBtn">"0";
bool any_risk_in_total=false;
double money_risk_total=0,risk_total=0,pl_total=0,lots_total=0,risk_pl_total=0;
int live_total=0,pending_total=0;
//if any items exist 
if(ss.list_total>0){
   for(int r=0;r<ss.list_total;r++)
   {
   //pair 
     if(!is_minimized){OG>column_titles[0]+"_"+IntegerToString(r)>ss.list[r].symbol;}
   //money
     bool enbolden=false;color rcolor=CLR_Risk_UNL;
     string amo_="Full Balance";
     if(ss.list[r].any_risk)
     {
     any_risk_in_total=true;
     money_risk_total+=ss.list[r].money_max_loss;
     amo_=DoubleToString(ss.list[r].money_max_loss,2)+currency;
     rcolor=CLR_Risk_Normal;
     if(ss.list[r].money_max_loss<=0){rcolor=CLR_Risk_Neg;}
     }
     if(!is_minimized){
     OG>column_titles[1]+"_"+IntegerToString(r)>amo_;
     OG>column_titles[1]+"_"+IntegerToString(r)<rcolor;
     if(!enbolden){OG>column_titles[1]+"_"+IntegerToString(r)<false;}
     if(enbolden){OG>column_titles[1]+"_"+IntegerToString(r)<true;}}
   //risk %
     enbolden=false;rcolor=CLR_Risk_UNL;
     amo_="Unlimited Risk";
     if(ss.list[r].any_risk)
     {
     risk_total+=ss.list[r].risk_max_loss;
     amo_=DoubleToString(ss.list[r].risk_max_loss,2)+"%";
     rcolor=CLR_Risk_Normal;
     if(ss.list[r].risk_max_loss<=0){rcolor=CLR_Risk_Neg;}
     if(ss.list[r].risk_max_loss>=instrument_max_risk){rcolor=CLR_Risk_Max;enbolden=true;}
     }
     if(!is_minimized){
     OG>column_titles[2]+"_"+IntegerToString(r)>amo_;
     OG>column_titles[2]+"_"+IntegerToString(r)<rcolor;
     if(!enbolden){OG>column_titles[2]+"_"+IntegerToString(r)<false;}
     if(enbolden){OG>column_titles[2]+"_"+IntegerToString(r)<true;}}
   //lots
     amo_=DoubleToString(ss.list[r].lots,2);
     lots_total+=ss.list[r].lots;
     if(!is_minimized){OG>column_titles[3]+"_"+IntegerToString(r)>amo_;}
   //pl
     amo_=DoubleToString(ss.list[r].money_pl,2)+currency+" ("+DoubleToString(ss.list[r].risk_pl,2)+"%)";
     pl_total+=ss.list[r].money_pl;
     risk_pl_total+=ss.list[r].risk_pl;
     if(!is_minimized){
     OG>column_titles[4]+"_"+IntegerToString(r)>amo_;
     if(ss.list[r].money_pl>=0){OG>column_titles[4]+"_"+IntegerToString(r)<CLR_PL_Profit;}
     if(ss.list[r].money_pl<0){OG>column_titles[4]+"_"+IntegerToString(r)<CLR_PL_Loss;}} 
   //live
     amo_="Close "+IntegerToString(ss.list[r].live_orders);
     live_total+=ss.list[r].live_orders;
     if(!is_minimized){
     OG>column_titles[5]+"_"+IntegerToString(r)>amo_;
     if(ss.list[r].live_orders==0){OG>column_titles[5]+"_"+IntegerToString(r)=false;}
     if(ss.list[r].live_orders>0){OG>column_titles[5]+"_"+IntegerToString(r)=true;}}
   //pending 
     amo_="Delete "+IntegerToString(ss.list[r].pending_orders);
     pending_total+=ss.list[r].pending_orders;
     if(!is_minimized){
     OG>column_titles[6]+"_"+IntegerToString(r)>amo_;
     if(ss.list[r].pending_orders==0){OG>column_titles[6]+"_"+IntegerToString(r)=false;}
     if(ss.list[r].pending_orders>0){OG>column_titles[6]+"_"+IntegerToString(r)=true;}}
   }
}
//if any items exist ends here
//totals 
  bool display_totals=false;
  if(!is_minimized||(is_minimized&&show_stats_on_minimize)){display_totals=true;}
  if(!is_minimized){OG>column_titles[0]+"_Total">"TOTAL";}
     bool enbolden=false;color rcolor=CLR_Risk_UNL;
     string amo_="Full Balance";
     rcolor=CLR_Risk_Normal;
     if(any_risk_in_total)
     {
     amo_=DoubleToString(money_risk_total,2)+currency;
     if(money_risk_total<=0){rcolor=CLR_Risk_Neg;}
     }
     if(ss.list_total==0){amo_=DoubleToString(AccountBalance(),2)+currency;}
     if(display_totals){
     OG>column_titles[1]+"_Total">amo_;
     OG>column_titles[1]+"_Total"<rcolor;
     if(!enbolden){OG>column_titles[1]+"_Total"<false;}
     if(enbolden){OG>column_titles[1]+"_Total"<true;}}
   //risk %
     enbolden=false;rcolor=CLR_Risk_UNL;
     amo_="Unlimited Risk";
     rcolor=CLR_Risk_Normal;
     if(any_risk_in_total)
     {
     amo_=DoubleToString(risk_total,2)+"%";
     if(risk_total<=0){rcolor=CLR_Risk_Neg;}
     }
     if(ss.list_total==0){amo_="0%";}
     if(display_totals){
     OG>column_titles[2]+"_Total">amo_;
     OG>column_titles[2]+"_Total"<rcolor;
     if(!enbolden){OG>column_titles[2]+"_Total"<false;}
     if(enbolden){OG>column_titles[2]+"_Total"<true;}}
   //lots
     amo_=DoubleToString(lots_total,2);
     if(display_totals){OG>column_titles[3]+"_Total">amo_;}
   //pl
     amo_=DoubleToString(pl_total,2)+currency+" ("+DoubleToString(risk_pl_total,2)+"%)";
     if(display_totals){
     OG>column_titles[4]+"_Total">amo_;
     if(pl_total>=0){OG>column_titles[4]+"_Total"<CLR_PL_Profit;}
     if(pl_total<0){OG>column_titles[4]+"_Total"<CLR_PL_Loss;}}
 
   //live
     amo_="Close All("+IntegerToString(live_total)+")";
     if(!is_minimized){
     OG>column_titles[5]+"_Total">amo_;
     if(live_total==0){OG>column_titles[5]+"_Total"=false;}
     if(live_total>0){OG>column_titles[5]+"_Total"=true;}}
   //pending 
     amo_="Delete All("+IntegerToString(pending_total)+")";
     if(!is_minimized){
     OG>column_titles[6]+"_Total">amo_;
     if(pending_total==0){OG>column_titles[6]+"_Total"=false;}
     if(pending_total>0){OG>column_titles[6]+"_Total"=true;}}  

if(is_minimized){OG>"MinimizeBtn">"6";}
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
*/