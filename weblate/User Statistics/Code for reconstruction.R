df <- df %>%
  group_by(x) %>% 
  mutate(z=list(eval(parse(text=z))))