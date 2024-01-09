//###################################################################################################################################################
//CABEÇALHO ############################################################################################################################################
//###################################################################################################################################################

#property copyright "Paulo Enrique"
#property link      "WhatsApp - (11)98979-4039"
#property version   "1.09"

//INCLUDE E RESOURCE ############################################################################################################################################

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <GenericIncludesMQL5\GenericEnums.mqh>

//VARIÁVEIS DE INCLUDES ############################################################################################################################################
CTrade          TradeGenericFunctions;
CSymbolInfo     SymbolInfoGenericFunctions;

//COMPRAR A MERCADO ##############################################################################################################################################
bool buyMarket(ulong magicNumber, string symbol, double volume, double take, double stop, string comment) {
    SymbolInfoGenericFunctions.Refresh();
    SymbolInfoGenericFunctions.RefreshRates();
    
    TradeGenericFunctions.SetExpertMagicNumber(magicNumber);

    double st = stop == 0 ? 0 : SymbolInfoGenericFunctions.Ask() - (stop * SymbolInfoGenericFunctions.Point());
    double tk = take == 0 ? 0 : SymbolInfoGenericFunctions.Ask() + (take * SymbolInfoGenericFunctions.Point());

    TradeGenericFunctions.Buy(
        volume, 
        symbol, 
        SymbolInfoGenericFunctions.Ask(), 
        SymbolInfoGenericFunctions.NormalizePrice(st), 
        SymbolInfoGenericFunctions.NormalizePrice(tk), 
        comment
    );

    if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE) {
        Print("ERRO AO EXECUTAR COMPRA A MERCADO CÓDIGO DE ERRO: ", TradeGenericFunctions.ResultRetcode());
        Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
        return false;
    } else {
        Print("ORDEM DE COMPRA A MERCADO EXECUTADA / COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
        return true;
    }

    return false;
}

//VENDER A MERCADO ##############################################################################################################################################
bool sellMarket(ulong magicNumber, string symbol, double volume, double take, double stop, string comment) {
    SymbolInfoGenericFunctions.Refresh();
    SymbolInfoGenericFunctions.RefreshRates();
    
    TradeGenericFunctions.SetExpertMagicNumber(magicNumber);

    double st = stop == 0 ? 0 : SymbolInfoGenericFunctions.Bid() + (stop * SymbolInfoGenericFunctions.Point());
    double tk = take == 0 ? 0 : SymbolInfoGenericFunctions.Bid() - (take * SymbolInfoGenericFunctions.Point());    

    TradeGenericFunctions.Sell(
        volume, 
        symbol, 
        SymbolInfoGenericFunctions.Bid(), 
        SymbolInfoGenericFunctions.NormalizePrice(st), 
        SymbolInfoGenericFunctions.NormalizePrice(tk), 
        comment
    );

    if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE) {
        Print("ERRO AO EXECUTAR VENDA A MERCADO CÓDIGO DE ERRO: ", TradeGenericFunctions.ResultRetcode());
        Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
        return false;
    } else {
        Print("ORDEM DE VENDA A MERCADO EXECUTADA / COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
        return true;
    }

    return false;
}

//FECHAR TODAS AS POSIÇÕES ##############################################################################################################################################
bool closeAllPositions(string symbol, ulong magicNumber) {
    for (int i = PositionsTotal() - 1 ; i >= 0; i--) {
        if (!PositionSelectByTicket(PositionGetTicket(i))) {
            closeAllPositions(symbol, magicNumber);
            return false;
        }

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionTicket       = PositionGetInteger(POSITION_TICKET);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
            TradeGenericFunctions.PositionClose(positionTicket);

            if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE) {
                Print("PROBLEMAS PARA FECHAR A POSIÇÃO COM TICKET: ", positionTicket);
                Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
                closeAllPositions(symbol, magicNumber);
                return false;
            }
        }
    }

    return true;
}

