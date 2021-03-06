install.packages("twitteR")
devtools::install_github("r-lib/devtools")
install.packages("devtools")
install.packages("backports")

library(twitteR)
library(httr)
library(devtools)
library(base64enc)
install.packages("httpuv")
library(httpuv)
library(tm)
library(ggplot2)
library(stringr)
install.packages("wordcloud")
library(wordcloud)
library(lubridate)
library(data.table)



consumer_key<-""
consumer_secret<-""
access_token<-""
access_secret<-""

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
2


# too, without, only VS earthquake? ?ธ๊ธ๋ ??ธ
library(ggplot2)

searchTerm<-"too" # too, without, only, earthquake๋ฅ? ๋ฒ๊ฐ? ?ฃ๊ณ? ๊ฒฐ๊ณผ ??ธ  
trendingTweets<-searchTwitter(searchTerm, n=1000)
trendingTweets.df<-twListToDF(trendingTweets)
trendingTweets.df$text<-sapply(trendingTweets.df$text, function(x) iconv(x, to='UTF-8'))
ggplot(data=trendingTweets.df, aes(x=created))+geom_histogram(aes(fill=..count..))+theme(legend.position="none")+xlab("Time")+ylab("Number of tweets")+scale_fill_gradient(low="midnightblue", high="aquamarine4")




# cleaning & transforming ๊ธฐ๋ฅ? extractTweets ?จ? ? ?

extractTweets <- function(enc){
  
  tweets = searchTwitter(enc, n=1000)
  tweets.df = twListToDF(tweets)
  tweets.df$text <- sapply(tweets.df$text,function(x) iconv(x,to='UTF-8'))
  
  return(tweets.df)
}


# too, without, only๋ฅ? ?ค??๋ก? ?? ๋ถ์


INEword<-enc2utf8("too")  # Implied Negative Expression(INEword)๋ก์ too, without, only๋ฅ? ๋ฒ๊ฐ? ?ฃ๊ณ? ๋ถ์

tweets_PUS<-extractTweets(INEword)
tweets_PUS$text <- sapply(tweets_PUS$text,function(x) iconv(x,to='UTF-8'))
View(tweets_PUS)
tweets_PUS_rmv<-tweets_PUS[!is.na(tweets_PUS$text),]  # ๊ฐ์ด N/A?ธ tweets_PUS$text๊ฐ ??ค๋ฉ? ๊ท? ?ฐ?ด?ฐ row๋ฅ? ? ๊ฑฐํ๊ฒ ๋ค.
View(tweets_PUS_rmv)




######### Sentimental Analysis ##############

install.packages("syuzhet")
library(syuzhet)

tweetSentiments<-get_sentiment(tweets_PUS_rmv$text, method="syuzhet")
tweets_A <- cbind(tweets_PUS_rmv, tweetSentiments)
View(tweets_A)

encodeSentiment <- function(x) {
  if(x <= -0.5){
    "very negative"
  }else if(x > -0.5 & x < 0){
    "negative"
  }else if(x > 0 & x < 0.5){
    "positive"
  }else if(x >= 0.5){
    "very positive"
  }else {
    "neutral"
  }
}

tweets_A$sentiment <- sapply(tweets_A$tweetSentiments,encodeSentiment)

# ggplot

library(ggplot2)

ggplot(tweets_A, aes(sentiment)) +
  geom_bar(fill = "aquamarine4") + 
  theme(legend.position="none", axis.title.x = element_blank()) +
  ylab("Number of tweets") + 
  ggtitle("Tweets by Sentiment") 

# NRC Sample
tweetSentiments <- get_nrc_sentiment(tweets_PUS_rmv$text)
tweets_B<-cbind(tweets_PUS_rmv, tweetSentiments)    #?๋ฏธ๋?? ?ค?  0&1
View(tweets_B)
sentimentTotals<- data.frame(colSums(tweets_B[,c(17:26)]))
names(sentimentTotals)<-"count" 
sentimentTotals<- cbind("sentiment" = rownames(sentimentTotals), sentimentTotals)
rownames(sentimentTotals) <- NULL
View(sentimentTotals)

ggplot(data = sentimentTotals, aes(x = sentiment, y = count)) +
  geom_bar(aes(fill = sentiment), stat = "identity") +
  theme(legend.position = "none") +
  xlab("Sentiment") + ylab("Total Count") + ggtitle("Total Sentiment Score for All Tweets")





######### WordCloud ###############

nohandles <- str_replace_all(tweets_PUS_rmv$text, "@\\w+", "")
wordCorpus <- Corpus(VectorSource(nohandles))

##use tm_map to apply transformations like stopword removal (a, an, the) and so on 
wordCorpus <- tm_map(wordCorpus, removePunctuation)
wordCorpus <- tm_map(wordCorpus, content_transformer(tolower))
wordCorpus <- tm_map(wordCorpus, removeWords, stopwords("english"))
wordCorpus <- tm_map(wordCorpus, removeWords, c("amp"))

wordCorpus <- tm_map(wordCorpus, stripWhitespace)


wordcloud(words=wordCorpus)

pal <- brewer.pal(n=9,name="YlGnBu")
pal <- pal[-(1:4)] # ?? 4๊ฐ? ?๊น์ ๋นผ์. 

wordcloud(words = wordCorpus, max.words=100, min.freq=5, random.order=FALSE, 
          rot.per=0.4, colors=pal)   ###wordcloud๋ฅ? ?ธ๋ก๊?๋ก๋ฐฉ?ฅ?ผ๋ก? ?  ? ??
