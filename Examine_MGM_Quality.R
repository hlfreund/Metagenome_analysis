#if (!requireNamespace("BiocManager", quietly = TRUE))
#install.packages("BiocManager")
#BiocManager::install(version = "3.10")
#BiocManager::install(c("phyloseq"))
library(phyloseq)
#install.packages("ggplot2")
library (ggplot2)
library (vegan)
library(reshape2)
#install.packages("ggpubr")
library(ggpubr)
#install.packages("scales")
library(scales)
library(grid)
library(ape)
#install.packages("dplyr")
library(dplyr)
#install.packages("viridis")
library(viridis)
#install.packages("readxl")
library(readxl)
#BiocManager::install("metagenomeSeq")
library(metagenomeSeq)
#if (!requireNamespace("BiocManager", quietly = TRUE))
#install.packages("BiocManager")
#BiocManager::install("DESeq2")
library(DESeq2)
library(dplyr)
library(magrittr)
library(MASS)
library(ade4)
library("dendextend")
library("tidyr")
library("viridis")
library("reshape")
# Install
#install.packages("wesanderson")
# Load
library(wesanderson)
#devtools::install_github("katiejolly/nationalparkcolors")
library(nationalparkcolors)
library(shades)
#install.packages("tidyverse")
#install.packages("tidygraph")
#install.packages("ggraph")
#install.packages("RAM")
#install.packages("FactoMineR")
library(FactoMineR)
#library(tidyverse)
#library(tidygraph)
#library(ggraph)
#library(RAM)
#install.packages("huxtable")
library(huxtable)


### BEFORE YOU BEGIN! 
# make sure you change the directory and file names to the names of your files

setwd("/Volumes/HLF_SSD/SS_POW_MGM_Results") # change to your path
getwd()


#### Import Checkm Results ####

# import Pacific Ocean Water results
pow_best<-read.table(file = 'EA_Pool-POW_1-1a_S28_best_quality.tsv', sep = '\t', header = TRUE)
pow_high<-read.table(file = 'EA_Pool-POW_1-1a_S28_high_quality.tsv', sep = '\t', header = TRUE)
pow_med<-read.table(file = 'EA_Pool-POW_1-1a_S28_med_quality.tsv', sep = '\t', header = TRUE)
pow_low<-read.table(file = 'EA_Pool-POW_1-1a_S28_low_quality.tsv', sep = '\t', fill=TRUE, header = TRUE)
pow_low<-pow_low[!(pow_low$Taxa_Level=="root"),]

pow_all<-rbind(pow_best,pow_high,pow_med,pow_low)
pow_all<-subset(pow_all, select=-c(Lineage_ID)) # subset only part of the metadata we need
pow_all$Sample_Source<-"POW"
head(pow_all)

# import first Salton Sea water results
ss1_best<-read.table(file = 'EA_Pool-SeaWater_1-1a_S26_best_quality.tsv', sep = '\t', header = TRUE)
ss1_high<-read.table(file = 'EA_Pool-SeaWater_1-1a_S26_high_quality.tsv', sep = '\t', header = TRUE)
ss1_med<-read.table(file = 'EA_Pool-SeaWater_1-1a_S26_med_quality.tsv', sep = '\t', header = TRUE)
ss1_low<-read.table(file = 'EA_Pool-SeaWater_1-1a_S26_low_quality.tsv', sep = '\t', fill=TRUE, header = TRUE)
ss1_low<-ss1_low[!(ss1_low$Taxa_Level=="root"),]

ss1_all<-rbind(ss1_best,ss1_high,ss1_med,ss1_low)
ss1_all<-subset(ss1_all, select=-c(Lineage_ID)) # subset only part of the metadata we need
ss1_all$Sample_Source<-"SS"
head(ss1_all)

# import second Salton Sea water results
ss2_best<-read.table(file = 'EA_Pool-SeaWater_1a3_S27_best_quality.tsv', sep = '\t', header = TRUE)
ss2_high<-read.table(file = 'EA_Pool-SeaWater_1a3_S27_high_quality.tsv', sep = '\t', header = TRUE)
ss2_med<-read.table(file = 'EA_Pool-SeaWater_1a3_S27_med_quality.tsv', sep = '\t', header = TRUE)
ss2_low<-read.table(file = 'EA_Pool-SeaWater_1a3_S27_low_quality.tsv', sep = '\t', fill=TRUE, header = TRUE)
ss2_low<-ss2_low[!(ss2_low$Taxa_Level=="root"),]