//FECHAR TODAS AS ORDENS PENDENTES ##############################################################################################################################################
bool closeAllPendingOrders(string symbol, ulong magicNumber, ENUM_OPERATIONS_TYPE type) {
    for (int i = OrdersTotal() - 1 ; i >= 0; i--) {
        if (!OrderSelect(OrderGetTicket(i))) {
            return false;
        }

        string   orderSymbol       = OrderGetString(ORDER_SYMBOL);
        ulong    orderMagicNumber  = OrderGetInteger(ORDER_MAGIC);
        ulong    orderTicket       = OrderGetInteger(ORDER_TICKET);
        ulong    orderType         = OrderGetInteger(ORDER_TYPE);

        if (orderMagicNumber == magicNumber && orderSymbol == symbol) {
            if (type == all) {
               TradeGenericFunctions.OrderDelete(orderTicket);
            }
            
            if (type == sell && (orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP)) {
               TradeGenericFunctions.OrderDelete(orderTicket);
            }
            
            if (type == buy && (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP)) {
               TradeGenericFunctions.OrderDelete(orderTicket);
            }

            if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE) {
                Print("PROBLEMAS PARA FECHAR A ORDEM COM TICKET: ", orderTicket);
                Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
                return false;
            }
        }
    }

    return true;
}

//VERIRICA A QUANTIDADE DE POSIÇOES ##############################################################################################################################################
int getTotalPositions(string symbol, ulong magicNumber, ENUM_POSITION_TYPE type) {
    int positionsTotal = 0; 

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
            if (type == positionType) {
                positionsTotal++;
            }
        }
    }

    return positionsTotal;
}

//VERIRICA O VOLUME TOTAL DAS POSIÇÕES ##############################################################################################################################################
double getVolumeTotalPositions(string symbol, ulong magicNumber, ENUM_POSITION_TYPE type) {
    double positionsVolumeTotal = 0; 

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionVolume       = PositionGetDouble(POSITION_VOLUME);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
            if (type == positionType) {
                positionsVolumeTotal += positionVolume;
            }
        }
    }

    return positionsVolumeTotal;
}

//VERIRICA O LUCRO TOTAL DAS POSIÇÕES ##############################################################################################################################################
double getProfitAllPositions(string symbol, ulong magicNumber, ENUM_POSITION_TYPE type) {
    double positionsProfitTotal = 0; 

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionProfit       = PositionGetDouble(POSITION_PROFIT);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
            if (type == positionType) {
                positionsProfitTotal += positionProfit;
            }
        }
    }

    return positionsProfitTotal;
}

//VERIRICAR SE TEM ALGUMA POSIÇÃO ABERTA ##############################################################################################################################################
bool isPositioned(string symbol, ulong magicNumber, ENUM_POSITION_TYPE type) {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        if (!PositionSelectByTicket(PositionGetTicket(i))) {
            return false;
        }

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
            if (type == positionType) {
                return true;
            }
        }
    }

    return false;
}

//VERIRICAR SE TEM ALGUMA POSIÇÃO ABERTA ##############################################################################################################################################
bool isPendingOrder(string symbol, ulong magicNumber, ENUM_OPERATIONS_TYPE type) {
    StringToUpper(symbol);
    
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (!OrderSelect(OrderGetTicket(i))) {
            return false;
        }

        string   orderSymbol       = OrderGetString(ORDER_SYMBOL);
        ulong    orderMagicNumber  = OrderGetInteger(ORDER_MAGIC);
        ulong    orderType         = OrderGetInteger(ORDER_TYPE);

        if (orderMagicNumber == magicNumber && orderSymbol == symbol) {
            if (type == all) {
               return true;
            }
            
            if (type == buy && (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP)) {
               return true;
            }
            
            if (type == sell && (orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP)) {
               return true;
            }
        }
    }

    return false;
}

//VALIDAÇOES DE CONTA DEMO ##############################################################################################################################################
bool isOnTime(string date) {
//BLOQUEIO DE 7 DIAS PARA TESTE    
    if ((TimeCurrent() > StringToTime(date))) {
        Alert("PERÍODO DE TESTES ENCERRADO");
        return false;
    }

//BLOQUEIO DE CONTA DEMO
    if (AccountInfoInteger(ACCOUNT_TRADE_MODE) != ACCOUNT_TRADE_MODE_DEMO) {
        Alert("O ROBÔ NÃO PERMITE OPERAR EM CONTAS REAIS");
        return false;
    }

    return true; 
}

