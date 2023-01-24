
server <- function(input, output) {
  helper <- reactive({
    load("advanced_dashboard_helper.Rdata")
  })
  
  elo_1 <- reactive(create_elo_data(input$v_k_1))
  elo_2 <- reactive(create_elo_data(input$v_k_2))
  elo <- reactive(elo.run(winner ~ fighter + opponent,
                          k = input$v_k_2,
                          data = elo_df))
  output$weight_class_selector_1 <- renderUI({
    selectInput(inputId = "v_weight_class_1",
                label = "Weight Class",
                choices = elo_1() %>% clean_weight_class())
    
  })
  output$weight_class_selector_2 <- renderUI({
    selectInput(inputId = "v_weight_class_2",
                label = "Weight Class",
                choices = elo_2() %>% clean_weight_class())
  })
  output$weight_class_selector_3 <- renderUI({
    selectInput(inputId = "v_weight_class_3",
                label = "Weight Class",
                choices = elo_2() %>% clean_weight_class())
  })
  output$fighter_selector <- renderUI({
    selectInput(inputId = "v_fighter",
                label = "Fighter",
                choices = elo_2() %>% filter(weight_class == input$v_weight_class_2) %>% clean_fighter())
  })
  output$fighter_selector2 <- renderUI({
    selectInput(inputId = "v_fighter_desc",
                label = "Fighter",
                choices = elo_2() %>% filter(weight_class == input$v_weight_class_3) %>% clean_fighter())
  })
  output$opponent_selector <- renderUI({
    selectInput(inputId = "v_opponent",
                label = "Opponent",
                choices = elo_2() %>% 
                  filter(weight_class == input$v_weight_class_2) %>% 
                  filter(fighter != input$v_fighter) %>% 
                  clean_fighter())
  })
  output$top_5_table <- renderDataTable({
    elo_1() %>% 
      filter(weight_class == input$v_weight_class_1) %>% 
      group_by(fighter) %>% 
      arrange(desc(elo)) %>% 
      slice(1) %>% 
      ungroup() %>% 
      top_n(elo, n = 5) %>% 
      arrange(desc(elo)) %>% 
      select(fighter, elo) %>% 
      mutate(rank = row_number())     
  })
  output$elo_timeseries <- renderPlotly({
    elo_timeseries_df <- elo_1() %>% filter(weight_class == input$v_weight_class_1)
    
    top_5_fighters <- elo_timeseries_df %>% 
      group_by(fighter) %>% 
      arrange(desc(elo)) %>% 
      slice(1) %>% 
      ungroup() %>% 
      top_n(elo, n = 5) %>% 
      select(fighter)
    
    ggplotly(
      ggplot(data = elo_timeseries_df, aes(x = date, y = elo)) + 
        geom_point() + 
        geom_point(data = elo_timeseries_df %>% filter(fighter %in% top_5_fighters$fighter),
                   aes(x = date, y = elo, color = fighter)) +
        theme(legend.position = "top")
    )
  })
  output$elo_dist <- renderPlotly({
    ggplotly(ggplot(data = elo_1() %>% filter(weight_class == input$v_weight_class_1), aes(x = elo)) + geom_histogram())
  })
  output$fighter_card <- renderValueBox({
    valueBox(
      value = paste(round(100*predict(elo(), data.frame(fighter = input$v_fighter, opponent = input$v_opponent)),0), "%", sep = ""),
      subtitle = paste(input$v_fighter, " Probability", sep = ""),
      color = "blue",
      icon = icon("hand-rock")
    )
  })
  output$opponent_card <- renderValueBox({
    valueBox(
      value = paste(round(100*predict(elo(), data.frame(fighter = input$v_opponent, opponent = input$v_fighter)),0), "%", sep = ""),
      subtitle = paste(input$v_opponent, " Probability", sep = ""),
      color = "red",
      icon = icon("hand-rock")
    )
  })
  output$fighter_desc <- DT::renderDataTable({
    DT::datatable(
      df %>% 
        select(date, fighter, height = Height_cms, reach = Reach_cms, Stance, age, wins, losses) %>% 
        mutate(date = as.Date(date)) %>% 
        filter(fighter == input$v_fighter_desc) %>% 
        rename_all(~str_replace(.x, "_", " ") %>% str_to_title) %>% 
        add_tally(name = "Fights") %>% 
        slice_max(Date, n = 1) %>% 
        select(-Date),
      options = list(paging = FALSE,
                     searching = FALSE),
      rownames= FALSE
    )
    
  })
  output$fighter_radar <- renderPlotly({
    radar_df <- df %>%
      select(fighter, match_id, avg_LEG_landed, avg_BODY_landed, avg_CLINCH_landed, avg_GROUND_landed, avg_HEAD_landed) %>% 
      drop_na() %>% 
      group_by(fighter) %>% 
      filter(match_id == max(match_id)) %>% 
      ungroup() %>% 
      select(-match_id) %>% 
      rename_all(~str_replace_all(.x, "avg_|_landed", "") %>% str_to_title()) %>% 
      pivot_longer(-Fighter) %>% 
      filter(Fighter == input$v_fighter_desc)
    
    plot_ly(
      type = "scatterpolar",
      r = radar_df$value,
      theta = radar_df$name,
      fill = "toself"
    ) %>% 
      layout(title = paste0(input$v_fighter_desc))
  })
}
