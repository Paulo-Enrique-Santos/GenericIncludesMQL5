//###################################################################################################################################################
//CABEÇALHO ############################################################################################################################################
//###################################################################################################################################################

#property copyright "Paulo Enrique"
#property link      "WhatsApp - (11)98979-4039"
#property version   "1.09"

//VARIAVEIS ESTATICAS ###################################################################################################################################################

static         int      y_distance_global                   = 25;
static         int      x_distance_global                   = 10;
static         int      y_padding_global                    = 10;
static         int      x_padding_global                    = 10;
static         int      x_size_global                       = 0;
static         int      y_size_global                       = 0;
static         int      y_header_size_global                = 0;
static         color    border_color_global                 = NULL;

static         string   default_code_name                   = "objpanel_";
static         string   background_name                     = default_code_name + "panel";
static         string   header_name                         = default_code_name + "header";
static         string   minimze_button_name                 = default_code_name + "minimize";
static         string   close_button_name                   = default_code_name + "close";
static         string   close_positions_button_name         = default_code_name + "close_positions";
static         string   open_buy_button_name                = default_code_name + "open_buy_position";
static         string   open_sell_button_name               = default_code_name + "open_sell_position";

//###################################################################################################################################################
//GENERICPANEL CLASS ############################################################################################################################################
//###################################################################################################################################################

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GenericPanel
  {
public:
                     GenericPanel();
   bool              createBackground(int x_size, int y_size, uint background_color, uint border_color, int font_size, int y_header_size, int y_footer_size0 = 0);
   bool              createText(string name, uint text_color, int x_distance, int y_distance, string text, string fonte, int font_size, int anchor = ANCHOR_LEFT_UPPER);
   bool              editText(string name, uint text_color, string text);
   bool              createButton(string name, int x_size, int y_size, uint background_color, uint text_color, int x_distance, int y_distance, string text, string font, int font_size);
   bool              minimizePanel();
   bool              deletePanel();
   string            getBuyButtonName();
   string            getClosePositionsButtonName();
   string            getSellButtonName();
   string            getClosePanelButtonName();
   string            getMinimizePanelButtonName();
  };

//CONSTRUTOR ###################################################################################################################################################
GenericPanel::GenericPanel()
  {

  }

