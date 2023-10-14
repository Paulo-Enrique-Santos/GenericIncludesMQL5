//###################################################################################################################################################
//CABEÇALHO ############################################################################################################################################
//###################################################################################################################################################

#property copyright "Paulo Enrique"
#property link      "WhatsApp - (11)98979-4039"
#property version   "1.09"

//VARIAVEIS ESTATICAS ###################################################################################################################################################

static         int      y_distance_global          = 0;
static         long     y_distance_global_current  = 0;
static         int      header_size_global         = 0;
static         color    border_color_global        = NULL;
static         string   default_code_name          = "objpanel_";
static         string   background_name            = default_code_name + "panel";
static         string   header_name                = default_code_name + "header";
static         string   minimze_button_name        = default_code_name + "minimize";
static         string   close_button_name          = default_code_name + "close";

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
   bool              createBackground(int x_size, int y_size, uint background_color, uint border_color, int size_header, int y_distance = 0, int x_distance = 0, ENUM_BASE_CORNER corner = CORNER_LEFT_LOWER);
   bool              createText(string name, uint text_color, int x_distance, int y_distance, string text, string fonte, int font_size, int anchor = ANCHOR_LEFT_UPPER);
   bool              editText(string name, uint text_color, string text);
   bool              createButton(string name, int x_size, int y_size, uint background_color, uint text_color, int x_distance, int y_distance, string text, string font, int font_size, ENUM_BASE_CORNER corner = CORNER_LEFT_LOWER);
   bool              minimizePanel();
   bool              deletePanel();
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
   int size_header,
   int y_distance = 0,
   int x_distance = 0,
   ENUM_BASE_CORNER corner = CORNER_LEFT_LOWER
)
  {
//CRIA O BACKGROUND DO PAINEL
   if(!ObjectCreate(0, background_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return false;

   ObjectSetInteger(0, background_name, OBJPROP_BGCOLOR, background_color);
   ObjectSetInteger(0, background_name, OBJPROP_YDISTANCE, y_distance);
   ObjectSetInteger(0, background_name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, background_name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, background_name, OBJPROP_XSIZE, x_size);
   ObjectSetInteger(0, background_name, OBJPROP_YSIZE, y_size);
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
   ObjectSetInteger(0, header_name, OBJPROP_YDISTANCE, y_distance);
   ObjectSetInteger(0, header_name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, header_name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, header_name, OBJPROP_XSIZE, x_size);
   ObjectSetInteger(0, header_name, OBJPROP_YSIZE, size_header);
   ObjectSetInteger(0, header_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, header_name, OBJPROP_BORDER_COLOR, NULL);
   ObjectSetInteger(0, header_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, header_name, OBJPROP_BORDER_COLOR, border_color);
   ObjectSetInteger(0, header_name, OBJPROP_COLOR, border_color);
   ObjectSetInteger(0, header_name, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, header_name, OBJPROP_STYLE, STYLE_SOLID);

//CRIA OS BOTOES DO PAINEL
   createButton("minimize", 20, size_header, border_color, background_color, x_size - 50, y_size, "▬", "Trebuchet MS", 13);
   createButton("close", 20, size_header, border_color, background_color, x_size - 20, y_size, "×", "Trebuchet MS", 20);

//CRIA O TITULO DO PAINEL
   createText("title", background_color, 20, y_size - 3, "Painel de Dados", "Trebuchet MS", 10);

   y_distance_global = y_distance;
   y_distance_global_current = y_distance;
   header_size_global = size_header;

   return true;
  }

//CRIA O TEXTO DO PAINEL DE DADOS ###################################################################################################################################################
bool GenericPanel::createText(string name, uint text_color, int x_distance, int y_distance, string text, string fonte, int font_size, int anchor = ANCHOR_LEFT_UPPER)
  {
   if(!ObjectCreate(0, default_code_name + name, OBJ_LABEL, 0, 0, 0))
      return false;

   ObjectSetInteger(0, default_code_name + name, OBJPROP_YDISTANCE, y_distance);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetString(0, default_code_name + name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
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
bool GenericPanel::createButton(string name, int x_size, int y_size, uint background_color, uint text_color, int x_distance, int y_distance, string text, string font, int font_size, ENUM_BASE_CORNER corner = CORNER_LEFT_LOWER)
  {
   if(!ObjectCreate(0, default_code_name + name, OBJ_BUTTON, 0, 0, 0))
      return false;

   ObjectSetInteger(0, default_code_name + name, OBJPROP_BGCOLOR, background_color);
   ObjectSetString(0, default_code_name + name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, default_code_name + name, OBJPROP_CORNER, corner);
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
   y_distance_global_current = ObjectGetInteger(0, background_name, OBJPROP_YDISTANCE);

//PERCORRE TODOS OS OBJETOS DO GRAFICO
   for(int i = total - 1; i >= 0; i--)
     {
      //BUSCA APENAS POR OBJETOS DO PAINEL
      if(StringFind(ObjectName(0, i), default_code_name) >= 0)
        {
         //BUSCA A DISTANCIA ATUAL DO OBJETO
         long y_distance_object = ObjectGetInteger(0, ObjectName(0, i), OBJPROP_YDISTANCE);

         //VALIDA SE O PAINEL ESTA ABERTO OU FECHADO
         if(y_distance_global == y_distance_global_current)
           {
            //FAZ A CONTA PARA ATUALIZAR A DISTANCIA DO PAINEL
            long y_distace_current = (y_distance_object - y_distance_global) + header_size_global;

            //ATUALIZA A DISTANCIA DO PAINEL
            ObjectSetInteger(0, ObjectName(0, i), OBJPROP_YDISTANCE, y_distace_current);
           }
         else
           {
            //FAZ A CONTA PARA ATUALIZAR A DISTANCIA DO PAINEL
            long y_distace_current = (y_distance_object + y_distance_global) - header_size_global;

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

//###################################################################################################################################################
//ON CHART ############################################################################################################################################
//###################################################################################################################################################
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//INICIA UMA CLASSE DE PAINEL
   GenericPanel genericPanel;

//VALIDA SE FOI UM EVENTO DE CLICK
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      //VALIDA SE O CLIQUE FOI NO BOTAO DE MINIMIZAR O PAINEL
      if(sparam == minimze_button_name)
        {
         //MINIMZA O PAINEL
         genericPanel.minimizePanel();
        }

      if(sparam == close_button_name)
        {
         //DELETA O PAINEL DE DADOS
         genericPanel.deletePanel();
        }

      ChartRedraw(0);
     }
  }
//+------------------------------------------------------------------+
