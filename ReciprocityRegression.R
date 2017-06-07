# Libraries ----
library(tidyverse)
library(Cairo)
library(scales)
library(extrafont)


# Data o filmech... ----
# Bergger Pancro400 z datasheetu
bg400 <- tibble(measured = c(1, 10, 60), 
                adjusted = c(1.4, 10*2, 60*4)
)

#Fomapan Classic 100 z datasheetu
fp100 <- tibble(measured = c(1, 10, 100), 
                adjusted = c(1*2, 10*8, 100*16)
)

#Rollei RPX25 z datasheetu - http://www.atwaterkent.info/Images/Datasheet_Rollei%20RPX%2025_aug%20English_245.pdf
rpx25 <- tibble(measured = c(1,2, 10, 20, 50), 
                adjusted = c(1,3, 20, 50, 180)
)

#HP5 z netu (APUG)
HP5net <- tibble(measured = c(5,10,15,20,25,30),
                 adjusted = c(12.5,31,56,84,118,157)
)

#HP5 z Photo Techinque Magazine (Howard Bond) - http://phototechmag.com/black-and-white-reciprocity-departure-revisited-by-howard-bond/
HP5Bond <- tibble(measured = c(1,2,4,8,15,30,60,120,240),
                  adjusted = c(1,2,5,10,24,54,2*60+36,5*60+45,19*60)
)
# Ilford datasheet

Ilford <- tibble(measured = c(1,2,4,8,15,20,25,30),
                 adjusted = c(1,4,9,24,55,82,118,155))


#Fomapan Classic podle JLA tabulek
fp100JLA <- tibble(measured = c(1,2,4,8,15,30,60),
                   adjusted = c(2,7,21,59,2*60+19,5*60+47, 14*60+3)
)

#Fomapan Action podle JLA tabulek
fp400JLA <-tibble(measured = c(1,2,4,8,15,30,60),
                  adjusted = c(2,6,18,45,60+38,3*60+38, 7*60+46)
)

# Regrese & dopočet křivek pro graf ----

#Se kterou verzí pracuju?!
ChrtSrc <- rpx25 %>%
  mutate(label = paste(measured, '/', adjusted))

FilmLabel <- "RPX25"


#lineární transformace = logaritmus upraveného podle logaritmu měřeného
expmodel <- lm(formula = log(adjusted) ~ log(measured), data = ChrtSrc)


# model z regrese pro graf
model <- tibble(measured = c(1:120), 
                modelled = exp(coef(expmodel)[1])*measured^coef(expmodel)[2])


# přepsání rovnice modelu pro anotaci grafu
eq <- substitute(italic(adjusted) ==  a*~italic(measured)^~b, 
                 list(a = format(exp(coef(expmodel)[1]), digits = 4), 
                      b = format(coef(expmodel)[2], digits = 4)))


# standardní půl časy
times <- tibble(measured = c(1,1.5,2,3,4,6,8,10,12,15,20,30,45,50,60,90,120),
                modelled = exp(coef(expmodel)[1])*measured^coef(expmodel)[2])



# Vlastní graf ----

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

# uložit potřebné...
ggsave(paste(FilmLabel,"ReciprocityChart.png"), h = 6, w = 8, dpi = 100, type = "cairo-png")
write_csv(times, paste(FilmLabel,"ReciprocityTable.csv"))

# Úklid (teď už rovnici nepotřebuji...)
rm(eq)
rm(FilmLabel)