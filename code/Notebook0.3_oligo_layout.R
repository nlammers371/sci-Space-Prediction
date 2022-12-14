# Oligo layout: Hash oligos were arrayed in a predetermined format
# This notebook transforms the 19 384-well plates which contained aliquotted hash oligos 
# into their grid coordinates on the space-grid
# Layout used for slides 1 -6 

# Load startup packages ---------------------------------------------------
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(ggplot2)
  library(randomcoloR)
})



setwd("/Volumes/GoogleDrive/My Drive/sciSpace/Submission_Data/Oligo_layout/")

# Constructing the oligo array ---------------------------------------------------
# Layout of how the printer arrays the spatial grid
oligo_plate_layout =read.delim("plate_layout.tsv", header = F,sep = "\t")

rownames(oligo_plate_layout) = as.character(1:84)
colnames(oligo_plate_layout) = as.character(1:84)


oligo_plate_layout = as.data.frame.table(as.matrix(oligo_plate_layout))
colnames(oligo_plate_layout) = c("Row","Col","Oligo")

rownames(oligo_plate_layout) = oligo_plate_layout$Oligo

oligo_plate_layout$plate = stringr::str_split_fixed(string = oligo_plate_layout$Oligo,pattern = "_",n = 2)[,1]
oligo_plate_layout$well = stringr::str_split_fixed(string = oligo_plate_layout$Oligo,pattern = "_",n = 2)[,2]
oligo_plate_layout$row_well = (substr(x = oligo_plate_layout$well,start = 1,stop = 1))
oligo_plate_layout$col_well = (substr(x = oligo_plate_layout$well,start = 2,stop = 3))


# Load in the positions that are  marked with SYBR green
sybr_positions_in_array = read.table("SYBR_positions.tsv", sep = "\t", header = T) 
sybr_positions_in_array =
  sybr_positions_in_array %>%
  dplyr::select(Oligo, SYBR)

oligo_plate_layout = 
  left_join(oligo_plate_layout, sybr_positions_in_array, by = "Oligo") %>%
  replace_na(list(SYBR = FALSE))

# Read in all the hash oligos available
all_hashes = read.table(file = "all_hashes.tsv", sep= "\t",header = F)
colnames(all_hashes) = c("plate","position","RT_seq","seq","barcode")
all_hashes = 
  all_hashes %>% 
  mutate(plate = stringr::str_split_fixed(plate, "_",2)[,1]) %>%
  dplyr::select(-seq)

# This function builds a 384 well plate from 4 given 96 well plates in a specific order
build_384_well_plate = function(plate1, plate2, plate3, plate4, hashes, label = "", rev = F ){
  
  plate1_table = 
    data.frame(
      hash =  hashes %>% filter(plate == plate1) %>% pull(RT_seq),
      row = seq(1:8) * 2  - 1,
      col = (seq(0,95) %/% 8 + 1)*2 - 1,
      position = "1")
  
  plate2_table = 
    data.frame(
      hash =  hashes %>% filter(plate == plate2) %>% pull(RT_seq),
      row = seq(1:8) * 2 - 1,
      col = (seq(0,95) %/% 8 + 1)*2,
      position = "2")
  
  plate3_table = 
    data.frame(
      hash =  hashes %>% filter(plate == plate3) %>% pull(RT_seq),
      row = seq(1:8) * 2,
      col = (seq(0,95) %/% 8 + 1)*2 - 1,
      position = "3")
  
  plate4_table =
    data.frame(
      hash =  hashes %>% filter(plate == plate4) %>% pull(RT_seq),
      row = seq(1:8) * 2,
      col = (seq(0,95) %/% 8 + 1)*2,
      position = "4")
  
  plate_384_well_plate = 
    rbind(plate1_table,
          plate2_table,
          plate3_table,
          plate4_table)
  
  plate_384_well_plate$plate = label
  
  rows_to_letters = 
    data.frame(row_letters = LETTERS[1:16],
               row = seq(1,16))
  
  
  if (rev) {
    
    plate_384_well_plate$col = 
      plate_384_well_plate$col * (-1) + max(plate_384_well_plate$col) + 1
    
    plate_384_well_plate$row = 
      plate_384_well_plate$row * (-1) + max(plate_384_well_plate$row) + 1
    
    plate_384_well_plate = 
      left_join(plate_384_well_plate,rows_to_letters, by = "row")
    
    plate_384_well_plate$well_position = paste0(label, "_",
                                                plate_384_well_plate$row_letters,
                                                plate_384_well_plate$col)
    return(plate_384_well_plate)
    
    
  } else{
    
    plate_384_well_plate = 
      left_join(plate_384_well_plate,rows_to_letters, by = "row")
    
    plate_384_well_plate$well_position = paste0(label, "_",
                                                plate_384_well_plate$row_letters,
                                                plate_384_well_plate$col)
    
    return(plate_384_well_plate)
  }
  
}

