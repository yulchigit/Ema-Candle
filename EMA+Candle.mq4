//+------------------------------------------------------------------+
//|                                                   EMA+Candle.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define MAGICMA   20131111
#include <Object.mqh>

//input double     MaximumRisk        =0.01;
//input double     DecreaseFactor     =2;
input int        MovingPeriod1      =50;
input int        MovingShift        =1;
input int        Slippage           =30;
input double     Lot                =0.01;
input int        SellBuyStop        =25;
//input int        TP                 =200;
//input bool       TrailingStop       =true;

double Trailingqadam;
double lot;
double ma1; //
double ma2; //
double Sl,Tp1,Tp2;
double macd,oldmacd;
int a,res1,res2;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
ma1=iMA(Symbol(),Period(),MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,1);
if(!IsDemo()){ Comment(" Real hisobda savdoda ruxsat berilmagan "); } 
if(IsDemo()){ Comment(" ___Savdo maslahatchisi ishni boshladi___ "); }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   Comment("Signal: ",IntegerToString(SignaL())," Selclose :",sellclose(),"  Buyclose :",buyclose()," MA : ",NormalizeDouble(ma1,Digits));
   if(SignaL()<0)SignaL();//buyclose();sellclose();
   if( buyclose() || sellclose() ) CloseOrder();
   //if(OrdersTotal()>0) CloseOrder();
   if(!IsDemo()){ Comment(" Real hisobda savdoda ruxsat berilmagan "); }                    
   if(OrdersTotal()<1 && IsDemo())
     {
      if(SignaL()==OP_BUYSTOP)
        {
        CloseOrder();
         OrderSend(Symbol(),SignaL(),Lot,iHigh(Symbol(),Period(),1)+SellBuyStop*Point,Slippage,0,0,"Buy",MAGICMA,0,clrBlue);
        }
      if(SignaL()==OP_SELLSTOP)
        {
        CloseOrder();
         OrderSend(Symbol(),SignaL(),Lot,iLow(Symbol(),Period(),1)-SellBuyStop*Point,Slippage,0,0,"Sell",MAGICMA,0,clrRed);
        }
     }

  }
//+------------------------------------------------------------------+
int SignaL()
  {
 
  
 ma1=iMA(Symbol(),Period(),MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,1);
   if(ma1<iClose(Symbol(),Period(),2))
      if((iHigh(Symbol(),Period(),2)<iHigh(Symbol(),Period(),1)) && 
         (iLow(Symbol(),Period(),2)<iLow(Symbol(),Period(),1))   &&
         (iOpen(_Symbol,_Period,2)<iClose(_Symbol,_Period,2))    &&
         (iOpen(_Symbol,_Period,1)<iClose(_Symbol,_Period,1))    
                                                                    )
         return(OP_BUYSTOP);
   if(ma1>iClose(Symbol(),Period(),2))
      if((iLow(Symbol(),Period(),2)>iLow(Symbol(),Period(),1)) && 
         (iHigh(Symbol(),Period(),2)>iHigh(Symbol(),Period(),1)) &&
         (iOpen(_Symbol,_Period,2)>iClose(_Symbol,_Period,2))    &&
         (iOpen(_Symbol,_Period,1)>iClose(_Symbol,_Period,1))    
                                                                     )
         return(OP_SELLSTOP);

   return(EMPTY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrder()
  {

    for(int i=OrdersTotal()-1; i>=0; i--)
    //for(int i=0; i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
           {

            if(OrderType()==OP_BUY )
               if(SignaL()==OP_SELLSTOP || buyclose()==true)
                  if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,clrBlack))
                     Print("OrderDelete error ",GetLastError());
            if(OrderType()==OP_BUYSTOP )
               if(SignaL()==OP_SELLSTOP || buyclose()==true)
                  if(!OrderDelete(OrderTicket(),clrRed))
                     Print("OrderDelete error ",GetLastError());
            if(OrderType()==OP_SELL )
               if(SignaL()==OP_BUYSTOP  || sellclose()==true)
                  //if(OrderDelete(OrderTicket(),clrRed))return;
                  if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,clrBlack))
                     Print("OrderDelete error ",GetLastError());
            if(OrderType()==OP_SELLSTOP )
               if(SignaL()==OP_BUYSTOP  || sellclose()==true)
                  //if(OrderDelete(OrderTicket(),clrRed)) return;
                  if(!OrderDelete(OrderTicket(),clrRed))
                     Print("OrderDelete error ",GetLastError());

            //return;


           }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool buyclose()
  {
  ma1=iMA(Symbol(),Period(),MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,1);
   bool Buyclose=false;
   if(((iLow(Symbol(),Period(),2)>iLow(Symbol(),Period(),1)) &&
       (iClose(_Symbol,_Period,2)>iClose(_Symbol,_Period,1)) &&
       (iOpen(_Symbol,_Period,2)>iClose(_Symbol,_Period,2))) ||
       ma1>iClose(_Symbol,_Period,1)
   
                                                            )
      Buyclose=true;
   return Buyclose ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sellclose()
  {
  ma1=iMA(Symbol(),Period(),MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,1);
   bool Sellclose=false;
   if(((iHigh(Symbol(),Period(),2)<iHigh(Symbol(),Period(),1)) && 
       (iClose(_Symbol,_Period,2)<iClose(_Symbol,_Period,1))   &&
       (iOpen(_Symbol,_Period,2)<iClose(_Symbol,_Period,2)))   ||
       ma1<iClose(_Symbol,_Period,1) 
                                                                 )
      Sellclose=true;
   return Sellclose;
  }
//+------------------------------------------------------------------+