//CRIA O BACKGROUND DO PAINEL DE DADOS ###################################################################################################################################################
bool GenericPanel::createBackground(
   int x_size,
   int y_size,
   uint background_color,
   uint border_color,
   int font_size,
   int y_header_size,
   int y_footer_size = 0
)
  {
//TODOS DEIXA O PAINEL NO TAMANHO CORRETO
   y_size_global = y_size + (y_padding_global * 2);
   x_size_global = x_size + (x_padding_global * 2);
   
   if (y_footer_size > 0)
      y_size_global += y_footer_size;

//CRIA O BACKGROUND DO PAINEL
   if(!ObjectCreate(0, background_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return false;

   ObjectSetInteger(0, background_name, OBJPROP_BGCOLOR, background_color);
   ObjectSetInteger(0, background_name, OBJPROP_YDISTANCE, y_distance_global);
   ObjectSetInteger(0, background_name, OBJPROP_XDISTANCE, x_distance_global);
   ObjectSetInteger(0, background_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, background_name, OBJPROP_XSIZE, x_size_global);
   ObjectSetInteger(0, background_name, OBJPROP_YSIZE, y_size_global);
   ObjectSetInteger(0, background_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, background_name, OBJPROP_BORDER_COLOR, NULL);
   ObjectSetInteger(0, background_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, background_name, OBJPROP_BORDER_COLOR, border_color);
   ObjectSetInteger(0, background_name, OBJPROP_COLOR, border_color);
   ObjectSetInteger(0, background_name, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, background_name, OBJPROP_STYLE, STYLE_SOLID);

//CRIA O HEADER DO PAINEL
   if(!ObjectCreate(0, header_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return false;

   ObjectSetInteger(0, header_name, OBJPROP_BGCOLOR, border_color);
   ObjectSetInteger(0, header_name, OBJPROP_YDISTANCE, y_distance_global);
   ObjectSetInteger(0, header_name, OBJPROP_XDISTANCE, x_distance_global);
   ObjectSetInteger(0, header_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, header_name, OBJPROP_XSIZE, x_size_global);
   ObjectSetInteger(0, header_name, OBJPROP_YSIZE, y_header_size);
   ObjectSetInteger(0, header_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, header_name, OBJPROP_BORDER_COLOR, NULL);
   ObjectSetInteger(0, header_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, header_name, OBJPROP_BORDER_COLOR, border_color);
   ObjectSetInteger(0, header_name, OBJPROP_COLOR, border_color);
   ObjectSetInteger(0, header_name, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, header_name, OBJPROP_STYLE, STYLE_SOLID);

//CRIA O TITULO DO PAINEL
   int x_padding_header = x_padding_global;
   int y_padding_header = 3;
   int x_position_title = x_distance_global + x_padding_header;
   int y_position_title = y_distance_global + y_padding_header;

   if(!ObjectCreate(0, default_code_name + "title", OBJ_LABEL, 0, 0, 0))
      return false;

   ObjectSetInteger(0, default_code_name + "title", OBJPROP_YDISTANCE, y_position_title);
   ObjectSetInteger(0, default_code_name + "title", OBJPROP_XDISTANCE, x_position_title);
   ObjectSetString(0, default_code_name + "title", OBJPROP_TEXT, "Paniel de Dados");
   ObjectSetInteger(0, default_code_name + "title", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, default_code_name + "title", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, default_code_name + "title", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, default_code_name + "title", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, default_code_name + "title", OBJPROP_COLOR, background_color);

//CRIA OS BOTOES DO PAINEL
   int y_button_header_size = y_header_size;
   int x_button_header_size = 20;
   int y_position_button_header = y_distance_global;
   int x_position_close_button_header = x_size_global - x_padding_header - x_button_header_size + x_distance_global;
   int x_position_minimize_button_header = x_position_close_button_header - x_button_header_size - 3;

   //createButton("minimize", x_button_header_size, y_button_header_size, border_color, background_color, x_position_minimize_button_header, y_position_button_header, "▬", "Trebuchet MS", 13);
   createButton("close", x_button_header_size, y_button_header_size, border_color, background_color, x_position_close_button_header, y_position_button_header, "×", "Trebuchet MS", 20);

   int gap_footer_buttons = 15;
   int x_size_button_footer = ((x_size_global - (x_padding_global * 2))/ 3) - (gap_footer_buttons / 3);
   int y_position_button_footer = y_distance_global + y_size_global - y_footer_size - y_padding_global;
   int x_position_buy_botton = x_padding_global + x_distance_global;
   int x_position_close_botton = x_padding_global + x_distance_global + x_size_button_footer + (gap_footer_buttons / 2);
   int x_position_sell_botton = x_padding_global + x_distance_global + (x_size_button_footer *2) + ((gap_footer_buttons / 2) * 2);

   //CRIA O FOOTR DO PAINEL
   if(y_footer_size > 0)
     {
      createButton("open_buy_position", x_size_button_footer, y_footer_size, clrDodgerBlue, clrWhite, x_position_buy_botton, y_position_button_footer, "COMPRAR", "Trebuchet MS", font_size);
      createButton("close_positions", x_size_button_footer, y_footer_size, clrLightGray, clrBlack, x_position_close_botton, y_position_button_footer, "ZERAR", "Trebuchet MS", font_size);
      createButton("open_sell_position", x_size_button_footer, y_footer_size, clrRed, clrWhite, x_position_sell_botton, y_position_button_footer, "VENDER", "Trebuchet MS", font_size);
     }

   return true;
  }

//CRIA O TEXTO DO PAINEL DE DADOS ###################################################################################################################################################
bool GenericPanel::createText(string name, uint text_color, int x_distance, int y_distance, string text, string fonte, int font_size, int anchor = ANCHOR_LEFT_UPPER)
  {
   if(!ObjectCreate(0, default_code_name + name, OBJ_LABEL, 0, 0, 0))
      return false;

   int y_distance_local = y_distance + y_distance_global + y_padding_global;
   int x_distance_local = x_distance + x_distance_global + x_padding_global;

   if(anchor == ANCHOR_RIGHT_UPPER)
      x_distance_local = x_size_global ;
   else
      x_distance_local = x_distance + x_distance_global + x_padding_global;

   ObjectSetInteger(0, default_code_name + name, OBJPROP_YDISTANCE, y_distance_local);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_XDISTANCE, x_distance_local);
   ObjectSetString(0, default_code_name + name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_COLOR, text_color);

   return true;
  }

//EDITA O TEXTO DO PAINEL DE DADOS ###################################################################################################################################################
bool GenericPanel::editText(string name,uint text_color,string text)
  {
   ObjectSetString(0, default_code_name + name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_COLOR, text_color);

   return true;
  }

//CRIA O BOTAO DO PAINEL DE DADOS ###################################################################################################################################################
bool GenericPanel::createButton(string name, int x_size, int y_size, uint background_color, uint text_color, int x_distance, int y_distance, string text, string font, int font_size)
  {
   if(!ObjectCreate(0, default_code_name + name, OBJ_BUTTON, 0, 0, 0))
      return false;

   ObjectSetInteger(0, default_code_name + name, OBJPROP_BGCOLOR, background_color);
   ObjectSetString(0, default_code_name + name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_XSIZE, x_size);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_YSIZE, y_size);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_BACK, false);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_BORDER_COLOR, NULL);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_BORDER_COLOR, background_color);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_YDISTANCE, y_distance);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_XDISTANCE, x_distance);

   return true;
  }