//INFORMAÇÕES DA CONTA ##############################################################################################################################################
bool getAccountData() {
    //COLETA O NOME DO CLIENTE
    string nome = AccountInfoString(ACCOUNT_NAME);
    Print("NOME DO CLIENTE: ", nome);

    //COLETA O NÚMERO DA CONTA DO CLIENTE
    long login = AccountInfoInteger(ACCOUNT_LOGIN);
    Print("NÚMERO DA CONTA: ", login);

    //COLETA O NOME DA CORRETORA QUE O CLIENTE ESTÁ USANDO
    string corretora = AccountInfoString(ACCOUNT_COMPANY);
    Print("CORRETORA: ", corretora);

    return true;
}

//VERIFICA SE OS LIMITES DE GANHOS OU DE PERDAS FORAM ALCANÇADOS ##############################################################################################################################################
bool isProfitLimit(string symbol, ulong magicNumber, double gainLimit, double lossLimit){
    SymbolInfoGenericFunctions.Refresh();
    SymbolInfoGenericFunctions.RefreshRates();

    double positionsProfit = getProfitAllPositions(symbol, magicNumber, POSITION_TYPE_BUY) + getProfitAllPositions(symbol, magicNumber, POSITION_TYPE_SELL);
    double historicProfit = getProfitHistoric(symbol, magicNumber, PERIOD_D1, false);
    double profitTotal = positionsProfit + historicProfit;
    bool   isNewDay = positionsProfit == 0 && historicProfit == 0;
    static bool isPause = false;
    
    if (isNewDay) {
      isPause = false;
    }
    
    if (isPause) {
      closeAllPositions(symbol, magicNumber);
      return true;
    }

    if (gainLimit <= profitTotal && gainLimit > 0) {
        closeAllPositions(symbol, magicNumber);
        Print("ORDENS FECHADAS APÓS ATINGIR O LUCRO DE: ", gainLimit, " LUCRO ATUAL: ", profitTotal);
        isPause = true;
        return true;
    }

    if ((lossLimit * -1) >= profitTotal && lossLimit > 0) {
        closeAllPositions(symbol, magicNumber);
        Print("ORDENS FECHADAS APÓS ATINGIR A PERDA DE: ", lossLimit, " PERDA ATUAL: ", profitTotal);
        isPause = true;
        return true;
    }

    return false;
}

//RETORNA O TOTAL DE LUCRO ##############################################################################################################################################
double getProfitHistoric(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe, bool isTotalProfit = false) {
    int candle = isTotalProfit ? iBars(symbol,timeframe) : 0;
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, timeframe, candle);

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();
    double dealProfitTotal = 0;

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            long     dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            double   dealProfit        = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber) { 
                dealProfitTotal += dealProfit;
            }
        }
    }

    return dealProfitTotal;
}

//NÚMERO DE GAINS ##############################################################################################################################################
int getGainsHistoric(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe, bool isTotalProfit = false) {
    int candle = isTotalProfit ? iBars(symbol,timeframe) : 0;
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, timeframe, candle);

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();
    int dealGainsTotal = 0;

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            long     dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            double   dealProfit        = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber && dealProfit > 0) { 
                dealGainsTotal++;
            }
        }
    }

    return dealGainsTotal;
}

//NÚMERO DE LOSS ##############################################################################################################################################
int getLossHistoric(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe, bool isTotalProfit = false) {
    int candle = isTotalProfit ? iBars(symbol,timeframe) : 0;
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, timeframe, candle);

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();
    int dealLossTotal = 0;

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            long     dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            double   dealProfit        = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber && dealProfit < 0) { 
                dealLossTotal++;
            }
        }
    }

    return dealLossTotal;
}

//CONSULTA O HORÁRIO DE FECHAMENTO ##############################################################################################################################################
bool isClosingTime(string close){ 
    MqlDateTime currentTime, closeTime;

    TimeToStruct(TimeCurrent(), currentTime); 
    TimeToStruct(StringToTime(close), closeTime);

    if (currentTime.hour * 60 + currentTime.min > closeTime.hour * 60 + closeTime.min) {
        return true;
    }

    return false;
}