# Build the 19 384 well plates that constitute the spatial grid -----------

plate1 = build_384_well_plate("plate3","plate4","plate5","plate6",hashes = all_hashes, label = "Plate1")
plate2 = build_384_well_plate("plate6","plate3","plate4","plate5",hashes = all_hashes, label = "Plate2")
plate3 = build_384_well_plate("plate5","plate6","plate3","plate4",hashes = all_hashes, label = "Plate3")
plate4 = build_384_well_plate("plate4","plate5","plate6","plate3",hashes = all_hashes, label = "Plate4")
plate5 = build_384_well_plate("plate3","plate4","plate5","plate6",hashes = all_hashes, label = "Plate5", rev = T)
plate6 = build_384_well_plate("plate7","plate8","plate9","plate10",hashes = all_hashes, label = "Plate6")
plate7 = build_384_well_plate("plate10","plate7","plate8","plate9",hashes = all_hashes, label = "Plate7")
plate8 = build_384_well_plate("plate9","plate10","plate7","plate8",hashes = all_hashes, label = "Plate8")
plate9 = build_384_well_plate("plate8","plate9","plate10","plate7",hashes = all_hashes, label = "Plate9")
plate10 = build_384_well_plate("plate7","plate8","plate9","plate10",hashes = all_hashes, label = "Plate10", rev = T)
plate11 = build_384_well_plate("plate11","plate12","plate13","plate14",hashes = all_hashes, label = "Plate11")
plate12 = build_384_well_plate("plate14","plate11","plate12","plate13",hashes = all_hashes, label = "Plate12")
plate13 = build_384_well_plate("plate13","plate14","plate11","plate12",hashes = all_hashes, label = "Plate13")
plate14 = build_384_well_plate("plate12","plate13","plate14","plate11",hashes = all_hashes, label = "Plate14")
plate15 = build_384_well_plate("plate11","plate12","plate13","plate14",hashes = all_hashes, label = "Plate15", rev = T)
plate16 = build_384_well_plate("plate15","plate16","plate17","plate18",hashes = all_hashes, label = "Plate16")
plate17 = build_384_well_plate("plate18","plate15","plate16","plate17",hashes = all_hashes, label = "Plate17")
plate18 = build_384_well_plate("plate17","plate18","plate15","plate16",hashes = all_hashes, label = "Plate18")
plate19 = build_384_well_plate("plate16","plate17","plate18","plate15",hashes = all_hashes, label = "Plate19")

all_plates = rbind(plate1,plate2,plate3,plate4,
                   plate5,plate6,plate7,plate8,
                   plate9,plate10,plate11,plate12,
                   plate13,plate14,plate15,plate16,
                   plate17,plate18,plate19)


all_plates = all_plates %>%
  dplyr::rename(Oligo = well_position) %>%
  dplyr::select(-plate)


oligo_plate_layout =
  left_join(oligo_plate_layout,all_plates, by = "Oligo" )

oligo_plate_layout  = left_join(oligo_plate_layout, (all_hashes %>% dplyr::select(hash = RT_seq, barcode)), by = "hash")


# Plots of how rows and columns of 384 well plates end up in the grid --------
ggplot(oligo_plate_layout) + 
  geom_tile(data=oligo_plate_layout %>% dplyr::select(-col_well), aes(x = Row, y = Col)) +
  geom_tile(data=oligo_plate_layout %>% dplyr::select(-col_well), aes(x = Row, y = Col)) +
  geom_tile(aes(x = Row, y = Col, fill = col_well)) +
  facet_wrap(~col_well, ncol = 5) +
  theme_void()  +
  theme(legend.position = "none", 
        text = element_text(size = 6),
        strip.text.x = element_text(size = 6)) +   
  ggsave(filename = "ColumnWell_of_384plate.png", width = 8, height = 5)


ggplot(oligo_plate_layout) + 
  geom_tile(data=oligo_plate_layout %>% dplyr::select(-row_well), aes(x = Row, y = Col)) +
  geom_tile(aes(x = Row, y = Col, fill = row_well)) +
  facet_wrap(~row_well, ncol = 5) +
  theme_void()  +
  theme(legend.position = "none", 
        text = element_text(size = 6),
        strip.text.x = element_text(size = 6)) + 
  ggsave(filename = "RowWell_of_384plate.png", width = 8, height = 5)