ss2_all<-rbind(ss2_best,ss2_high,ss2_med,ss2_low)
ss2_all<-subset(ss2_all, select=-c(Lineage_ID)) # subset only part of the metadata we need
ss2_all$Sample_Source<-"SS"
head(ss2_all)

#### Checking out some color pallettes before we visualize ####
wes1<-wes_palette("Chevalier1")
wes2<-wes_palette("Moonrise3")
wes3<-wes_palette("IsleofDogs1")
wes4<-wes_palette("GrandBudapest1")
wes5<-wes_palette("GrandBudapest2")

SM_pal <- park_palette("SmokyMountains") # create a palette and specify # of colors youw ant
Arc_pal <- park_palette("Arches") # create a palette and specify # of colors youw ant
CL_pal <- park_palette("CraterLake") # create a palette and specify # of colors youw ant
Sag_pal <- park_palette("Saguaro") # create a palette and specify # of colors youw ant
Aca_pal <- park_palette("Acadia") # create a palette and specify # of colors youw ant
DV_pal <- park_palette("DeathValley") # create a palette and specify # of colors youw ant
DV_pal2 <- park_palette("DeathValley", 1) # create a palette and specify # of colors youw ant
CI_pal <- park_palette("ChannelIslands") # create a palette and specify # of colors youw ant
Bad_pal <- park_palette("Badlands") # create a palette and specify # of colors youw ant
MR_pal2 <- park_palette("MtRainier", 1) # create a palette and specify # of colors youw ant
MR_pal <- park_palette("MtRainier") # create a palette and specify # of colors youw ant

HI_pal <- park_palette("Hawaii") # create a palette and specify # of colors youw ant

YS_pal<-get_palette(palette = paste0("#", c("028edf","30eec8","fecd49","f56e00","8c4017","4d5f07","ccddf5","1f7ec1")), k = 8)


colfunc <- colorRampPalette(c("blue", "red"))
grad<-colfunc(10)

#fungal_pal<-get_palette(palette = paste0("#", c("222529","c72421","da7049","eedc2b","c5debf","b6f2fa","513a56","fafccf")), k = 8)
#fungal_pal2<-get_palette(palette = paste0("#", c("07060f","dd1f19","eda964","bba20d","44be45","74dabc","5e2479","5f3523")), k = 8)

#scale_fill_manual(values = wes_palette("IsleofDogs1"))

#### Visualize the Results Considering Completeness & Contamination ####

pw_fig<-ggplot(pow_all, aes(x = reorder(Bin_Num, -Completeness), y=Completeness)) + geom_bar(aes(fill = Contamination), stat = "identity") + scale_fill_gradient(low = "forestgreen", high = "red2", na.value = NA) + theme_classic() + theme_bw()+theme_classic()+
  labs(title="Metagenome Assembled Genome Quality - Pacific Ocean Water", subtitle="Color Gradient Based on Contamination of Assembly", caption = "Sample ID = POW_1-1a_S28", x="Bin Numer", y="Completeness (%)", fill="Contamination (%)")+
  theme(axis.title.x = element_text(size=13),axis.title.y = element_text(size=13),legend.title.align=0.5, legend.title = element_text(size=13),axis.text = element_text(size=11),axis.text.x = element_text(vjust=1),legend.text = element_text(size=11),plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, vjust = 0, size=10))
# reorder(Bin_Num, -Completeness) : reorders x axis based on largest to smallest #s in y axis!
ggsave(pw_fig,filename = "Quality_POW_MAG_12.14.2020.pdf", width=15, height=10, dpi=600)

ss1_fig<-ggplot(ss1_all, aes(x = reorder(Bin_Num, -Completeness), y=Completeness)) + geom_bar(aes(fill = Contamination), stat = "identity") + scale_fill_gradient2(low = "forestgreen", mid="yellow1", high = "red2",midpoint=5, na.value = NA) + theme_classic() + theme_bw()+theme_classic()+
  labs(title="Metagenome Assembled Genome Quality - Salton Sea Water 1", subtitle="Color Gradient Based on Contamination of Assembly", caption = "Sample ID = SeaWater_1-1a_S26", x="Bin Numer", y="Completeness (%)", fill="Contamination (%)")+
  theme(axis.title.x = element_text(size=13),axis.title.y = element_text(size=13),legend.title.align=0.5, legend.title = element_text(size=13),axis.text = element_text(size=11),axis.text.x = element_text(vjust=1),legend.text = element_text(size=11),plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, vjust = 0, size=10))

ggsave(ss1_fig,filename = "Quality_SS1_MAG_12.14.2020.pdf", width=15, height=10, dpi=600)