//CONSULTA O HORÁRIO DE PAUSA ##############################################################################################################################################
bool isPauseTime(string pause, string free) {    
    MqlDateTime currentTime, pauseTime, freeTime;

    TimeToStruct(TimeCurrent(), currentTime); 
    TimeToStruct(StringToTime(pause), pauseTime);
    TimeToStruct(StringToTime(free), freeTime);

    if (currentTime.hour * 60 + currentTime.min > pauseTime.hour * 60 + pauseTime.min &&
        currentTime.hour * 60 + currentTime.min < freeTime.hour * 60 + freeTime.min) {
            return true;
    }

    return false;
}


//CONSULTA O HORÁRIO DE ABERTURA ##############################################################################################################################################
bool isOpenningTime(string open) {
    MqlDateTime currentTime, openTime;

    TimeToStruct(TimeCurrent(), currentTime); 
    TimeToStruct(StringToTime(open), openTime);

    if (currentTime.hour * 60 + currentTime.min < openTime.hour * 60 + openTime.min) {
        return false;
    }

    return true;
}

//VERIFICA SE ABRIU UM NOVO CANDLE ##############################################################################################################################################
bool isNewCandle(string symbol, ENUM_TIMEFRAMES timeframe) {
    static int bars;

    if (bars != Bars(symbol, timeframe) && bars > 0) {
        bars = Bars(symbol, timeframe);
        return true;
    }
    
    if (bars == 0) {
      bars = Bars(symbol, timeframe);
    }

    return false;
}

//BUSCA O TICKET DA ULTIMA POSIÇÃO ABERTA ##############################################################################################################################################
ulong getTicketLastPositionOpen(string symbol, ulong magicNumber) {
    ulong positionTicketLastPosition = 0;
    datetime positionLastDatetime = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        datetime positionOpenTime     = (datetime) PositionGetInteger(POSITION_TIME);
        ulong    positionTicket       = PositionGetInteger(POSITION_TICKET);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
            if (positionOpenTime > positionLastDatetime) {
                positionLastDatetime = positionOpenTime;
                positionTicketLastPosition = positionTicket;    
            }
        }
    }

    return positionTicketLastPosition;
}

//BUSCA O PREÇO DE ABERTURA PELO TICKET DA POSIÇÃO ##############################################################################################################################################
double getPositionPriceOpenByTicket(string symbol, ulong magicNumber, ulong ticket) {
    if (!PositionSelect(symbol)) {return 0;}

    if (!PositionSelectByTicket(ticket)) {
        return 0;
    }

    string   positionSymbol       = PositionGetString(POSITION_SYMBOL);
    ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
    double   positionPriceOpen    = PositionGetDouble(POSITION_PRICE_OPEN);

    if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
        return positionPriceOpen;
    }

    return 0;
}

//BUSCA O SENTIDO PELO TICKET DA POSIÇÃO ##############################################################################################################################################
ENUM_POSITION_TYPE getPositionTypeByTicket(string symbol, ulong magicNumber, ulong ticket) {
    if (!PositionSelect(symbol)) {return NULL;}

    if (!PositionSelectByTicket(ticket)) {
        return NULL;
    }

    string   positionSymbol       = PositionGetString(POSITION_SYMBOL);
    ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
    ulong    positionType         = PositionGetInteger(POSITION_TYPE);

    if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
        return (ENUM_POSITION_TYPE) positionType;
    }

    return NULL;
}

//BUSCA O SENTIDO PELO TICKET DA POSIÇÃO ##############################################################################################################################################
double getPositionVolumeByTicket(string symbol, ulong magicNumber, ulong ticket) {
    if (!PositionSelect(symbol)) {return 0;}

    if (!PositionSelectByTicket(ticket)) {
        return 0;
    }

    string   positionSymbol       = PositionGetString(POSITION_SYMBOL);
    ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
    double   positionVolume       = PositionGetDouble(POSITION_VOLUME);

    if (positionMagicNumber == magicNumber && positionSymbol == symbol) {
        return positionVolume;
    }

    return 0;
}