//MINIMA E MAXIMIZA O PAINEL DE DADOS ###################################################################################################################################################
bool GenericPanel::minimizePanel()
  {
//BUSCA TODOS OS OBJETOS DO GRAFICO
   int total = ObjectsTotal(0);

//ATUALIZA A DISTANCIA ATUAL DO PAINEL
//y_distance_global_current = ObjectGetInteger(0, background_name, OBJPROP_YDISTANCE);

//PERCORRE TODOS OS OBJETOS DO GRAFICO
   for(int i = total - 1; i >= 0; i--)
     {
      //BUSCA APENAS POR OBJETOS DO PAINEL
      if(StringFind(ObjectName(0, i), default_code_name) >= 0)
        {
         //BUSCA A DISTANCIA ATUAL DO OBJETO
         long y_distance_object = ObjectGetInteger(0, ObjectName(0, i), OBJPROP_YDISTANCE);

         //VALIDA SE O PAINEL ESTA ABERTO OU FECHADO
         if(y_distance_global == 0)
           {
            //FAZ A CONTA PARA ATUALIZAR A DISTANCIA DO PAINEL
            long y_distace_current = (y_distance_object - y_distance_global) + y_header_size_global;

            //ATUALIZA A DISTANCIA DO PAINEL
            ObjectSetInteger(0, ObjectName(0, i), OBJPROP_YDISTANCE, y_distace_current);
           }
         else
           {
            //FAZ A CONTA PARA ATUALIZAR A DISTANCIA DO PAINEL
            long y_distace_current = (y_distance_object + y_distance_global) - y_header_size_global;

            //ATUALIZA A DISTANCIA DO PAINEL
            ObjectSetInteger(0, ObjectName(0, i), OBJPROP_YDISTANCE, y_distace_current);
           }
        }
     }

   return true;
  }

//DELETA O PAINEL DE DADOS ###################################################################################################################################################
bool GenericPanel::deletePanel()
  {
//BUSCA TODOS OS OBJETOS DO GRAFICO
   int total = ObjectsTotal(0);

//PERCORRE TODOS OS OBJETOS DO GRAFICO
   for(int i = total - 1; i >= 0; i--)
     {
      //BUSCA APENAS POR OBJETOS DO PAINEL
      if(StringFind(ObjectName(0, i), default_code_name) >= 0)
        {
         //DELETA OS OBJETOS DO PAINEL
         ObjectDelete(0, ObjectName(0, i));
        }
     }

   return true;
  }

//GETTTERS ###################################################################################################################################################
string GenericPanel::getBuyButtonName()
  {
   return open_buy_button_name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenericPanel::getSellButtonName()
  {
   return open_sell_button_name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenericPanel::getClosePositionsButtonName()
  {
   return close_positions_button_name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenericPanel::getClosePanelButtonName()
  {
   return close_button_name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenericPanel::getMinimizePanelButtonName()
  {
   return minimze_button_name;
  }
//+------------------------------------------------------------------+
