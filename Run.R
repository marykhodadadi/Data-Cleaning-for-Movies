#Import datasets
movie_infoData <- read.table('movie_info.tsv',
                             sep = '\t', header = TRUE,
                             na.strings = '', fill = TRUE, quote = "\"")

reviewsData <- read.table('reviews.tsv',
                          sep = '\t', header = TRUE,
                          na.strings = '', fill = TRUE, quote = "\"")

#Removing extra symbols in variable names
names(movie_infoData) <- gsub('_', '', names(movie_infoData))
names(reviewsData) <- gsub('_', '', names(reviewsData))

#Checking missing values
any(is.na(movie_infoData))
any(is.na(reviewsData))
colSums(is.na(movie_infoData))
colSums(is.na(reviewsData))
sum(is.na(movie_infoData))
sum(is.na(reviewsData))

#Correcting the formate of Date
library(dplyr)
movie_infoData <- mutate(movie_infoData,
                         theaterdate= as.Date(theaterdate, "%b%d,%Y"),
                         dvddate= as.Date(dvddate, "%b%d,%Y"))
reviewsData <- mutate(reviewsData, date= as.Date(date, "%b%d,%Y"))

#Use descriptive names to name variables in the data set
#Removing unnecassery simbols in columns 
movie_infoData <- dplyr::rename(movie_infoData, RottenTomatosRating = rating,
                                earningmilliondollar = boxoffice)
movie_infoData <- mutate(movie_infoData,
                         earningmillion= gsub(",", "", earningmillion))
movie_infoData <- mutate(movie_infoData, runtime= gsub("minutes", "", runtime))
movie_infoData <- mutate(movie_infoData,
                         earningmillion=as.numeric(earningmillion)/1000000)
movie_infoData <- mutate(movie_infoData,
                         earningmillion=round(earningmillion, digits = 2))
reviewsData <- dplyr::rename(reviewsData,
                             criticReview= review)

reviewsData <- dplyr::rename(reviewsData, criticrating=rating,
                             criticName=critic)

#ommitting currency column
movie_infoData$currency <- NULL

#Encoding categorical variable
reviewsData <- mutate(reviewsData, fresh= factor(reviewsData$fresh,
                                                 labels = c('TRUE', 'FALSE')))
reviewsData <- mutate(reviewsData, topcritic= factor(topcritic,
                                                     labels = c('FALSE', 'TRUE')))

#Merge datasets and removing the outliers
mergeData <- merge(movie_infoData, reviewsData, by="id")

mergeData <- arrange(mergeData, date)
mergeData <- mergeData %>% mutate(year=as.POSIXlt(date)$year+1900) %>% filter(year>1800)
mergeData$year <- NULL

mergeData <- mergeData %>% mutate(year=as.POSIXlt(theaterdate)$year+1900)%>% filter(year>1991)
mergeData$year <- NULL