//BUSCA O TIPO DA ULTIMA OPERAÇÃO ##############################################################################################################################################
ENUM_DEAL_TYPE getLastOrderType(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe) {
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, timeframe, iBars(symbol, timeframe));

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();
    datetime controlTime = iTime(symbol, timeframe, iBars(symbol, timeframe));
    ENUM_DEAL_TYPE dealLastType = NULL;

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            ulong    dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            double   dealProfit        = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            ulong    dealType          = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
            ulong    dealEntry         = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
            datetime dealTime          = (datetime) HistoryDealGetInteger(dealTicket, DEAL_TIME);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber) { 
                if (dealTime > controlTime && dealEntry == DEAL_ENTRY_IN) {
                    controlTime = dealTime;
                    dealLastType = (ENUM_DEAL_TYPE) dealType;
                }
            }
        }
    }

    return dealLastType;
}

//BUSCA O RESULTADO DA ULTIMA OPERACAO ##############################################################################################################################################
double getLastOrderResult(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe) {
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, timeframe, iBars(symbol, timeframe));

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();
    datetime controlTime = iTime(symbol, timeframe, iBars(symbol, timeframe));
    double result = 0;

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            ulong    dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            double   dealProfit        = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            ulong    dealType          = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
            ulong    dealEntry         = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
            datetime dealTime          = (datetime) HistoryDealGetInteger(dealTicket, DEAL_TIME);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber) {
                if (dealTime > controlTime && dealEntry == DEAL_ENTRY_OUT) {
                    controlTime = dealTime;
                    result = dealProfit;
                }
            }
        }
    }

    return result;
}

//BUSCA O TICKET DA ULTIMA POSIÇÃO DE COMPRA ABERTA ##############################################################################################################################################
ulong getTicketLastBuyPositionOpen(string symbol, ulong magicNumber) {
    ulong positionTicketLastPosition = 0;
    datetime positionLastDatetime = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        datetime positionOpenTime     = (datetime) PositionGetInteger(POSITION_TIME);
        ulong    positionTicket       = PositionGetInteger(POSITION_TICKET);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_BUY) {
            if (positionOpenTime > positionLastDatetime) {
                positionLastDatetime = positionOpenTime;
                positionTicketLastPosition = positionTicket;    
            }
        }
    }

    return positionTicketLastPosition;
}

//BUSCA O TICKET DA ULTIMA POSIÇÃO DE VENDA ABERTA ##############################################################################################################################################
ulong getTicketLastSellPositionOpen(string symbol, ulong magicNumber) {
    ulong positionTicketLastPosition = 0;
    datetime positionLastDatetime = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        datetime positionOpenTime     = (datetime) PositionGetInteger(POSITION_TIME);
        ulong    positionTicket       = PositionGetInteger(POSITION_TICKET);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_SELL) {
            if (positionOpenTime > positionLastDatetime) {
                positionLastDatetime = positionOpenTime;
                positionTicketLastPosition = positionTicket;    
            }
        }
    }

    return positionTicketLastPosition;
}

//RETORNA O VALOR DO DRAWDONW ##############################################################################################################################################
double getDrawdownValue(string symbol, ulong magicNumber) {
    static double profit;

    double positionsProfit = getProfitAllPositions(symbol, magicNumber, POSITION_TYPE_BUY) + getProfitAllPositions(symbol, magicNumber, POSITION_TYPE_SELL);

    if ((positionsProfit < 0 && profit == 0) || positionsProfit < profit) {
        profit = positionsProfit;
    }

    return profit;
}

//RETORNA O VALOR DO DRAWDONW DIARIO ##############################################################################################################################################
double getDailyDrawdownValue(string symbol, ulong magicNumber) {
    static double profit;
    static int bars;

    if (bars != Bars(symbol, PERIOD_D1) && bars > 0) {
        bars = Bars(symbol, PERIOD_D1);
        profit = 0;
    }
    
    if (bars == 0) {
      bars = Bars(symbol, PERIOD_D1);
    }

    double positionsProfit = getProfitAllPositions(symbol, magicNumber, POSITION_TYPE_BUY) + getProfitAllPositions(symbol, magicNumber, POSITION_TYPE_SELL);

    if ((positionsProfit < 0 && profit == 0) || positionsProfit < profit) {
        profit = positionsProfit;
    }

    return profit;
}

