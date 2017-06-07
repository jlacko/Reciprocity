# Libraries ----
library(tidyverse)
library(Cairo)
library(scales)
library(extrafont)


# Source data... ----
# Bergger Pancro400 from datasheet
bg400 <- tibble(measured = c(1, 10, 60), 
                adjusted = c(1.4, 10*2, 60*4)
)

#Fomapan Classic 100 from datasheet
fp100 <- tibble(measured = c(1, 10, 100), 
                adjusted = c(1*2, 10*8, 100*16)
)

#Rollei RPX25 from datasheet - http://www.atwaterkent.info/Images/Datasheet_Rollei%20RPX%2025_aug%20English_245.pdf
rpx25 <- tibble(measured = c(1,2, 10, 20, 50), 
                adjusted = c(1,3, 20, 50, 180)
)

#HP5 from net (APUG)
HP5net <- tibble(measured = c(5,10,15,20,25,30),
                 adjusted = c(12.5,31,56,84,118,157)
)

#HP5 from Photo Techinque Magazine (Howard Bond) - http://phototechmag.com/black-and-white-reciprocity-departure-revisited-by-howard-bond/
HP5Bond <- tibble(measured = c(1,2,4,8,15,30,60,120,240),
                  adjusted = c(1,2,5,10,24,54,2*60+36,5*60+45,19*60)
)


# generic Ilford datasheet
Ilford <- tibble(measured = c(1,2,4,8,15,20,25,30),
                 adjusted = c(1,4,9,24,55,82,118,155))


# Regression & preparation of chart annotation  ----

#Film version to be analysed - data & label
ChrtSrc <- rpx25 %>%
  mutate(label = paste(measured, '/', adjusted))

FilmLabel <- "RPX25"


#regression on log - log transformed data
expmodel <- lm(formula = log(adjusted) ~ log(measured), data = ChrtSrc)


# chart source
model <- tibble(measured = c(1:120), 
                modelled = exp(coef(expmodel)[1])*measured^coef(expmodel)[2])


# transform equation for chart annotation
eq <- substitute(italic(adjusted) ==  a*~italic(measured)^~b, 
                 list(a = format(exp(coef(expmodel)[1]), digits = 4), 
                      b = format(coef(expmodel)[2], digits = 4)))


# standard exposure times (half steps)
times <- tibble(measured = c(1,1.5,2,3,4,6,8,10,12,15,20,30,45,50,60,90,120),
                modelled = exp(coef(expmodel)[1])*measured^coef(expmodel)[2])



# Chart ----

ggplot() +
  geom_point(data = ChrtSrc, aes(x = measured, y = adjusted),color = "darkorange2", shape = 20, size = 2) +
  geom_text(data = ChrtSrc, aes(x = measured, y = adjusted, label = label), size = 3, vjust = -1) +
  geom_line(data = model, aes(x = measured, y = modelled), color = "cornflowerblue", linetype = "dotdash") +
  scale_x_continuous(breaks = c(1,2,4,8,15,30,60,120), 
                     limits = c(1,60)) +
  scale_y_continuous(breaks = c(15,30,60,120,180,5*60,7*60,10*60,15*60),
                     limits = c(1,4*60))+
  theme_classic()+
  theme(text=element_text(family="Calibri"))+
  theme(plot.title = element_text(size = rel (1.5), face = "bold"))+
  labs(x = "measured time (sec.)", y = "adjusted time (sec)", 
       title = "Reciprocity failure",
       subtitle = FilmLabel) +
  
  annotate("text", x = 50, y = 5, label = as.character(as.expression(eq)), parse = TRUE, size = rel(3))

# saving of results... ----
ggsave(paste(FilmLabel,"ReciprocityChart.png", sep= ""), h = 6, w = 8, dpi = 100, type = "cairo-png")
write_csv(times, paste(FilmLabel,"ReciprocityTable.csv", sep = ""))

# Cleanup
rm(eq)
rm(FilmLabel)