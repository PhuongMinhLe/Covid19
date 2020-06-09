## Graph from Phuong ###

setwd("C:/Users/Dell/Dropbox/COVID-firmes/Working_files/Scripts/R_graphs")

library(readr)
library(tidyverse)
supply_occ_2d <- read_csv("supply_occ_2d.csv")


# Try the original 4 dimensions one : 
    # X = Remote labor index (0 to 1) //  == rli 
    # Y = Fraction of essential employees (0 to 1) // == occ_ess_ita
    # Color = wage // == earn_mean [I assumed]
    # Size of the bubbles = employment  // == size_employment

bdd <- supply_occ_2d
# 39 obs of 20 variables 

bdd$size_employment<- log(bdd$occ_emp_tot)

#----------------- Teleworkability ------------------#
# Save the graph #1
jpeg("plot_tlw.jpeg", width = 5.5, height = 5, units = 'in', res = 300)

# Graph with Isco inside the bubbles 
p <- ggplot(bdd, 
       aes(x=teleworkable,  
           y=occ_ess,  
           color = earn_mean ,
           size = size_employment)) +
  geom_point() +                                                     # Scatterplot 
  scale_size(range = c(1,10)) +                                      # Scale of the bubbles
  geom_text(label= bdd$isco08_2d, color= "black", size =3) +         # Label inside the bubbles (Isco)
  scale_color_gradientn(colours = rainbow(5))                               # Colours like rainbow

# Labels and legends
p + labs(
  color = "Mean earnings",
  size = "Ln employment",
  x = "Teleworkability",
  y = "Employment fraction in essential industries"
)

# Save the graph #2
dev.off()

#----------------- RLI ------------------#
# Save the graph #2
jpeg("plot_rli.jpeg", width = 5.5, height = 5, units = 'in', res = 300)

# Graph with Isco inside the bubbles 
p <- ggplot(bdd, 
            aes(x=rli,  
                y=occ_ess,  
                color = earn_mean ,
                size = size_employment)) +
  geom_point() +                                                     # Scatterplot 
  scale_size(range = c(1,10)) +                                      # Scale of the bubbles
  geom_text(label= bdd$isco08_2d, color= "black", size =3) +         # Label inside the bubbles (Isco)
  scale_color_gradientn(colours = rainbow(5))                               # Colours like rainbow

# Labels and legends
p + labs(
  color = "Mean earnings",
  size = "Ln employment",
  x = "Remote labor index",
  y = "Employment fraction in essential industries"
)

# Save the graph #2
dev.off()

# Graph with ISCO as x
 ggplot(bdd, 
           mapping = aes(x=isco08_2d,  
           y=rli,  
           color = occ_ess_ita , 
           size = size_employment)) +  
      geom_point() +
     scale_color_gradientn(colours = rainbow(5))
 