ggplot(oligo_plate_layout) + 
  geom_tile(data=oligo_plate_layout %>% dplyr::select(-plate), aes(x = Row, y = Col)) +
  geom_tile(aes(x = Row, y = Col, fill = plate)) + 
  facet_wrap(~plate) +
  theme_void()  +
  theme(legend.position="none") +
  ggsave(filename = " plate_by_384plate.png", width = 8, height = 5)


# Revalue oligo combos corresponding to rows and combos for sectors --------

oligo_plate_layout$rowCombo <- plyr::revalue((oligo_plate_layout$row_well),c("A" = 'A',
                                                                             "E" = 'A',
                                                                             "I" = 'A',
                                                                             "M" = 'A',
                                                                             "B" = 'B',
                                                                             "F" = 'B',
                                                                             "J" = 'B',
                                                                             "N" = 'B',
                                                                             "C" = 'C',
                                                                             "G" = 'C',
                                                                             "K" = 'C',
                                                                             "O" = 'C',
                                                                             "D" = 'D',
                                                                             "H" = 'D',
                                                                             "L" = 'D',
                                                                             "P" = 'D'))

oligo_plate_layout$colCombo <- plyr::revalue((oligo_plate_layout$col_well),c("1" = '1',
                                                                             "10" = '2',
                                                                             "11" = '3',
                                                                             "12" = '4',
                                                                             "13" = '1',
                                                                             "14" = '2',
                                                                             "15" = '3',
                                                                             "16" = '4',
                                                                             "17" = '1',
                                                                             "18" = '2',
                                                                             "19" = '3',
                                                                             "20" = '4',
                                                                             "2" = '2',
                                                                             "21" = '1',
                                                                             "22" = '2',
                                                                             "23" = '3',
                                                                             "24" = '4',
                                                                             "3" = '3',
                                                                             "4" = '4',
                                                                             "5" = '1',
                                                                             "6" = '2',
                                                                             "7" = '3',
                                                                             "8" = '4',
                                                                             "9" = '1'))



oligo_plate_layout$combo = paste(oligo_plate_layout$rowCombo, oligo_plate_layout$colCombo)

oligo_plate_layout$sector<- plyr::revalue((oligo_plate_layout$combo),c(
  "D 4"= "sector16", 
  "C 4" = "sector12", 
  "B 4" = "sector8", 
  "A 4" = "sector4", 
  "D 3"= "sector15",
  "C 3" = "sector11", 
  "B 3" = "sector7", 
  "A 3" = "sector3", 
  "D 2"= "sector14", 
  "C 2" = "sector10", 
  "B 2"= "sector6", 
  "A 2" = "sector2", 
  "D 1" = "sector13", 
  "C 1" = "sector9", 
  "B 1" = "sector5", 
  "A 1" = "sector1"))



ggplot(oligo_plate_layout) + 
  geom_tile(data=oligo_plate_layout %>% dplyr::select(-combo), aes(x = Row, y = Col)) +
  geom_tile(aes(x = Row, y = Col, fill = sector)) + 
  facet_wrap(~combo) +
  theme_void()  +
  theme(legend.position="none") 



colors = c("#41e05e", 
           "#fc9cf6",
           "#f9e0a9", 
           "#ed6f99",
           "#1956d1",
           "#eaaf85",
           "#dd7f7a",
           "#27e8d7",
           "#8e68ff",
           "#7dd7d8",
           "#3a63a8",
           "#f2b529",
           "#bbfc9f",
           "#20188e",
           "#9b08cc",
           "#e0503a")

sectors = oligo_plate_layout$sector %>% unique()

colors_df = data.frame(color = colors, 
                       sector = sectors)

oligo_plate_layout = left_join(oligo_plate_layout, colors_df, by = "sector")
write.table(oligo_plate_layout,file = "oligo_plate_layout.tsv",sep = "\t",quote = F)

# Supplementary Figure 2 ??? Panel D ----------------------------------------
supp_grid_figure = "/Volumes/GoogleDrive/My Drive/sciSpace/Figures/Figure_Components/Supplemental_Figure_Grid_Design/"


