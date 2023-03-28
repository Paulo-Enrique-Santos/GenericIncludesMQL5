//###################################################################################################################################################
//CABEÇALHO ############################################################################################################################################
//###################################################################################################################################################

#property copyright "Paulo Enrique"
#property link      "WhatsApp - (11)98979-4039"
#property version   "1.05"

//INCLUDE E RESOURCE ############################################################################################################################################

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

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
            Print("PROBLEMAS PARA SELECIONAR UMA POSIÇÃO NA FUNÇÃO closeAllPositions!");
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
            Print("PROBLEMAS PARA SELECIONAR UMA POSIÇÃO NA FUNÇÃO isPositioned!");
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

    if (gainLimit <= profitTotal && gainLimit > 0) {
        closeAllPositions(symbol, magicNumber);
        Print("ORDENS FECHADAS APÓS ATINGIR O LUCRO DE: ", gainLimit, " LUCRO ATUAL: ", profitTotal);
        return true;
    }

    if ((lossLimit * -1) >= profitTotal && lossLimit > 0) {
        closeAllPositions(symbol, magicNumber);
        Print("ORDENS FECHADAS APÓS ATINGIR A PERDA DE: ", lossLimit, " PERDA ATUAL: ", profitTotal);
        return true;
    }

    return false;
}

//RETORNA O TOTAL DE LUCRO ##############################################################################################################################################
double getProfitHistoric(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe, bool isTotalProfit) {
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
int getGainsHistoric(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe, bool isTotalProfit) {
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
int getLossHistoric(string symbol, ulong magicNumber, ENUM_TIMEFRAMES timeframe, bool isTotalProfit) {
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
        Comment("O HORÁRIO DE FECHAMENTO FOI ATINGIDO");
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
            Comment("O ROBÔ ESTÁ NO HORÁRIO DE PAUSA");
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
        Comment("ESPERANDO HORÁRIO DE ABERTURA DO ROBÔ");
        return false;
    }

    return true;
}

//VERIFICA SE ABRIU UM NOVO CANDLE ##############################################################################################################################################
bool isNewCandle(string symbol, ENUM_TIMEFRAMES timeframe) {
    static int bars;

    if (bars != Bars(symbol, timeframe)) {
        bars = Bars(symbol, timeframe);
        return true;
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
        Print("PROBLEMAS PARA SELECIONAR UMA POSIÇÃO NA FUNÇÃO getPositionPriceOpenByTicket");
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
        Print("PROBLEMAS PARA SELECIONAR UMA POSIÇÃO NA FUNÇÃO getPositionTypeByTicket");
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
        Print("PROBLEMAS PARA SELECIONAR UMA POSIÇÃO NA FUNÇÃO getPositionTypeByTicket");
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
    double historicProfit = getProfitHistoric(symbol, magicNumber, PERIOD_D1, false);
    double profitTotal = positionsProfit + historicProfit;

    if (profitTotal < 0 || profitTotal < profit) {
        profit = profitTotal;
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