//BUSCA SE HOUVE OPERAÇÃO DE COMPRA NO DIA ##############################################################################################################################################
bool hadBuyOperationOnTheDay(string symbol, ulong magicNumber) {
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, PERIOD_D1, 0);

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            ulong    dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            ulong    dealType          = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
            ulong    dealEntry         = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber) { 
                if (dealType == DEAL_TYPE_BUY && dealEntry == DEAL_ENTRY_IN) {
                    return true;
                }
            }
        }
    }

    return false;
}

//BUSCA SE HOUVE OPERAÇÃO DE VENDA NO DIA ##############################################################################################################################################
bool hadSellOperationOnTheDay(string symbol, ulong magicNumber) {
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, PERIOD_D1, 0);

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            ulong    dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            ulong    dealType          = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
            ulong    dealEntry         = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber) { 
                if (dealType == DEAL_TYPE_SELL && dealEntry == DEAL_ENTRY_IN) {
                    return true;
                }
            }
        }
    }

    return false;
}

//BUSCA O PREÇO MÉDIO DE OPERAÇÕES COMPRADAS ##############################################################################################################################################
double getBuyPositionsAveragePrice(string symbol, ulong magicNumber) {
    double totalVolume = 0;
    double totalPrices = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionVolume       = PositionGetDouble(POSITION_VOLUME);
        double   positionPrice        = PositionGetDouble(POSITION_PRICE_OPEN);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_BUY) {
            totalVolume += positionVolume;
            totalPrices += (positionPrice * positionVolume);
        }
    }

    return totalPrices / totalVolume;
}

//BUSCA O PREÇO MÉDIO DE OPERAÇÕES VENDAS ##############################################################################################################################################
double getSellPositionsAveragePrice(string symbol, ulong magicNumber) {
    double totalVolume = 0;
    double totalPrices = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionVolume       = PositionGetDouble(POSITION_VOLUME);
        double   positionPrice        = PositionGetDouble(POSITION_PRICE_OPEN);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_SELL) {
            totalVolume += positionVolume;
            totalPrices += (positionPrice * positionVolume);
        }
    }

    return totalPrices / totalVolume;
}

//ALTERAR STOP DAS ORDENS COMPRADAS ##############################################################################################################################################
void changeStopBuyPositions(string symbol, ulong magicNumber, double averagePrice, double stop) {
    SymbolInfoGenericFunctions.Refresh();
    SymbolInfoGenericFunctions.RefreshRates();
    
    double st = SymbolInfoGenericFunctions.NormalizePrice(averagePrice - (stop * SymbolInfoGenericFunctions.Point()));

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionPriceOpen    = PositionGetDouble(POSITION_PRICE_OPEN);
        double   positionTake         = PositionGetDouble(POSITION_TP);
        double   positionStop         = PositionGetDouble(POSITION_SL);
        ulong    positionTicket       = PositionGetTicket(i);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_BUY) {
            if (positionStop != st && averagePrice != 0 && SymbolInfoGenericFunctions.Bid() >= st) {
               TradeGenericFunctions.PositionModify(positionTicket, st, positionTake);
            }
        }
    }
}

//ALTERAR STOP DAS ORDENS VENDIDAS ##############################################################################################################################################
void changeStopSellPositions(string symbol, ulong magicNumber, double averagePrice, double stop) {
    SymbolInfoGenericFunctions.Refresh();
    SymbolInfoGenericFunctions.RefreshRates();
    
    double st = SymbolInfoGenericFunctions.NormalizePrice(averagePrice + (stop * SymbolInfoGenericFunctions.Point()));

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionPriceOpen    = PositionGetDouble(POSITION_PRICE_OPEN);
        double   positionTake         = PositionGetDouble(POSITION_TP);
        double   positionStop         = PositionGetDouble(POSITION_SL);
        ulong    positionTicket       = PositionGetTicket(i);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_SELL) {
            if (positionStop != st && averagePrice != 0 && SymbolInfoGenericFunctions.Ask() <= st) {
               TradeGenericFunctions.PositionModify(positionTicket, st, positionTake);
            }
        }
    }
}

