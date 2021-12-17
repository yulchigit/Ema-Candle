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

input double     MaximumRisk        =0.01;
input double     DecreaseFactor     =2;
input int        MovingPeriod1      =50;
input int        MovingPeriod2      =200;
input int        MovingShift        =1;
input int        Slippage           =30;
input double     Lot                =0.01;
input bool       TrailingStop       =true;

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
   Comment("Signal: ",IntegerToString(SignaL()));
   if(SignaL()<0)
      return;
   if(OrdersTotal()==0)
     {
      if(SignaL()==OP_BUYSTOP)
        {
         OrderSend(Symbol(),SignaL(),Lot,iHigh(Symbol(),Period(),1),Slippage,0,0,"Buy",MAGICMA,0,clrBlue);
        }
      if(SignaL()==OP_SELLSTOP)
        {
         OrderSend(Symbol(),SignaL(),Lot,iLow(Symbol(),Period(),1),Slippage,0,0,"Sell",MAGICMA,0,clrRed);
        }
     }
   CloseOrder();
  }
//+------------------------------------------------------------------+
int SignaL()
  {
   ma1=iMA(Symbol(),Period(),MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,1);
   if(ma1<iClose(Symbol(),Period(),2))
      if((iHigh(Symbol(),Period(),2)<iHigh(Symbol(),Period(),1)) && (iLow(Symbol(),Period(),2)<iLow(Symbol(),Period(),1)))
         return(OP_BUYSTOP);
   if(ma1>iClose(Symbol(),Period(),2))
      if((iLow(Symbol(),Period(),2)>iLow(Symbol(),Period(),1)) && (iHigh(Symbol(),Period(),2)>iHigh(Symbol(),Period(),1)))
         return(OP_SELLSTOP);

   return(EMPTY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrder()
  {


   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
           {

            if(OrderType()==OP_BUY || OrderType()==OP_BUYSTOP)
               if(SignaL()==OP_SELLSTOP || ((iLow(Symbol(),Period(),2)>iLow(Symbol(),Period(),1)) &&
                                            (iHigh(Symbol(),Period(),2)>iHigh(Symbol(),Period(),1)))
                  || ma1>iClose(Symbol(),Period(),1)
                  || buyclose()==9)
                  if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,clrBlack))
                     Print("OrderDelete error ",GetLastError());
            if(OrderType()==OP_SELL || OrderType()==OP_SELLSTOP)
               if(SignaL()==OP_BUYSTOP || ((iHigh(Symbol(),Period(),2)<iHigh(Symbol(),Period(),1)) &&
                                           (iLow(Symbol(),Period(),2)<iLow(Symbol(),Period(),1)))
                  || ma1<iClose(Symbol(),Period(),2)
                  || sellclose()==9)
                  if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,clrBlack))
                     Print("OrderDelete error ",GetLastError());

            return;


           }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int buyclose()
  {
   int Buyclose;
   if(iLow(Symbol(),Period(),2)>iLow(Symbol(),Period(),1))
      Buyclose=9;
   return Buyclose ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int sellclose()
  {
   int Sellclose;
   if(iHigh(Symbol(),Period(),2)<iHigh(Symbol(),Period(),1))
      Sellclose=9;
   return Sellclose;
  }
//+------------------------------------------------------------------+