oligo_plate_layout %>%
  group_by(combo) %>%
  mutate(med_row = median(as.numeric(Row)), 
         med_col = median(as.numeric(Col)),
         sector = stringr::str_replace(sector, pattern = "sector", "Sector ")) %>%
  ggplot() + 
  geom_tile(aes(x = Row, y = Col, fill = combo),color = "black") + 
  geom_label(aes(x = med_row, y = med_col, label = sector), size = 1.5) +
  theme_void()  +
  scale_fill_manual(values = colors) +
  theme(legend.position = "none",
        text = element_text(size = 6)) + 
  ggsave(paste(supp_grid_figure,
               "sectors.png",
               sep = ""), 
         height = 2, 
         width = 2, dpi = 550, 
         units = "in")

# Supplementary Figure 2 ??? Panel E ----------------------------------------
oligo_plate_layout$same_seq_example = 
  oligo_plate_layout$Oligo %in% c("Plate1_A1", 
                                  "Plate5_A2",
                                  "Plate9_B1",
                                  "Plate13_B2",
                                  "Plate17_P24")


ggplot(oligo_plate_layout) + 
  geom_tile(aes(x = Row, y = Col, fill = combo)) +     
  geom_tile(data=oligo_plate_layout %>% dplyr::filter(same_seq_example), aes(x = Row, y = Col),
            fill = "white") + 
  theme_void()  + 
  scale_fill_manual(values = colors) +
  theme(legend.position = "none",
        text = element_text(size = 6)) +
  ggsave(paste(supp_grid_figure,
               "same_sequence.png",
               sep = ""), 
         height = 2, 
         width = 2, 
         dpi = 550,
         units = "in")

# Supplementary Figure 2 ??? Panel A ----------------------------------------

ggplot(oligo_plate_layout) +
  geom_point(data = oligo_plate_layout %>% filter(!SYBR), aes(x = Row, y = Col), 
             alpha = .2, color = "black", stroke = 0, size = .5 ) +
  geom_point(data = oligo_plate_layout %>% filter(SYBR), aes(x = Row, y = Col ), 
             color = "green2", size = 1, stroke = 0 ) +
  monocle:::monocle_theme_opts() + 
  theme_void() +
  theme(legend.position = "none") + 
  ggsave(paste(supp_grid_figure,
               "sybr_grid.png",
               sep = ""), 
         height = 2, 
         width = 2, 
         units = "in", 
         dpi = 550)




# Supplemental Figure 2 ??? Panel C -----------------------------------------

spot_size_df = 
  read.table(file="Submission_Data/Oligo_layout/sci_space_spot_size_200120.csv", 
             header = T, 
             sep = ',')

# plot spot area AND center distance in one plot
spot_size_df %>%
  mutate(measurement = ifelse(length_meas, length, radius), 
         label = ifelse(length_meas, "Spot-to-spot", "Spot Radius")) %>%
  dplyr::select(measurement,label) %>% 
  ggplot() +
  geom_boxplot(aes(x = label,
                   y=measurement),
               fill = "grey80",
               size = 0.25,
               color = "black",
               outlier.size = 0.75,
               outlier.stroke = 0) + 
  labs(y = "Distance (um)") + 
  ylim(0,300) + 
  monocle3:::monocle_theme_opts() + 
  theme(legend.position = "none",
        axis.text.x = element_text(size = 8, 
                                   angle = 45,
                                   hjust = 1),
        axis.text.y = element_text(size = 8),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 8)) +
  ggsave("Figures/Figure_Components/Supplement_grid_QC/spot_characteristics.pdf", 
         height = 2.5,
         width = 2) 

spot_size_df %>%
  mutate(measurement = ifelse(length_meas, length, radius), 
         label = ifelse(length_meas, "Spot-to-spot", "Spot Radius")) %>%
  dplyr::select(measurement,label) %>% 
  group_by(label) %>%
  summarise(mean_measurement =mean(measurement),
            sd_measurement = sqrt(var(measurement)))

# Supplemental Figure 2 ??? Panel B -----------------------------------------

ggplot(oligo_plate_layout) +
  geom_point(data = oligo_plate_layout %>% filter(combo != "C 3"), aes(x = Row, y = Col), 
             alpha = .2, color = "black", stroke = 0, size = .5 ) +
  geom_point(data = oligo_plate_layout %>% filter(combo == "C 3"), aes(x = Row, y = Col ), 
             color = "green2", size = .5, stroke = 0 ) +
  monocle3:::monocle_theme_opts() + 
  theme_void() +
  theme(legend.position = "none") +
  ggsave("~/Google Drive File Stream/My Drive/sciSpace/Figures/Figure1 Components/slide_sector_SYBR.png", height = 2, width = 2, units = "in", dpi = 900)