//ALTERAR TAKE DAS ORDENS COMPRADAS ##############################################################################################################################################
void changeTakeBuyPositions(string symbol, ulong magicNumber, double averagePrice, double take) {
    SymbolInfoGenericFunctions.Refresh();
    SymbolInfoGenericFunctions.RefreshRates();
    
    double tp = SymbolInfoGenericFunctions.NormalizePrice(averagePrice + (take * SymbolInfoGenericFunctions.Point()));

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionPriceOpen    = PositionGetDouble(POSITION_PRICE_OPEN);
        double   positionTake         = PositionGetDouble(POSITION_TP);
        double   positionStop         = PositionGetDouble(POSITION_SL);
        ulong    positionTicket       = PositionGetTicket(i);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_BUY) {
            if (positionTake != tp && averagePrice != 0 && SymbolInfoGenericFunctions.Bid() <= tp) {
               TradeGenericFunctions.PositionModify(positionTicket, positionStop, tp);
            }
        }
    }
}

//ALTERAR TAKE DAS ORDENS VENDIDAS ##############################################################################################################################################
void changeTakeSellPositions(string symbol, ulong magicNumber, double averagePrice, double take) {
    SymbolInfoGenericFunctions.Refresh();
    SymbolInfoGenericFunctions.RefreshRates();
    
    double tp = SymbolInfoGenericFunctions.NormalizePrice(averagePrice - (take * SymbolInfoGenericFunctions.Point()));

    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        PositionSelectByTicket(PositionGetTicket(i));

        string   positionSymbol       = PositionGetSymbol(i);
        ulong    positionMagicNumber  = PositionGetInteger(POSITION_MAGIC);
        ulong    positionType         = PositionGetInteger(POSITION_TYPE);
        double   positionPriceOpen    = PositionGetDouble(POSITION_PRICE_OPEN);
        double   positionTake         = PositionGetDouble(POSITION_TP);
        double   positionStop         = PositionGetDouble(POSITION_SL);
        ulong    positionTicket       = PositionGetTicket(i);

        if (positionMagicNumber == magicNumber && positionSymbol == symbol && positionType == POSITION_TYPE_SELL) {
            if (positionTake != tp && averagePrice != 0 && SymbolInfoGenericFunctions.Ask() >= tp) {
               TradeGenericFunctions.PositionModify(positionTicket, positionStop, tp);
            }
        }
    }
}

//VERIFICA SE O ATIVO AINDA ESTA EM LEILAO ##############################################################################################################################################
bool isAuction(string symbol, ENUM_TIMEFRAMES timeframe) {
MqlDateTime time_candle_previous, time_candle_current, time_current;
   
//DEFININDO HORÁRIOS DOS CANDLES
   TimeToStruct(TimeCurrent(), time_current); 
   TimeToStruct(iTime(symbol, timeframe, 0), time_candle_current);
   TimeToStruct(iTime(symbol, timeframe, 1), time_candle_previous);
   
//VARIÁVEIS
   double highCandle = iHigh(symbol, timeframe, 0);
   double lowCandle = iLow(symbol, timeframe, 0);
   
//VERIFICAÇÕES
   if (time_candle_current.day != time_candle_previous.day) {
      if (highCandle != lowCandle) {
         return false;
      }
   } else {
      if (time_current.day == time_candle_current.day) {
         return false;
      }
   }
   return true;
}

