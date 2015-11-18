#download data if it does not exists
if (!file.info('UCI HAR Dataset')$isdir) {
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  dir.create('UCI HAR Dataset')
  download.file(url, 'UCI-HAR-dataset.zip', method='curl')
  unzip('./UCI-HAR-dataset.zip')
}

# read test data
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

# read train data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

# merge  X training and test data set
combinedSet_x <- rbind(X_train,X_test)

# merge training and test subject
subject <- rbind(subject_train, subject_test)

# merge Y training and test data set
Y <- rbind(y_train, y_test)

# read the features set
features <- read.table("./UCI HAR Dataset/features.txt")

# select the column that measures mean or standard deviation
mean_sd <- grep(("-mean|-std"),features[,2],ignore.case=TRUE)
# select only the columns which has means and standard deviations in measurement
X_mean_std <- combinedSet_x[,mean_sd]

# assign descriptive name to features
## extract feature name from feature data frame and assign to desired data frame of means and standard deviation
colnames(X_mean_std) <- features[mean_sd,2]
# removing paranthesis for easy reading
names(X_mean_std) <- gsub("\\(|\\)", "", names(X_mean_std))

# label the data set with activity name
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
Y[,1] <- sapply(Y[,1],function (x) activity_labels[x,2])
colnames(Y) <- c("Activity")
colnames(subject) <- "subject"
X_mean_std <- cbind(subject,X_mean_std,Y)

# Create another data set with average value for each variable for each activity and subject
data <- with(X_mean_std, aggregate(X_mean_std, by=list(Subject=subject, Act=Activity),FUN = mean))
data <- data[, !(colnames(data) %in% c("subject", "Activity"))]

# write the data set into text file
write.table(data, './tidy_data.txt', row.name=F)