ss2_fig<-ggplot(ss2_all, aes(x = reorder(Bin_Num, -Completeness), y=Completeness)) + geom_bar(aes(fill = Contamination), stat = "identity") + scale_fill_gradient2(low = "forestgreen", mid="yellow1", high = "red2",midpoint=5, na.value = NA)+ theme_classic() + theme_bw()+theme_classic()+
  labs(title="Metagenome Assembled Genome Quality - Salton Sea Water 2", subtitle="Color Gradient Based on Contamination of Assembly", caption = "Sample ID = SeaWater_1a3_S27", x="Bin Numer", y="Completeness (%)", fill="Contamination (%)")+
  theme(axis.title.x = element_text(size=13),axis.title.y = element_text(size=13),legend.title.align=0.5, legend.title = element_text(size=13),axis.text = element_text(size=11),axis.text.x = element_text(vjust=1),legend.text = element_text(size=11),plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, vjust = 0, size=10))

ggsave(ss2_fig,filename = "Quality_SS2_MAG_12.14.2020.pdf", width=15, height=10, dpi=600)

#### Looking at best & high quality assembly completeness #### 

pow_best<-rbind(pow_best,pow_high)

ss1_best<-rbind(ss1_best,ss1_high)

ss2_best<-rbind(ss2_best,ss2_high)

pw_fig2<-ggplot(pow_best, aes(x = reorder(Bin_Num, -Completeness), y=Completeness)) + geom_bar(aes(fill = Contamination), stat = "identity") + scale_fill_gradient(low = "green", high = "red", na.value = NA) + theme_classic() + theme_bw()+theme_classic()+
  labs(title="Metagenome Assembled Genome Quality - Good Quality Only", subtitle="Color Gradient Based on Contamination of Assembly", caption = "Sample ID = POW_1-1a_S28", x="Bin Numer", y="Completeness (%)", fill="Contamination (%)")+
  theme(axis.title.x = element_text(size=13),axis.title.y = element_text(size=13),legend.title.align=0.5, legend.title = element_text(size=13),axis.text = element_text(size=11),axis.text.x = element_text(vjust=1),legend.text = element_text(size=11),plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, vjust = 0, size=10))
# reorder(Bin_Num, -Completeness) : reorders x axis based on largest to smallest #s in y axis!
ggsave(pw_fig,filename = "Quality_POW_MAG_12.8.2020.pdf", width=15, height=10, dpi=600)

ss1_fig2<-ggplot(ss1_best, aes(x = reorder(Bin_Num, -Completeness), y=Completeness)) + geom_bar(aes(fill = Contamination), stat = "identity") + scale_fill_gradient(low = "green", high = "red",na.value = NA) + theme_classic() + theme_bw()+theme_classic()+
  labs(title="Metagenome Assembled Genome Quality - Good Quality Only", subtitle="Color Gradient Based on Contamination of Assembly", caption = "Sample ID = SeaWater_1-1a_S26", x="Bin Numer", y="Completeness (%)", fill="Contamination (%)")+
  theme(axis.title.x = element_text(size=13),axis.title.y = element_text(size=13),legend.title.align=0.5, legend.title = element_text(size=13),axis.text = element_text(size=11),axis.text.x = element_text(vjust=1),legend.text = element_text(size=11),plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, vjust = 0, size=10))

ggsave(ss1_fig,filename = "Quality_SS1_MAG_12.8.2020.pdf", width=15, height=10, dpi=600)

ss2_fig2<-ggplot(ss2_best, aes(x = reorder(Bin_Num, -Completeness), y=Completeness)) + geom_bar(aes(fill = Contamination), stat = "identity") + scale_fill_gradient(low = "green", high = "red", na.value = NA) + theme_classic() + theme_bw()+theme_classic()+
  labs(title="Metagenome Assembled Genome Quality - Good Quality Only", subtitle="Color Gradient Based on Contamination of Assembly", caption = "Sample ID = SeaWater_1a3_S27", x="Bin Numer", y="Completeness (%)", fill="Contamination (%)")+
  theme(axis.title.x = element_text(size=13),axis.title.y = element_text(size=13),legend.title.align=0.5, legend.title = element_text(size=13),axis.text = element_text(size=11),axis.text.x = element_text(vjust=1),legend.text = element_text(size=11),plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, vjust = 0, size=10))

ggsave(ss2_fig,filename = "Quality_SS2_MAG_12.8.2020.pdf", width=15, height=10, dpi=600)