//ENVIAR ORDEM ##############################################################################################################################################
bool sendOrders(ulong magicNumber, ENUM_OPERATIONS_TYPE type, double precoBruto, string symbol, double lote, double take, double stop, bool stopFixedPrice = false){
   SymbolInfoGenericFunctions.Name(symbol);
   SymbolInfoGenericFunctions.Refresh();
   SymbolInfoGenericFunctions.RefreshRates();
   
   TradeGenericFunctions.SetExpertMagicNumber(magicNumber);
   
   double valorAtual = SymbolInfoGenericFunctions.Last();
   double preco = SymbolInfoGenericFunctions.NormalizePrice(precoBruto);
   double takeProfitLocal = 0;
   double stopLossLocal = 0;
   static bool isExecuting;
   
   if (isExecuting) {return false;}
   
   if (type == sell) {
      takeProfitLocal = take != 0 ? SymbolInfoGenericFunctions.NormalizePrice(preco - take) : take;
      stopLossLocal = stop != 0 && !stopFixedPrice ? SymbolInfoGenericFunctions.NormalizePrice(preco + stop) : stop;
      
      if (SymbolInfoGenericFunctions.Bid() > preco) {      
         TradeGenericFunctions.SellStop(lote, preco, symbol, stopLossLocal, takeProfitLocal, ORDER_TIME_DAY, 0, "ORDEM SELLSTOP");
         isExecuting = true;
         
         if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE && TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_PLACED) {
            Print("ERRO AO ENVIAR ORDEM DE VENDA, CÓDIGO DE ERRO: ", TradeGenericFunctions.ResultRetcode());
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());  
            
            isExecuting = false;    
            return false; 
         } else {
            Print("ORDEM DE VENDA ENVIADA NO PREÇO: ", preco);
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
            
            isExecuting = false;
            return true;
         }
      } else {
         TradeGenericFunctions.SellLimit(lote, preco, symbol, stopLossLocal, takeProfitLocal, ORDER_TIME_DAY, 0, "ORDEM SELLLIMIT");
         isExecuting = true;
         
         if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE && TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_PLACED) {
            Print("ERRO AO ENVIAR ORDEM DE VENDA, CÓDIGO DE ERRO: ", TradeGenericFunctions.ResultRetcode());
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());  
            
            isExecuting = false; 
            return false;    
         } else {
            Print("ORDEM DE VENDA ENVIADA NO PREÇO: ", preco);
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
            
            isExecuting = false;
            return true;
         }      
      }
   } else {
      takeProfitLocal = take != 0 ? SymbolInfoGenericFunctions.NormalizePrice(preco + take) : take;
      stopLossLocal = stop != 0 && !stopFixedPrice ? SymbolInfoGenericFunctions.NormalizePrice(preco - stop) : stop;
      
      
      if (SymbolInfoGenericFunctions.Bid() > preco) {      
         TradeGenericFunctions.BuyLimit(lote, preco, symbol, stopLossLocal, takeProfitLocal, ORDER_TIME_DAY, 0, "ORDEM BUYLIMIT");
         isExecuting = true;
         
         if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE && TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_PLACED) {
            Print("ERRO AO ENVIAR ORDEM DE COMPRA, CÓDIGO DE ERRO: ", TradeGenericFunctions.ResultRetcode());
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());   
            
            isExecuting = false;
            return false;    
         } else {
            Print("ORDEM DE COMPRA ENVIADA NO PREÇO: ", preco);
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
            
            isExecuting = false;
            return true;
         }
      } else {
         TradeGenericFunctions.BuyStop(lote, preco, symbol, stopLossLocal, takeProfitLocal, ORDER_TIME_DAY, 0, "ORDEM BUYSTOP");
         isExecuting = true;
         
         if (TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_DONE && TradeGenericFunctions.ResultRetcode() != TRADE_RETCODE_PLACED) {
            Print("ERRO AO ENVIAR ORDEM DE COMPRA, CÓDIGO DE ERRO: ", TradeGenericFunctions.ResultRetcode());
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());       
            
            isExecuting = false;
            return false;
         } else {
            Print("ORDEM DE COMPRA ENVIADA NO PREÇO: ", preco);
            Print("COMENTÁRIO DA CORRETORA: ", TradeGenericFunctions.ResultComment());
            
            isExecuting = false;
            return true;
         }      
      }
   }
   
   return false;
}

//BUSCA QUANTAS OPERACOES FORAM FEITAS NO DIA ##############################################################################################################################################
int getTotalOperationsOnTheDay(string symbol, ulong magicNumber) {
    datetime end = TimeCurrent();
    datetime start = iTime(symbol, PERIOD_D1, 0);

    HistorySelect(start, end);
    int dealsTotal = HistoryDealsTotal();
    
    int total = 0;

    for (int i = dealsTotal - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);

        if (dealTicket > 0) {
            string   dealSymbol        = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            ulong    dealMagicNumber   = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            ulong    dealType          = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
            ulong    dealEntry         = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

            if (dealSymbol == symbol && dealMagicNumber == magicNumber) { 
                if (dealEntry == DEAL_ENTRY_IN) {
                    total++;
                }
            }
        }
    }

    return total;
}