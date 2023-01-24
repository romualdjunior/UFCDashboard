ui <- dashboardPage(
  dashboardHeader(title = "UFC Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Weight Class",
               tabName = "weight_class_tab",
               icon = icon("dashboard")),
      menuItem("Head to Head",
               tabName = "head_tab",
               icon = icon("dashboard")),
      menuItem("Fighter",
               tabName = "fighter_tab",
               icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "weight_class_tab",
              box(plotlyOutput("elo_timeseries")),
              box(plotlyOutput("elo_dist")),
              box(dataTableOutput("top_5_table")),
              box(uiOutput("weight_class_selector_1")),
              box(sliderInput(inputId = "v_k_1",
                              label = "K for ELO",
                              min = 1, 
                              max = 100,
                              value = 20))
      ),
      tabItem(tabName = "head_tab",
              fluidRow(box(uiOutput("fighter_selector")), box(uiOutput("opponent_selector"))),
              fluidRow(box(valueBoxOutput("fighter_card")), box(valueBoxOutput("opponent_card"))),
              box(uiOutput("weight_class_selector_2")),
              box(sliderInput("v_k_2",
                              label = "K for ELO",
                              min = 1,
                              max = 100,
                              value = 20))),
      tabItem(tabName = "fighter_tab",
              fluidRow(box(uiOutput("fighter_selector2")), box(uiOutput("weight_class_selector_3"))),
              fluidRow(box(DT::dataTableOutput("fighter_desc"), width = 12, column(align = "center", width = 12))),
              fluidRow(box(plotlyOutput("fighter_radar"), width = 12, column(align = "center", width = 12))))
    )
  )
  
)